import Foundation
import AvasiaEngine

/// Lightweight arena combat for anthology training mode.
enum AnthologyArenaCombat {
    struct Wave {
        let name: String
        let hp: Int
        let atk: Int
    }

    static let waves: [Wave] = [
        Wave(name: "Road Bandit", hp: 10, atk: 3),
        Wave(name: "Agroman Scout", hp: 14, atk: 5),
        Wave(name: "Paladin Trainee", hp: 20, atk: 6)
    ]

    static func beginWave(_ wave: Int, state: inout AnthologyGameState) {
        let enemy = waves[wave - 1]
        state.arenaInCombat = true
        state.arenaEnemyName = enemy.name
        state.arenaEnemyHp = enemy.hp
        state.arenaEnemyAtk = enemy.atk
    }

    static func statLines(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .body("You: \(state.arenaHp) HP"),
            .body("\(state.arenaEnemyName): \(state.arenaEnemyHp) HP")
        ]
    }

    static func handleAttack(_ state: inout AnthologyGameState) -> [StyledLine] {
        guard state.arenaInCombat else { return [.hint("ATTACK when a foe stands before you.")] }

        var lines: [StyledLine] = []
        let playerHit = Int.random(in: state.arenaPlayerDamageRange)
        state.arenaEnemyHp = max(0, state.arenaEnemyHp - playerHit)
        lines.append(.body("You strike for \(playerHit) damage."))

        if state.arenaEnemyHp <= 0 {
            state.arenaInCombat = false
            lines.append(.body("\(state.arenaEnemyName) falls."))
            return lines
        }

        let enemyHit = state.arenaMitigatedEnemyDamage(state.arenaEnemyAtk)
        state.arenaHp = max(0, state.arenaHp - enemyHit)
        lines.append(.body("\(state.arenaEnemyName) hits you for \(enemyHit)."))
        if state.arenaHp <= 0 {
            lines.append(.death("You collapse in the training pit."))
        }
        return lines
    }
}

struct AnthologyArenaPitRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .arenaPit

    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]? {
        guard state.arenaRunActive, !state.arenaInCombat, state.arenaWave > 0 else { return nil }
        if state.arenaWave <= AnthologyArenaCombat.waves.count {
            AnthologyArenaCombat.beginWave(state.arenaWave, state: &state)
        }
        return nil
    }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.arenaInCombat {
            return AnthologyArenaCombat.statLines(state) + [.hint("ATTACK.")]
        }
        if !state.arenaRunActive {
            return [
                .title("Training Arena"),
                .body("Sand pit. Wooden dummies stacked for burning."),
                .hint("Return to the story hub from the menu.")
            ]
        }
        if state.arenaWave > AnthologyArenaCombat.waves.count {
            return [.hint("CONTINUE — claim your reward.")]
        }
        return [
            .title("Wave \(state.arenaWave)"),
            .body("The next opponent enters the ring."),
            .hint("CONTINUE to begin.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.arenaInCombat {
            guard input.contains("ATTACK") || input.contains("FIGHT") || input.contains("STRIKE") else {
                return AnthologyTurnResult([.hint("ATTACK.")])
            }
            var lines = AnthologyArenaCombat.handleAttack(&state)
            lines.append(contentsOf: AnthologyArenaCombat.statLines(state))

            if state.arenaHp <= 0 {
                let partialGold = max(0, (state.arenaWave - 1) * 25)
                state.anthologyGold += partialGold
                state.resetArenaRun()
                lines.append(.body("You earned \(partialGold) training gold."))
                return AnthologyTurnResult(lines, .move(.storyHub))
            }

            guard state.arenaInCombat else {
                if state.arenaWave >= AnthologyArenaCombat.waves.count {
                    state.arenaWave += 1
                    return AnthologyTurnResult(lines + [.hint("CONTINUE to finish.")])
                }
                state.arenaWave += 1
                state.arenaHp = state.arenaMaxHp
                lines.append(.body("Wave cleared. Catch your breath."))
                lines.append(.hint("CONTINUE for the next foe."))
                return AnthologyTurnResult(lines)
            }
            return AnthologyTurnResult(lines)
        }

        if state.arenaWave > AnthologyArenaCombat.waves.count {
            guard input.contains("CONTINUE") else {
                return AnthologyTurnResult([.hint("CONTINUE.")])
            }
            return finishRun(&state)
        }

        if input.contains("CONTINUE") {
            AnthologyArenaCombat.beginWave(state.arenaWave, state: &state)
            var lines = AnthologyArenaCombat.statLines(state)
            lines.append(.hint("ATTACK."))
            return AnthologyTurnResult(lines)
        }

        return AnthologyTurnResult([.hint("CONTINUE or ATTACK.")])
    }

    private func finishRun(_ state: inout AnthologyGameState) -> AnthologyTurnResult {
        let gold = AnthologyCatalog.arenaGoldReward
        state.anthologyGold += gold
        var lines: [StyledLine] = [
            .title("Arena cleared"),
            .body("+\(gold) training gold.")
        ]
        if !state.arenaFirstClearDone {
            state.arenaFirstClearDone = true
            state.factionPoints += AnthologyCatalog.arenaFirstClearFP
            lines.append(.body("+\(AnthologyCatalog.arenaFirstClearFP) FP — first clear bonus."))
        }
        state.resetArenaRun()
        lines.append(.blank)
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
