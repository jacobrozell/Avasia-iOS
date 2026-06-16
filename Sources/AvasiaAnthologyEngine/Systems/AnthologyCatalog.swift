import Foundation
import AvasiaEngine

public struct AnthologyStoryMeta: Sendable {
    public let id: AnthologyStoryID
    public let title: String
    public let subtitle: String
    public let systemImage: String
    public let fpCost: Int
    public let fpReward: Int
    public let requiredAlignment: AnthologyAlignment?
    public let requiresPrior: AnthologyStoryID?

    public init(
        id: AnthologyStoryID,
        title: String,
        subtitle: String,
        systemImage: String,
        fpCost: Int,
        fpReward: Int,
        requiredAlignment: AnthologyAlignment? = nil,
        requiresPrior: AnthologyStoryID? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.fpCost = fpCost
        self.fpReward = fpReward
        self.requiredAlignment = requiredAlignment
        self.requiresPrior = requiresPrior
    }
}

public enum AnthologyCatalog {
    public static let all: [AnthologyStoryMeta] = [
        AnthologyStoryMeta(
            id: .storyZero,
            title: "Scout Patrol",
            subtitle: "Observe the valley. Choose your allegiance.",
            systemImage: "binoculars.fill",
            fpCost: 0,
            fpReward: 500
        ),
        AnthologyStoryMeta(
            id: .goodOne,
            title: "The Oceandale Warning",
            subtitle: "Warn the fishing colony before the ships land.",
            systemImage: "water.waves",
            fpCost: 500,
            fpReward: 500,
            requiredAlignment: .loyalist
        ),
        AnthologyStoryMeta(
            id: .goodTwo,
            title: "Nascastrum Courier",
            subtitle: "Carry Oceandale's truth to the floating city.",
            systemImage: "envelope.fill",
            fpCost: 1_000,
            fpReward: 1_000,
            requiredAlignment: .loyalist,
            requiresPrior: .goodOne
        ),
        AnthologyStoryMeta(
            id: .badOne,
            title: "Walking with Vashirr",
            subtitle: "March west. Learn Many Hands from the inside.",
            systemImage: "figure.walk",
            fpCost: 500,
            fpReward: 500,
            requiredAlignment: .agroman
        ),
        AnthologyStoryMeta(
            id: .badTwo,
            title: "Cataracta Periphery",
            subtitle: "Watch the druid city from the hills.",
            systemImage: "eye.fill",
            fpCost: 1_000,
            fpReward: 1_000,
            requiredAlignment: .agroman,
            requiresPrior: .badOne
        ),
        AnthologyStoryMeta(
            id: .elkFeast,
            title: "The Elk Feast",
            subtitle: "One night without banners.",
            systemImage: "flame.fill",
            fpCost: 250,
            fpReward: 250,
            requiredAlignment: .neutral
        ),
        AnthologyStoryMeta(
            id: .caveRecord,
            title: "The Cave Record",
            subtitle: "Old prison graffiti and a scholar's hidden archive.",
            systemImage: "archivebox.fill",
            fpCost: 500,
            fpReward: 500,
            requiredAlignment: .neutral,
            requiresPrior: .elkFeast
        ),
        AnthologyStoryMeta(
            id: .goodThree,
            title: "Council Under Glass",
            subtitle: "Testify before Kaefden's floating court.",
            systemImage: "building.columns.fill",
            fpCost: 2_500,
            fpReward: 2_500,
            requiredAlignment: .loyalist,
            requiresPrior: .goodTwo
        ),
        AnthologyStoryMeta(
            id: .badThree,
            title: "Many Hands Oath",
            subtitle: "Swear with Vashirr's Paladins — or refuse the bind.",
            systemImage: "hand.raised.fill",
            fpCost: 2_500,
            fpReward: 2_500,
            requiredAlignment: .agroman,
            requiresPrior: .badTwo
        ),
        AnthologyStoryMeta(
            id: .neutralThree,
            title: "Two Hands Market",
            subtitle: "Broker a truce — or sell the cave record to one side.",
            systemImage: "cart.fill",
            fpCost: 2_500,
            fpReward: 2_500,
            requiredAlignment: .neutral,
            requiresPrior: .caveRecord
        ),
        AnthologyStoryMeta(
            id: .goodFour,
            title: "Restoration Mobilization",
            subtitle: "Hold the Oceandale line — or push before Paladins swell.",
            systemImage: "shield.lefthalf.filled",
            fpCost: 5_000,
            fpReward: 5_000,
            requiredAlignment: .loyalist,
            requiresPrior: .goodThree
        ),
        AnthologyStoryMeta(
            id: .badFour,
            title: "Cataracta Breach",
            subtitle: "Burn the garden gate — or storm it with discipline.",
            systemImage: "flame.fill",
            fpCost: 5_000,
            fpReward: 5_000,
            requiredAlignment: .agroman,
            requiresPrior: .badThree
        ),
        AnthologyStoryMeta(
            id: .neutralFour,
            title: "Cellious at the Gate",
            subtitle: "Witness Kaefden's deserter count — or walk away.",
            systemImage: "doc.text.fill",
            fpCost: 5_000,
            fpReward: 5_000,
            requiredAlignment: .neutral,
            requiresPrior: .neutralThree
        )
    ]

