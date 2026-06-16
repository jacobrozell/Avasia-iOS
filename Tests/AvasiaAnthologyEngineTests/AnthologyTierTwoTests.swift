import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyTierTwoTests: FullAnthologyTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodTwoRequiresGoodOneAndFP() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        var blocked = engine.state
        blocked.ringPasses = 0
        engine.load(blocked)
        XCTAssertEqual(engine.state.factionPoints, 500)
        XCTAssertFalse(AnthologyCatalog.canPlay(.goodTwo, state: engine.state).allowed)
        var boosted = engine.state
        boosted.factionPoints = 1000
        engine.load(boosted)
        XCTAssertTrue(AnthologyCatalog.canPlay(.goodTwo, state: engine.state).allowed)
    }

    func testGoodTwoFullPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        var boosted = engine.state
        boosted.factionPoints = 1000
        engine.load(boosted)
        _ = engine.launchStory(.goodTwo)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "FULL")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.goodTwoComplete)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertEqual(engine.state.factionPoints, 1000)
    }
}
