import Foundation
import AvasiaEngine

/// Quest/combat XP and leveling — ported from `Avasia-SoC/Player/Player.py`.
public enum SoCQuestProgress {
    private static let thresholds: [Int: Int] = [
        2: 100, 3: 500, 4: 1500, 5: 5000, 6: 7500, 7: 10000, 8: 15000
    ]

    public static func grantQuestExp(_ amount: Int, state: inout SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = []
        if !state.questExpHintShown {
            state.questExpHintShown = true
            lines.append(.body("You can occasionally get bonus exp from hidden or uncommon choices."))
            lines.append(.body("The more uncommon, the more bonus experience."))
        }
        state.questExp += amount
        lines.append(.symbol("Quest experience +\(amount)"))
        lines.append(.body("You now have \(state.questExp) exp."))
        lines.append(contentsOf: applyLevelUps(state: &state))
        return lines
    }

    public static func grantCombatExp(state: inout SoCGameState) -> [StyledLine] {
        let amount = state.playerLevel <= 3 ? state.playerLevel * 50 : state.playerLevel * 100
        state.questExp += amount
        var lines: [StyledLine] = [
            .body("You gain \(amount) exp!"),
            .body("You now have \(state.questExp) exp.")
        ]
        lines.append(contentsOf: applyLevelUps(state: &state))
        return lines
    }

    public static func expToNextLevel(_ state: SoCGameState) -> Int? {
        thresholds[state.playerLevel + 1]
    }

    public static func applyLevelUps(state: inout SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = []
        while let needed = thresholds[state.playerLevel + 1], state.questExp >= needed {
            state.playerLevel += 1
            state.playerAtk += 1
            state.playerSpeed += 1
            state.playerMaxHp += 1
            state.playerLuck += 1
            state.playerHp = state.playerMaxHp
            lines.append(.title("Level Up!"))
            lines.append(.body("You are now level \(state.playerLevel)!"))
            lines.append(.body("Attack, speed, health, and luck increased."))
        }
        return lines
    }

    public static func levelSummary(_ state: SoCGameState) -> String {
        if let next = expToNextLevel(state) {
            return "Level \(state.playerLevel) · \(state.questExp)/\(next) exp"
        }
        return "Level \(state.playerLevel) · \(state.questExp) exp (max)"
    }
}
