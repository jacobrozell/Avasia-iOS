import XCTest
@testable import AvasiaAnthologyEngine

final class RingPassTests: XCTestCase {
    func testPurchaseAddsPass() {
        var state = AnthologyGameState()
        state.anthologyGold = 150
        _ = AnthologyRingPass.purchase(state: &state)
        XCTAssertEqual(state.ringPasses, 1)
        XCTAssertEqual(state.anthologyGold, 50)
    }

    func testRingPassBypassesFPOnLaunch() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        var boosted = engine.state
        boosted.factionPoints = 0
        boosted.ringPasses = 1
        engine.load(boosted)
        XCTAssertTrue(AnthologyCatalog.canPlay(.goodThree, state: engine.state).allowed)
        _ = engine.launchStory(.goodThree)
        XCTAssertEqual(engine.state.ringPasses, 0)
        XCTAssertEqual(engine.state.currentRoom, .goodThreeLanding)
    }

    func testDailyGrantOnHubEnter() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.ringPassLastGrantDay = "1999-01-01"
        let lines = StoryHubRoom().onEnter(&state)
        XCTAssertEqual(state.ringPasses, 1)
        XCTAssertNotNil(lines)
    }
}
