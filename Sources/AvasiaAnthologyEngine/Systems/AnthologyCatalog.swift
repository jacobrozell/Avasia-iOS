import Foundation
import AvasiaEngine

public struct AnthologyStoryMeta: Sendable {
    public let id: AnthologyStoryID
    public let title: String
    public let subtitle: String
    /// Longer pitch for the story picker — arc, stakes, and fork without spoiling endings.
    public let synopsis: String
    public let systemImage: String
    public let fpCost: Int
    public let fpReward: Int
    public let requiredAlignment: AnthologyAlignment?
    public let requiresPrior: AnthologyStoryID?
    /// Lean 1.0.0 ship set — Scout + tier 1 + hub utilities only.
    public let shipsIn100: Bool

    public init(
        id: AnthologyStoryID,
        title: String,
        subtitle: String,
        synopsis: String,
        systemImage: String,
        fpCost: Int,
        fpReward: Int,
        requiredAlignment: AnthologyAlignment? = nil,
        requiresPrior: AnthologyStoryID? = nil,
        shipsIn100: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.synopsis = synopsis
        self.systemImage = systemImage
        self.fpCost = fpCost
        self.fpReward = fpReward
        self.requiredAlignment = requiredAlignment
        self.requiresPrior = requiresPrior
        self.shipsIn100 = shipsIn100
    }
}

