import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyPathProgressTests: XCTestCase {
    func testLoyalistPathCountsSixStories() {
        XCTAssertEqual(AnthologyPathProgress.totalCount(for: .loyalist), 6)
    }

    func testProgressLabelHiddenForLeanRelease() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.alignment = .loyalist
        state.completedStories = [.goodOne, .goodTwo]
        XCTAssertNil(AnthologyPathProgress.progressLabel(state: state))
    }

    func testLaunchStoriesInLeanRelease() {
        XCTAssertEqual(AnthologyPathProgress.launchStories(for: .loyalist), [.goodOne])
        XCTAssertEqual(AnthologyPathProgress.launchStories(for: .neutral), [.elkFeast])
    }

    func testPathCompleteLabel() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.alignment = .agroman
        state.completedStories = Set(AnthologyPathProgress.stories(for: .agroman))
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.agroman, state: state))
    }
}
