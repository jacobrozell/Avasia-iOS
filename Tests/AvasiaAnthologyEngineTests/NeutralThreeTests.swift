import XCTest
@testable import AvasiaAnthologyEngine

final class NeutralThreeTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testNeutralThreeRequiresCaveRecord() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        XCTAssertFalse(AnthologyCatalog.canPlay(.neutralThree, state: engine.state).allowed)
    }

    func testNeutralThreeBrokerPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        AnthologyTestPaths.finishCaveRecord(engine)
        var boosted = engine.state
        boosted.factionPoints = 2_500
        engine.load(boosted)
        _ = engine.launchStory(.neutralThree)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "BROKER")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.neutralThreeComplete)
        XCTAssertTrue(engine.state.neutralThreeBrokersPeace)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertEqual(engine.state.factionPoints, 2_500)
    }
}