public enum AnthologyCatalog {
    public static let all: [AnthologyStoryMeta] = [
        AnthologyStoryMeta(
            id: .storyZero,
            title: "Scout Patrol",
            subtitle: "Observe the valley. Choose your allegiance.",
            synopsis: "You and Mira count Agroman fires from the ridge — hundreds of campfires, Many Hands banners, Paladin drills in the valley below. Vashirr finds you anyway. Report to Silvarium, follow west, or refuse both sermons.",
            systemImage: "binoculars.fill",
            fpCost: 0,
            fpReward: 500,
            shipsIn100: true
        ),
        AnthologyStoryMeta(
            id: .goodOne,
            title: "The Oceandale Warning",
            subtitle: "Warn the fishing colony before the ships land.",
            synopsis: "Elder Venna seals your ridge report and sends you down the coastal road. Oceandale still mends nets while Agroman sails sit on the horizon. Evacuate the pier or hold the church — you have minutes, not hours.",
            systemImage: "water.waves",
            fpCost: 500,
            fpReward: 500,
            requiredAlignment: .loyalist,
            shipsIn100: true
        ),
        AnthologyStoryMeta(
            id: .goodTwo,
            title: "Nascastrum Courier",
            subtitle: "Carry Oceandale's truth to the floating city.",
            synopsis: "Smoke still stains your report when Elder Venna presses a wax seal into your palm. Refugees pass you on the Western Road while Nacastrum rebuilds in blue crystal. Thekia waits at the gate — tell her everything, or trim the truth for the court.",
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
            synopsis: "Shared rations and pamphlets in every kit. A farmhand learns to spark his gauntlet while Sergeant Dentros barks corrections. Vashirr asks whether mages should gatekeep — then sends you to map Silvarium outposts. Truth or mercy on the charcoal.",
            systemImage: "figure.walk",
            fpCost: 500,
            fpReward: 500,
            requiredAlignment: .agroman,
            shipsIn100: true
        ),
        AnthologyStoryMeta(
            id: .badTwo,
            title: "Cataracta Periphery",
            subtitle: "Watch the druid city from the hills.",
            synopsis: "Cataracta sits peaceful in its mountain bowl — Wolf, Bear, and Fox recruits choose names before they choose war. Vashirr wants every gate marked for the night the portals open. Give him the perfect map, or smuggle a warning toward the garden paths.",
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
            synopsis: "Cook-smoke and an elk horn call — no war banners near Splitpath. Elder Suformin offers truce-week hospitality: leave your sword at the gate, hear the schism fable told as warning not recruitment, and remember what the valley was before sermons split it.",
            systemImage: "flame.fill",
            fpCost: 250,
            fpReward: 250,
            requiredAlignment: .neutral,
            shipsIn100: true
        ),
        AnthologyStoryMeta(
            id: .caveRecord,
            title: "The Cave Record",
            subtitle: "Old prison graffiti and a scholar's hidden archive.",
            synopsis: "Suformin sends you up the KoN ridge to prison caves repurposed before Inflame was hidden below. Manacle rings, schism graffiti, and a neutral archivist's bark sheets — trials the court burned. Copy the archive for Silvarium or leave it where war cannot reach yet.",
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
            synopsis: "Thekia recalls you to Nacastrum's spell-glass dome. Ministers want Oceandale filed under tragedy, not accusation — Paladins with cousins in Kaefden, ministers who traded with Agromans last year. Petition for public testimony or let Thekia negotiate without burning every bridge.",
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
            synopsis: "Ash marks every brow in the rite ring — the same mark Vashirr wore at the ridge parley. Many Hands, one will, no private mercy. Swear the western oath and share breath with Paladins, or refuse binding and remain eyes only, never fist.",
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
            synopsis: "Splitpath market day — Sylvian honey beside Agroman iron. Both factions think your cave memory belongs to them. A neutral broker folds her hands like the graffiti: same beat as Nacastrum's court and Vashirr's ring, different costume. Broker a shared witness list or lean toward one buyer.",
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
            synopsis: "Sylvian militia dig in where fishers once mended nets. Thekia says the court heard you — or enough. Hold the pier line and evacuate more coast, or push now and hit the Agroman camp before Many Hands swells the valley.",
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
            synopsis: "Your map folds in a sergeant's kit — every weak hinge you marked or softened. Paladins test gauntlets while Cataracta's courtyard still hosts enlistment drills. Vashirr offers the gate: torches and terror in one night, or a measured breach that leaves fewer martyrs for their songs.",
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
            synopsis: "Restoration guards search wagons at the mainland gate. Cellious reads deserter names from a ledger without looking up — farmhands, fishers, a Paladin trainee who threw his gauntlet in the mud. Witness the count with neutral ink, or vanish before your name joins the list.",
            systemImage: "doc.text.fill",
            fpCost: 5_000,
            fpReward: 5_000,
            requiredAlignment: .neutral,
            requiresPrior: .neutralThree
        ),
        AnthologyStoryMeta(
            id: .goodFive,
            title: "Witness Stone",
            subtitle: "Carve your ridge truth into Sylvarium's living bark.",
            synopsis: "War reached the Great Tree at last. Elder Venna brings you to the witness stone — names of scouts and fishers who told truth when banners demanded lies. Swear your ridge report into living bark, or refuse permanent mark and serve Sylva as witness only.",
            systemImage: "leaf.fill",
            fpCost: 10_000,
            fpReward: 10_000,
            requiredAlignment: .loyalist,
            requiresPrior: .goodFour
        ),
        AnthologyStoryMeta(
            id: .badFive,
            title: "Western Command",
            subtitle: "Accept Vashirr's field seal — or stay scout.",
            synopsis: "Cataracta's breach smoke still stains the horizon. Vashirr offers a field seal — authority to order strikes without his voice. Accept western command and become Agroman's fist, or decline and stay the scout who walks between fires.",
            systemImage: "star.circle.fill",
            fpCost: 10_000,
            fpReward: 10_000,
            requiredAlignment: .agroman,
            requiresPrior: .badFour
        ),
        AnthologyStoryMeta(
            id: .neutralFive,
            title: "The Unmarked Road",
            subtitle: "Leave the war — or stay Splitpath's broker.",
            synopsis: "War maps redrawn again. Three roads from Splitpath: north to Sylva, west to Agroma, east toward the coast and away from both. Suformin meets you at the mile marker — walk until banners blur, or stay and keep the market honest.",
            systemImage: "signpost.right.fill",
            fpCost: 10_000,
            fpReward: 10_000,
            requiredAlignment: .neutral,
            requiresPrior: .neutralFour
        ),
        AnthologyStoryMeta(
            id: .goodSix,
            title: "The Restoration Accord",
            subtitle: "Sign the Sylvian–Kaefden pact — or walk away.",
            synopsis: "Nacastrum ministers and Sylvian elders share a table for the first time since Oceandale burned. Two copies of the pact — one for floating court, one for bark-archive. Sign as Sylvian witness and bind Restoration to Sylva, or walk and let honest pause beat a lying treaty.",
            systemImage: "signature",
            fpCost: 17_500,
            fpReward: 17_500,
            requiredAlignment: .loyalist,
            requiresPrior: .goodFive
        ),
        AnthologyStoryMeta(
            id: .badSix,
            title: "Western Throne",
            subtitle: "Rule occupied Cataracta — or yield the seat.",
            synopsis: "Agroman banners hang where druid sigils once grew. Officers want a governor's desk before Restoration counterattacks — not Vashirr's sermon, a face the city can fear. Take the western seat in occupied Cataracta, or yield the throne and keep the westward road.",
            systemImage: "crown.fill",
            fpCost: 17_500,
            fpReward: 17_500,
            requiredAlignment: .agroman,
            requiresPrior: .badFive
        ),
        AnthologyStoryMeta(
            id: .neutralSix,
            title: "The Open Ledger",
            subtitle: "Publish the neutral archive — or seal it.",
            synopsis: "Suformin and Cellious share a table — cave copies, gate ledgers, market truce maps. One open ledger every faction will hate equally. Publish and let truth travel without a banner, or seal the archive until the world can bear it.",
            systemImage: "book.closed.fill",
            fpCost: 17_500,
            fpReward: 17_500,
            requiredAlignment: .neutral,
            requiresPrior: .neutralFive
        )
    ]

