import Foundation

/// Saga-wide Chronicler Rank derived from lifetime `sagaXP`. See docs/META_PROGRESSION.md.
public enum ChroniclerRank {
    public static let xpDivisor = 100

    public static func rank(from sagaXP: Int) -> Int {
        guard sagaXP > 0 else { return 1 }
        return Int(floor(sqrt(Double(sagaXP) / Double(xpDivisor)))) + 1
    }

    public static func subtitle(for rank: Int) -> String {
        switch rank {
        case ...3: return "Stranger"
        case 4...6: return "Traveler"
        case 7...9: return "Witness"
        case 10...14: return "Chronicler"
        default: return "Keeper of the Pattern"
        }
    }

    /// Minimum sagaXP required to reach `rank` (rank 1 → 0).
    public static func xpThreshold(for rank: Int) -> Int {
        guard rank > 1 else { return 0 }
        let step = rank - 1
        return step * step * xpDivisor
    }

    public static func xpToNextRank(from sagaXP: Int) -> Int {
        let current = rank(from: sagaXP)
        return max(0, xpThreshold(for: current + 1) - sagaXP)
    }

    public static func progressToNextRank(from sagaXP: Int) -> Double {
        let current = rank(from: sagaXP)
        let floor = xpThreshold(for: current)
        let ceiling = xpThreshold(for: current + 1)
        guard ceiling > floor else { return 1 }
        return min(1, max(0, Double(sagaXP - floor) / Double(ceiling - floor)))
    }
}
