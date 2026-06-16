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
    private static let hitRollRange = 0...10

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
            return SoCCombatResult(helpLines(state: state))
        }

        if SoCGlobalCommands.objectiveTriggers.contains(where: { input.contains($0) }) {
            return SoCCombatResult(SoCJournal.objectiveLines(for: state))
        }

        if input.contains("FLEE") || input.contains("RETREAT") || input.contains("ESCAPE") {
            return handleFlee(state: &state)
        }

        if SoCGlobalCommands.isEatCommand(input) {
            return handleEat(input, state: &state, enemy: &enemy)
        }

        let attack = ["ATTACK", "STRIKE", "FIGHT"]
        guard attack.contains(where: { input.contains($0) }) else {
            return SoCCombatResult([.hint("ATTACK, EAT POTION, OBJECTIVES, or FLEE (if allowed).")])
        }

        var lines = exchangeAttacks(state: &state, enemy: &enemy)
        state.enemy = enemy
        return resolveAfterExchange(lines: &lines, enemy: enemy, state: &state)
    }

    // MARK: - Turn resolution

    private static func exchangeAttacks(
        state: inout SoCGameState,
        enemy: inout SoCCombatant
    ) -> [StyledLine] {
        state.playerAttacksFirst = state.isFasterThanEnemy()
        var lines: [StyledLine] = []

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

        lines.append(contentsOf: turnStatus(state: state, enemy: enemy))
        lines.append(contentsOf: lowHpWarning(state: state))
        return lines
    }

    private static func resolveAfterExchange(
        lines: inout [StyledLine],
        enemy: SoCCombatant,
        state: inout SoCGameState
    ) -> SoCCombatResult {
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

    private static func handleEat(
        _ input: ParsedInput,
        state: inout SoCGameState,
        enemy: inout SoCCombatant
    ) -> SoCCombatResult {
        var lines = SoCGlobalCommands.eatInCombat(input, state: &state)
        guard state.inCombat, state.playerHp > 0, !enemy.isDead else {
            state.enemy = enemy
            return SoCCombatResult(lines)
        }

        lines.append(.body("You gulp it down — the enemy does not wait."))
        lines.append(contentsOf: enemyAttack(state: &state, enemy: &enemy))
        lines.append(contentsOf: turnStatus(state: state, enemy: enemy))
        lines.append(contentsOf: lowHpWarning(state: state))
        state.enemy = enemy
        return resolveAfterExchange(lines: &lines, enemy: enemy, state: &state)
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

    // MARK: - Attacks

    private static func playerAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        var luck = effectivePlayerLuck(state)
        if state.playerClass == .scout, !state.combatScoutEdgeUsed {
            luck += 2
            state.combatScoutEdgeUsed = true
        }

        guard rollsHit(attackerLuck: luck, roll: &state.neededLuckToHit) else {
            return [.body(playerMissLine(enemyName: enemy.name))]
        }

        var damage = state.playerAtk
        var bonusNote: String?

        if state.playerClass == .hunter, !state.combatHunterStrikeUsed {
            damage += 3
            state.combatHunterStrikeUsed = true
            bonusNote = "Your wolf spirit drives the first blow"
        } else if state.playerClass == .hunter, enemy.hp <= enemy.maxHp / 2 {
            damage += 2
            bonusNote = "You press the wounded prey"
        }

        enemy.hp = max(0, enemy.hp - damage)
        var lines: [StyledLine] = [.body("You strike \(enemy.name) for \(damage) damage!")]
        if let bonusNote {
            lines.insert(.body(bonusNote + " —"), at: 0)
        }
        lines.append(.body(enemyHpLine(enemy)))
        return lines
    }

    private static func enemyAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        if state.playerClass == .guardian, state.combatGuardianBlockAvailable {
            state.combatGuardianBlockAvailable = false
            return [
                .body("\(enemy.name) attacks you!"),
                .body("Your bear shield absorbs the blow — the line holds!")
            ]
        }

        guard rollsHit(attackerLuck: enemy.luck, roll: &state.neededLuckToHit) else {
            return [.body(enemyMissLine(enemyName: enemy.name))]
        }

        var damage = enemy.atk
        if state.playerClass == .guardian {
            damage = max(1, damage - 1)
        }
        state.playerHp = max(0, state.playerHp - damage)
        return [
            .body("\(enemy.name) hits you for \(damage) damage!"),
            .body(playerHpLine(state))
        ]
    }

    // MARK: - Hit math

    /// Attacker hits when luck meets or beats a d11 roll (0...10).
    static func hits(attackerLuck: Int, roll: Int) -> Bool {
        attackerLuck >= roll
    }

    static func rollsHit(attackerLuck: Int, roll: inout Int) -> Bool {
        roll = Int.random(in: hitRollRange)
        return hits(attackerLuck: attackerLuck, roll: roll)
    }

    static func effectivePlayerLuck(_ state: SoCGameState) -> Int {
        state.playerLuck + max(0, state.playerLevel - 1)
    }

    // MARK: - Display

    public static func statLines(state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = []
        if let enemy = state.enemy {
            lines.append(.body("\(enemy.name):\n\t HEALTH: \(enemy.hp)/\(enemy.maxHp)\n\t ATTACK: \(enemy.atk)\n\t SPEED: \(enemy.speed)\n\t LUCK: \(enemy.luck)"))
        }
        let classNote: String
        switch state.playerClass {
        case .hunter: classNote = "hunter (first strike +3, wounded +2)"
        case .guardian: classNote = "guardian (block 1 hit, −1 damage)"
        case .scout: classNote = "scout (+2 first hit, flee)"
        case .none: classNote = "none"
        }
        let luck = effectivePlayerLuck(state)
        lines.append(.body("\(state.playerName.isEmpty ? "You" : state.playerName):\n\t HEALTH: \(state.playerHp)/\(state.playerMaxHp)\n\t ATTACK: \(state.playerAtk)\n\t SPEED: \(state.playerSpeed)\n\t LUCK: \(luck)\n\t CLASS: \(classNote)"))
        return lines
    }

    private static func turnStatus(state: SoCGameState, enemy: SoCCombatant) -> [StyledLine] {
        [.body("— \(playerHpLine(state)) · \(enemyHpLine(enemy))")]
    }

    private static func playerHpLine(_ state: SoCGameState) -> String {
        "You \(state.playerHp)/\(state.playerMaxHp) HP"
    }

    private static func enemyHpLine(_ enemy: SoCCombatant) -> String {
        "\(enemy.name) \(enemy.hp)/\(enemy.maxHp) HP"
    }

    private static func lowHpWarning(state: SoCGameState) -> [StyledLine] {
        guard state.playerMaxHp > 0,
              state.playerHp > 0,
              state.playerHp <= state.playerMaxHp / 4 else { return [] }
        return [.body("Blood runs hot — you're close to breaking.")]
    }

    private static func helpLines(state: SoCGameState) -> [StyledLine] {
        var cmds = [
            "ATTACK",
            "EAT POTION (enemy strikes after)",
            "OBJECTIVES",
            "FLEE (optional fights)"
        ]
        switch state.playerClass {
        case .guardian:
            cmds.append("Guardian: block first hit, take −1 damage")
        case .hunter:
            cmds.append("Hunter: +3 first strike, +2 vs wounded foes")
        case .scout:
            cmds.append("Scout: +2 on first hit, can flee most fights")
        case .none:
            break
        }
        return cmds.map { .body($0) }
    }

    // MARK: - Flavor

    private static func playerMissLine(enemyName: String) -> String {
        [
            "Your blade cuts air — \(enemyName) slips the blow.",
            "You swing wide and \(enemyName) is already gone.",
            "A feint throws your timing off. Miss."
        ].randomElement()!
    }

    private static func enemyMissLine(enemyName: String) -> String {
        [
            "\(enemyName) lunges — you turn the blow aside.",
            "\(enemyName)'s strike glances off your guard.",
            "\(enemyName) overcommits and you dodge clear."
        ].randomElement()!
    }
}
