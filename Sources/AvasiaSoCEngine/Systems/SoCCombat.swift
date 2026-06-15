import Foundation
import AvasiaEngine

public struct SoCCombatResult: Sendable {
    public var lines: [StyledLine]
    public var died: Bool
    public var fled: Bool

    public init(_ lines: [StyledLine], died: Bool = false, fled: Bool = false) {
        self.lines = lines
        self.died = died
        self.fled = fled
    }
}

public enum SoCCombat {
    public static func begin(
        enemy: SoCCombatant,
        deathText: String,
        state: inout SoCGameState,
        allowsFlee: Bool = false
    ) {
        state.inCombat = true
        state.enemy = enemy
        state.enemyDeathText = deathText
        state.combatAllowsFlee = allowsFlee
        state.combatHunterStrikeUsed = false
        state.combatGuardianBlockAvailable = state.playerClass == .guardian
        state.combatScoutEdgeUsed = false
    }

    public static func end(state: inout SoCGameState) {
        state.inCombat = false
        state.enemy = nil
        state.enemyDeathText = ""
        state.combatAllowsFlee = false
    }

  public static func handle(_ input: ParsedInput, state: inout SoCGameState) -> SoCCombatResult {
        guard state.inCombat, var enemy = state.enemy else {
            return SoCCombatResult([.hint("You are not in combat.")])
        }

        if input.contains("HELP") || input.contains("COMMANDS") {
            var cmds = ["ATTACK", "EAT POTION", "FLEE (optional fights)", "OBJECTIVES"]
            if state.playerClass == .guardian {
                cmds.append("Guardian: first enemy hit blocked once")
            }
            return SoCCombatResult(cmds.map { .body($0) })
        }

        if input.contains("FLEE") || input.contains("RETREAT") || input.contains("ESCAPE") {
            return handleFlee(state: &state)
        }

        if SoCGlobalCommands.isEatCommand(input) {
            return SoCCombatResult(SoCGlobalCommands.eatInCombat(input, state: &state))
        }

        let attack = ["ATTACK", "STRIKE", "FIGHT"]
        guard attack.contains(where: { input.contains($0) }) else {
            return SoCCombatResult([.hint("ATTACK, EAT POTION, or FLEE (if allowed).")])
        }

        var lines: [StyledLine] = []
        state.neededLuckToHit = Int.random(in: 0...11)
        state.playerAttacksFirst = state.isFasterThanEnemy()

        if state.playerAttacksFirst {
            lines.append(contentsOf: playerAttack(state: &state, enemy: &enemy))
            if state.playerHp > 0 && !enemy.isDead {
                lines.append(contentsOf: enemyAttack(state: &state, enemy: &enemy))
            }
        } else {
            lines.append(contentsOf: enemyAttack(state: &state, enemy: &enemy))
            if state.playerHp > 0 && !enemy.isDead {
                lines.append(contentsOf: playerAttack(state: &state, enemy: &enemy))
            }
        }

        state.enemy = enemy

        if state.playerHp <= 0 {
            lines.append(.body(state.enemyDeathText))
            lines.append(.body("You have died."))
            state.deathCount += 1
            end(state: &state)
            return SoCCombatResult(lines, died: true)
        }

        if enemy.isDead {
            lines.append(.body("You killed \(enemy.name)!"))
            lines.append(contentsOf: SoCQuestProgress.grantCombatExp(state: &state))
            end(state: &state)
        }

        return SoCCombatResult(lines)
    }

    private static func handleFlee(state: inout SoCGameState) -> SoCCombatResult {
        let canFlee = state.combatAllowsFlee || state.playerClass == .scout
        guard canFlee else {
            return SoCCombatResult([.body("There is nowhere honorable to run.")])
        }
        let lines: [StyledLine]
        switch state.playerClass {
        case .scout:
            lines = [.body("You melt into smoke and shadow — the Fox leaves no trail.")]
        case .hunter:
            lines = [.body("You break contact and regroup with the column.")]
        case .guardian:
            lines = [.body("You fall back under shield cover, bleeding but alive.")]
        case .none:
            lines = [.body("You disengage and stumble to safety.")]
        }
        end(state: &state)
        return SoCCombatResult(lines, fled: true)
    }

    private static func playerAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        var luckThreshold = state.neededLuckToHit
        if state.playerClass == .scout, !state.combatScoutEdgeUsed {
            luckThreshold = max(0, luckThreshold - 2)
            state.combatScoutEdgeUsed = true
        }

        let hits = state.playerLuck >= luckThreshold
        guard hits else { return [.body("You miss!")] }

        var damage = state.playerAtk
        if state.playerClass == .hunter, !state.combatHunterStrikeUsed {
            damage += 3
            state.combatHunterStrikeUsed = true
            enemy.hp -= damage
            return [
                .body("You attack \(enemy.name)!"),
                .body("Your wolf spirit drives the first blow — \(damage) damage!")
            ]
        }

        enemy.hp -= damage
        return [
            .body("You attack \(enemy.name)!"),
            .body("You deal \(damage) damage!")
        ]
    }

    private static func enemyAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        if state.playerClass == .guardian, state.combatGuardianBlockAvailable {
            state.combatGuardianBlockAvailable = false
            return [
                .body("\(enemy.name) attacks you!"),
                .body("Your bear shield absorbs the blow — the line holds!")
            ]
        }

        if state.enemyLuckBeatsRoll() {
            state.playerHp -= enemy.atk
            return [
                .body("\(enemy.name) attacks you!"),
                .body("You take \(enemy.atk) damage!")
            ]
        }
        return [.body("\(enemy.name) misses!")]
    }

    public static func statLines(state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = []
        if let enemy = state.enemy {
            lines.append(.body("\(enemy.name):\n\t HEALTH: \(enemy.hp)\n\t ATTACK: \(enemy.atk)\n\t SPEED: \(enemy.speed)"))
        }
        let classNote: String
        switch state.playerClass {
        case .hunter: classNote = "hunter (first strike +3)"
        case .guardian: classNote = "guardian (block 1 hit)"
        case .scout: classNote = "scout (edge + flee)"
        case .none: classNote = "none"
        }
        lines.append(.body("\(state.playerName.isEmpty ? "You" : state.playerName):\n\t HEALTH: \(state.playerHp)\n\t ATTACK: \(state.playerAtk)\n\t SPEED: \(state.playerSpeed)\n\t CLASS: \(classNote)"))
        return lines
    }
}
