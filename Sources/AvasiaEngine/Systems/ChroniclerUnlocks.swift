import Foundation

/// Rank-gated content (anthology tiers, Paladin, lives). All gates pass in 1.0.0.
public enum ChroniclerGate: String, Sendable {
    case anthologyScout
    case anthologyTier1
    case anthologyTier2
    case anthologyTier3
    case paladinClass
    case veteranProse
    case extraLifeTier2
}

public enum ChroniclerUnlocks {
    /// Minimum Chronicler Rank for each gate (used post-1.0).
    public static let rankRequirements: [ChroniclerGate: Int] = [
        .anthologyScout: 3,
        .anthologyTier1: 5,
        .anthologyTier2: 8,
        .anthologyTier3: 11,
        .paladinClass: 10,
        .veteranProse: 7,
        .extraLifeTier2: 5,
    ]

    /// 1.0.0: every gate is open. Flip to rank checks in a later release.
    public static let gatesEnabled = false

    public static func isUnlocked(_ gate: ChroniclerGate, profile: SagaProfile) -> Bool {
        guard gatesEnabled, let required = rankRequirements[gate] else { return true }
        return profile.chroniclerRank >= required
    }
}
