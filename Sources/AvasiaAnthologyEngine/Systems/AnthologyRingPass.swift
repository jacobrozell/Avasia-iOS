import Foundation
import AvasiaEngine

/// Ring Passes excuse one FP-gated story launch per pass (roadmap gold sink).
public enum AnthologyRingPass {
    public static let shopCost = 100
    public static let dailyGrantAmount = 1

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public static func todayKey() -> String {
        dayFormatter.string(from: Date())
    }

    /// Grants one pass the first time the hub is visited each calendar day.
    @discardableResult
    public static func refreshDailyGrant(state: inout AnthologyGameState) -> [StyledLine]? {
        guard state.storyZeroComplete else { return nil }
        let today = todayKey()
        guard state.ringPassLastGrantDay != today else { return nil }
        state.ringPassLastGrantDay = today
        state.ringPasses += dailyGrantAmount
        return [
            .body("Daily ring pass — +\(dailyGrantAmount). Excuses one FP story unlock.")
        ]
    }

    public static func canSpendForStory(_ story: AnthologyStoryID, state: AnthologyGameState) -> Bool {
        guard story != .storyZero else { return false }
        let meta = AnthologyCatalog.meta(for: story)
        guard meta.fpCost > 0, !state.completedStories.contains(story) else { return false }
        guard state.factionPoints < meta.fpCost else { return false }
        return state.ringPasses > 0
    }

    @discardableResult
    public static func purchase(state: inout AnthologyGameState) -> [StyledLine] {
        guard state.anthologyGold >= shopCost else {
            return [.body("Need \(shopCost) gold — you have \(state.anthologyGold).")]
        }
        state.anthologyGold -= shopCost
        state.ringPasses += 1
        return [
            .title("Ring Pass purchased"),
            .body("Passes held: \(state.ringPasses). Use one instead of FP when a story is locked by points."),
            .body("Gold remaining: \(state.anthologyGold)")
        ]
    }
}
