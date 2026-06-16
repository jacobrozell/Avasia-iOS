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

    /// Stories on an alignment path that ship in the current release (1.0.0 slice).
    public static func launchStories(for alignment: AnthologyAlignment) -> [AnthologyStoryID] {
        stories(for: alignment).filter { AnthologyRelease.isStoryAvailable(AnthologyCatalog.meta(for: $0)) }
    }

    public static func isLaunchSliceComplete(state: AnthologyGameState) -> Bool {
        guard state.alignment != .none else { return false }
        let launch = launchStories(for: state.alignment)
        guard !launch.isEmpty else { return false }
        return launch.allSatisfy { state.completedStories.contains($0) }
    }

    public static func progressLabel(state: AnthologyGameState) -> String? {
        nil
    }
}
