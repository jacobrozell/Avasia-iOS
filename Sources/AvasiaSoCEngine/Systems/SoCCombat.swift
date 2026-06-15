import Foundation
import AvasiaEngine

enum SoCCombat {
    static func begin(enemy: SoCCombatant, deathText: String, state: inout SoCGameState) {
        state.inCombat = true
        state.enemy = enemy
        state.enemyDeathText = deathText
    }

    static func end(state: inout SoCGameState) {
        state.inCombat = false
        state.enemy = nil
        state.enemyDeathText = ""
    }

    /// One player command during combat (matches one loop iteration in Python `Combat.start_combat`).
    static func handle(_ input: ParsedInput, state: inout SoCGameState) -> (lines: [StyledLine], died: Bool) {
        guard state.inCombat, var enemy = state.enemy else {
            return ([.hint("You are not in combat.")], false)
        }

        if input.contains("HELP") || input.contains("COMMANDS") {
            return ([.body("ATTACK"), .body("HEAL"), .body("HELP")], false)
        }

        let attack = ["ATTACK", "STRIKE", "FIGHT"]
        guard attack.contains(where: { input.contains($0) }) else {
            return ([.hint("What do will you do? ATTACK to fight.")], false)
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
            return (lines, true)
        }

        if enemy.isDead {
            lines.append(.body("You killed \(enemy.name)!"))
            lines.append(contentsOf: SoCQuestProgress.grantCombatExp(state: &state))
            end(state: &state)
        }

        return (lines, false)
    }

    private static func playerAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        if state.playerLuckBeatsRoll() {
            enemy.hp -= state.playerAtk
            return [
                .body("You attack \(enemy.name)!"),
                .body("You deal \(state.playerAtk) damage!")
            ]
        }
        return [.body("You miss!")]
    }

    private static func enemyAttack(state: inout SoCGameState, enemy: inout SoCCombatant) -> [StyledLine] {
        if state.enemyLuckBeatsRoll() {
            state.playerHp -= enemy.atk
            return [
                .body("\(enemy.name) attacks you!"),
                .body("You take \(enemy.atk) damage!")
            ]
        }
        return [.body("\(enemy.name) misses!")]
    }

    static func statLines(state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = []
        if let enemy = state.enemy {
            lines.append(.body("\(enemy.name):\n\t HEALTH: \(enemy.hp)\n\t ATTACK: \(enemy.atk)\n\t SPEED: \(enemy.speed)"))
        }
        lines.append(.body("\(state.playerName.isEmpty ? "You" : state.playerName):\n\t HEALTH: \(state.playerHp)\n\t ATTACK: \(state.playerAtk)\n\t SPEED: \(state.playerSpeed)\n\t CLASS: \(state.playerClass.rawValue)"))
        return lines
    }
}
