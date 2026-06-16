import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyPathProgressTests: XCTestCase {
    func testLoyalistPathCountsSixStories() {
        XCTAssertEqual(AnthologyPathProgress.totalCount(for: .loyalist), 6)
    }

    func testProgressLabelWhenIncomplete() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.alignment = .loyalist
        state.completedStories = [.goodOne, .goodTwo]
        XCTAssertEqual(
            AnthologyPathProgress.progressLabel(state: state),
            "Loyalist path — 2/6 stories"
        )
    }

    func testPathCompleteLabel() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.alignment = .agroman
        state.completedStories = Set(AnthologyPathProgress.stories(for: .agroman))
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.agroman, state: state))
        XCTAssertEqual(
            AnthologyPathProgress.progressLabel(state: state),
            "Agroman path — complete (6/6)"
        )
    }
}
