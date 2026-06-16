import Foundation

enum JournalCategory: String, CaseIterable, Identifiable {
    case character
    case storyBeat
    case timeline

    var id: String { rawValue }

    var title: String {
        switch self {
        case .character: return "Characters"
        case .storyBeat: return "Story"
        case .timeline: return "Timeline"
        }
    }
}

struct JournalEntry: Identifiable {
    let id: String
    let category: JournalCategory
    let title: String
    let symbolName: String
    let summary: String
    let lockedHint: String
    let unlocked: Bool
}
