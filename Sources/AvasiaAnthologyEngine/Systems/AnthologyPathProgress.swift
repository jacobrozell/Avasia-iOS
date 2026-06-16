import Foundation
import AvasiaEngine

public enum AnthologyPathProgress {
    public static func stories(for alignment: AnthologyAlignment) -> [AnthologyStoryID] {
        switch alignment {
        case .loyalist:
            return [.goodOne, .goodTwo, .goodThree, .goodFour, .goodFive, .goodSix]
        case .agroman:
            return [.badOne, .badTwo, .badThree, .badFour, .badFive, .badSix]
        case .neutral:
            return [.elkFeast, .caveRecord, .neutralThree, .neutralFour, .neutralFive, .neutralSix]
        case .none:
            return []
        }
    }

    public static func completedCount(state: AnthologyGameState) -> Int {
        guard state.alignment != .none else { return 0 }
        return stories(for: state.alignment).filter { state.completedStories.contains($0) }.count
    }

    public static func totalCount(for alignment: AnthologyAlignment) -> Int {
        stories(for: alignment).count
    }

    public static func isPathComplete(_ alignment: AnthologyAlignment, state: AnthologyGameState) -> Bool {
        stories(for: alignment).allSatisfy { state.completedStories.contains($0) }
    }

    public static func isActivePathComplete(state: AnthologyGameState) -> Bool {
        guard state.alignment != .none else { return false }
        return isPathComplete(state.alignment, state: state)
    }

    public static func progressLabel(state: AnthologyGameState) -> String? {
        guard state.alignment != .none, state.storyZeroComplete else { return nil }
        let done = completedCount(state: state)
        let total = totalCount(for: state.alignment)
        if isActivePathComplete(state: state) {
            return "\(state.alignment.rawValue.capitalized) path — complete (\(total)/\(total))"
        }
        return "\(state.alignment.rawValue.capitalized) path — \(done)/\(total) stories"
    }
}
