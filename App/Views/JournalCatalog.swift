import Foundation
import AvasiaEngine
import AvasiaSoCEngine
import AvasiaAnthologyEngine

enum JournalCatalog {
    static func entries(for product: AvasiaProduct, category: JournalCategory, kon: GameState?, soc: SoCGameState?) -> [JournalEntry] {
        guard category != .timeline else { return [] }
        switch product {
        case .kon:
            guard let kon else { return [] }
            return KonCodex.entries(for: category.kon).map { JournalEntry($0, state: kon) }
        case .soc:
            guard let soc else { return [] }
            return SoCCodex.entries(for: category.soc).map { JournalEntry($0, state: soc) }
        case .stories:
            return []
        }
    }

    static func unlockedCount(for product: AvasiaProduct, kon: GameState?, soc: SoCGameState?) -> Int {
        switch product {
        case .kon:
            guard let kon else { return 0 }
            return KonCodex.unlockedCount(for: kon)
        case .soc:
            guard let soc else { return 0 }
            return SoCCodex.unlockedCount(for: soc)
        case .stories:
            return 0
        }
    }

    static func totalCount(for product: AvasiaProduct) -> Int {
        switch product {
        case .kon: return KonCodexEntry.allCases.count
        case .soc: return SoCCodexEntry.allCases.count
        case .stories: return 0
        }
    }

    static func unlockedEntries(for product: AvasiaProduct, kon: GameState?, soc: SoCGameState?) -> [JournalEntry] {
        JournalCategory.allCases
            .filter { $0 != .timeline }
            .flatMap { entries(for: product, category: $0, kon: kon, soc: soc) }
            .filter(\.unlocked)
    }

    static func timelineEvents(
        for product: AvasiaProduct,
        kon: GameState?,
        soc: SoCGameState?,
        anthology: AnthologyGameState?
    ) -> [SagaTimelineEvent] {
        SagaTimelineCatalog.events(for: product, kon: kon, soc: soc, anthology: anthology)
    }
}

private extension JournalCategory {
    var kon: KonCodexCategory {
        switch self {
        case .character: return .character
        case .storyBeat: return .storyBeat
        case .timeline: return .storyBeat
        }
    }

    var soc: SoCCodexCategory {
        switch self {
        case .character: return .character
        case .storyBeat: return .storyBeat
        case .timeline: return .storyBeat
        }
    }
}

private extension JournalEntry {
    init(_ entry: KonCodexEntry, state: GameState) {
        id = entry.rawValue
        category = entry.category == .character ? .character : .storyBeat
        title = entry.title
        symbolName = entry.symbolName
        summary = entry.summary
        lockedHint = entry.lockedHint
        unlocked = KonCodex.isUnlocked(entry, state: state)
    }

    init(_ entry: SoCCodexEntry, state: SoCGameState) {
        id = entry.rawValue
        category = entry.category == .character ? .character : .storyBeat
        title = entry.title
        symbolName = entry.symbolName
        summary = entry.summary
        lockedHint = entry.lockedHint
        unlocked = SoCCodex.isUnlocked(entry, state: state)
    }
}