    /// Stories included in lean 1.0.0 ship — Scout, tier 1 forks, hub utilities.
    public static let shipsIn100: [AnthologyStoryMeta] = all.filter(\.shipsIn100)

    public struct PickerSection: Sendable {
        public let title: String
        public let systemImage: String
        public let stories: [AnthologyStoryMeta]
    }

    /// Story picker grouping — Scout, then each alignment path (current release only).
    public static let pickerSections: [PickerSection] = {
        let scout = PickerSection(
            title: "Scout Patrol",
            systemImage: "binoculars.fill",
            stories: [meta(for: .storyZero)]
        )
        let paths: [(String, String, AnthologyAlignment)] = [
            ("Loyalist Path", "shield.lefthalf.filled", .loyalist),
            ("Agroman Path", "figure.walk", .agroman),
            ("Neutral Path", "signpost.right.fill", .neutral)
        ]
        let sections = paths.map { title, icon, alignment in
            PickerSection(
                title: title,
                systemImage: icon,
                stories: AnthologyPathProgress.stories(for: alignment)
                    .filter { AnthologyRelease.isStoryAvailable(meta(for: $0)) }
                    .map { meta(for: $0) }
            )
        }
        return [scout] + sections
    }()

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
        if !AnthologyRelease.isStoryAvailable(meta), !state.completedStories.contains(story) {
            return (false, "That story isn't available yet.")
        }
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
        case .goodFive: state.goodFiveComplete = true
        case .badFive: state.badFiveComplete = true
        case .neutralFive: state.neutralFiveComplete = true
        case .goodSix: state.goodSixComplete = true
        case .badSix: state.badSixComplete = true
        case .neutralSix: state.neutralSixComplete = true
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
        if state.storyZeroComplete, !AnthologyRelease.shipsFullAnthology {
            if AnthologyPathProgress.isLaunchSliceComplete(state: state) {
                lines.append(.body("Your first chapter is complete. Replay from Choose Story, or train in the arena."))
                lines.append(.body("More Story Adventures are on the way."))
            } else {
                lines.append(.body("Choose Story — Training Arena — or the Training Shop."))
                lines.append(.body("More Story Adventures arrive in future updates."))
            }
        } else if state.storyZeroComplete {
            lines.append(.body("Choose Story — Training Arena — or the Training Shop. Each path runs six stories from fork to finale."))
        }
        if AnthologyPathProgress.isActivePathComplete(state: state) {
            lines.append(.body("Your alignment path is complete. Replay any story from Choose Story."))
        }
        lines.append(.blank)
        lines.append(.hint("Choose Story · Arena · Shop · LIST · PLAY <name>"))
        return lines
    }

    public static func listLines(state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [.title("Available Stories"), .blank]
        let catalog = AnthologyRelease.shipsFullAnthology ? all : shipsIn100
        for meta in catalog {
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

    /// Lines when the player finishes the current-release slice for their alignment path.
    public static func launchSliceCompletionLines(state: AnthologyGameState) -> [StyledLine] {
        guard AnthologyPathProgress.isLaunchSliceComplete(state: state) else { return [] }
        return [
            .blank,
            .body("More Story Adventures are on the way. Replay this chapter, train in the arena, or try another alignment from Scout Patrol.")
        ]
    }

    /// Celebration lines when the final story in an alignment path is completed.
    public static func pathCompletionLines(state: AnthologyGameState) -> [StyledLine] {
        guard AnthologyPathProgress.isActivePathComplete(state: state) else { return [] }
        let name = state.alignment.rawValue.capitalized
        return [
            .blank,
            .title("\(name) path complete"),
            .body("Six stories from fork to finale. Scout Patrol set your allegiance — you walked it to the end."),
            .body("Replay any story from the hub. Arena and shop stay open.")
        ]
    }
}
