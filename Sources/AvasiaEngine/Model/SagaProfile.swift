import Foundation

/// Cross-game, cross-run Chronicler progress. Persisted in `saga_profile.json`.
public struct SagaProfile: Codable, Sendable, Equatable {
    public static let ledgerCap = 500
    public static let maxDeathXPGrantsPerRun = 3
    public static let deathXPPerGrant = 3

    public var sagaXP: Int = 0
    public var runsStartedKon: Int = 0
    public var runsStartedSoc: Int = 0
    public var runsStartedStories: Int = 0
    public var completionsKon: Int = 0
    public var completionsSoc: Int = 0
    public var completionsStories: Int = 0
    public var lifetimeEvents: Set<String> = []
    public var achievementXPClaimed: Set<String> = []
    public var ledger: [SagaXPEntry] = []
    public var currentRunID: UUID?
    public var currentRunXP: Int = 0
    public var deathXPGrantsThisRun: Int = 0
    public var runEventKeys: Set<String> = []

    public init() {}

    public var chroniclerRank: Int { ChroniclerRank.rank(from: sagaXP) }
    public var chroniclerSubtitle: String { ChroniclerRank.subtitle(for: chroniclerRank) }

    public func runsStarted(for product: AvasiaProduct) -> Int {
        switch product {
        case .kon: return runsStartedKon
        case .soc: return runsStartedSoc
        case .stories: return runsStartedStories
        }
    }

    public func completions(for product: AvasiaProduct) -> Int {
        switch product {
        case .kon: return completionsKon
        case .soc: return completionsSoc
        case .stories: return completionsStories
        }
    }

    public mutating func incrementRunsStarted(_ product: AvasiaProduct) {
        switch product {
        case .kon: runsStartedKon += 1
        case .soc: runsStartedSoc += 1
        case .stories: runsStartedStories += 1
        }
    }

    public mutating func incrementCompletions(_ product: AvasiaProduct) {
        switch product {
        case .kon: completionsKon += 1
        case .soc: completionsSoc += 1
        case .stories: completionsStories += 1
        }
    }

    public func achievementClaimKey(_ achievement: Achievement) -> String {
        "kon.\(achievement.rawValue)"
    }

    public func canClaimAchievement(_ achievement: Achievement) -> Bool {
        !achievementXPClaimed.contains(achievementClaimKey(achievement))
    }

    public func xpTotal(for product: AvasiaProduct) -> Int {
        ledger.filter { $0.product == product }.reduce(0) { $0 + $1.amount }
    }

    public func ledgerEntries(forRun runID: UUID?) -> [SagaXPEntry] {
        guard let runID else { return [] }
        return ledger.filter { $0.runID == runID }
    }
}