    public static let shopTitle = "Training Shop"
    public static let shopSubtitle = "Arena gear and ring passes."
    public static let ringPassCost = AnthologyRingPass.shopCost

    public static let arenaTitle = "Training Arena"
    public static let arenaSubtitle = "Three waves. Earn gold — no story spoilers."
    public static let arenaGoldReward = 75
    public static let arenaFirstClearFP = 25

    public static func meta(for id: AnthologyStoryID) -> AnthologyStoryMeta {
        all.first { $0.id == id }!
    }

    public static func canPlay(_ story: AnthologyStoryID, state: AnthologyGameState) -> (allowed: Bool, reason: String?) {
        let meta = meta(for: story)
        if state.completedStories.contains(story) {
            return (true, nil)
        }
        if story != .storyZero, !state.storyZeroComplete {
            return (false, "Finish Scout Patrol first.")
        }
        if let prior = meta.requiresPrior, !state.completedStories.contains(prior) {
            return (false, "Finish \(Self.meta(for: prior).title) first.")
        }
        if let required = meta.requiredAlignment, state.alignment != required {
            let label = required == .loyalist ? "REPORT" : (required == .agroman ? "FOLLOW" : "REFUSE")
            return (false, "Requires \(required.rawValue) path (\(label) in Scout Patrol).")
        }
        if meta.fpCost > 0, state.factionPoints < meta.fpCost {
            if AnthologyRingPass.canSpendForStory(story, state: state) {
                return (true, nil)
            }
            return (false, "Need \(meta.fpCost) FP — you have \(state.factionPoints).")
        }
        return (true, nil)
    }

    public static func spendAndStart(_ story: AnthologyStoryID, state: inout AnthologyGameState) {
        let meta = meta(for: story)
        if meta.fpCost > 0, !state.completedStories.contains(story) {
            if state.factionPoints >= meta.fpCost {
                state.factionPoints -= meta.fpCost
            } else if AnthologyRingPass.canSpendForStory(story, state: state) {
                state.ringPasses -= 1
            }
        }
        state.currentStory = story
        state.resetActiveStoryProgress()
    }

    public static func complete(_ story: AnthologyStoryID, state: inout AnthologyGameState) {
        let meta = meta(for: story)
        state.completedStories.insert(story)
        if !state.storiesRewarded.contains(story) {
            state.factionPoints += meta.fpReward
            state.storiesRewarded.insert(story)
        }
        switch story {
        case .storyZero: state.storyZeroComplete = true
        case .goodOne: state.goodOneComplete = true
        case .goodTwo: state.goodTwoComplete = true
        case .badOne: state.badOneComplete = true
        case .badTwo: state.badTwoComplete = true
        case .elkFeast: state.elkFeastComplete = true
        case .caveRecord: state.caveRecordComplete = true
        case .goodThree: state.goodThreeComplete = true
        case .badThree: state.badThreeComplete = true
        case .neutralThree: state.neutralThreeComplete = true
        case .goodFour: state.goodFourComplete = true
        case .badFour: state.badFourComplete = true
        case .neutralFour: state.neutralFourComplete = true
        }
        state.currentStory = nil
        state.clearInProgressStoryFlags()
    }

    public static func hubLines(state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Story Adventures"),
            .body("Faction points: \(state.factionPoints)"),
            .body("Alignment: \(alignmentLabel(state.alignment))")
        ]
        if state.anthologyGold > 0 {
            lines.append(.body("Training gold: \(state.anthologyGold)"))
        }
        if state.ringPasses > 0 {
            lines.append(.body("Ring passes: \(state.ringPasses) — excuse one FP unlock each."))
        }
        if state.storyZeroComplete {
            lines.append(.body("Choose Story — Training Arena — or the Training Shop."))
        }
        lines.append(.blank)
        lines.append(.hint("Choose Story · Arena · Shop · LIST · PLAY <name>"))
        return lines
    }

    public static func listLines(state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [.title("Available Stories"), .blank]
        for meta in all {
            let (allowed, reason) = canPlay(meta.id, state: state)
            let done = state.completedStories.contains(meta.id)
            let cost = meta.fpCost == 0 ? "free" : "\(meta.fpCost) FP"
            let status = done ? " ✓" : (allowed ? "" : " (locked)")
            lines.append(.body("\(meta.title) — \(cost)\(status)"))
            if let reason, !allowed, !done {
                lines.append(.hint("  \(reason)"))
            }
        }
        lines.append(.blank)
        lines.append(.hint("Use Choose Story or PLAY commands from the hub."))
        return lines
    }

    private static func alignmentLabel(_ alignment: AnthologyAlignment) -> String {
        switch alignment {
        case .none: return "unset — finish Scout Patrol"
        case .loyalist: return "loyalist"
        case .agroman: return "agroman"
        case .neutral: return "neutral"
        }
    }
}
