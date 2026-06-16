import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyTierFourTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodFourRequiresGoodThreeAndFP() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        AnthologyTestPaths.finishGoodThree(engine)
        var blocked = engine.state
        blocked.ringPasses = 0
        engine.load(blocked)
        XCTAssertFalse(AnthologyCatalog.canPlay(.goodFour, state: engine.state).allowed)
        var boosted = engine.state
        boosted.factionPoints = 5_000
        engine.load(boosted)
        XCTAssertTrue(AnthologyCatalog.canPlay(.goodFour, state: engine.state).allowed)
    }

    func testGoodFourHoldPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        AnthologyTestPaths.finishGoodThree(engine)
        var boosted = engine.state
        boosted.factionPoints = 5_000
        engine.load(boosted)
        _ = engine.launchStory(.goodFour)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "HOLD")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.goodFourComplete)
        XCTAssertTrue(engine.state.goodFourHoldLine)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }

    func testBadFourStormPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        AnthologyTestPaths.finishBadOne(engine)
        AnthologyTestPaths.finishBadTwo(engine)
        AnthologyTestPaths.finishBadThree(engine)
        var boosted = engine.state
        boosted.factionPoints = 5_000
        engine.load(boosted)
        _ = engine.launchStory(.badFour)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "STORM")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.badFourComplete)
        XCTAssertTrue(engine.state.badFourMeasuredAssault)
    }

    func testNeutralFourWitnessPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        AnthologyTestPaths.finishCaveRecord(engine)
        AnthologyTestPaths.finishNeutralThree(engine)
        var boosted = engine.state
        boosted.factionPoints = 5_000
        engine.load(boosted)
        _ = engine.launchStory(.neutralFour)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "WITNESS")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.neutralFourComplete)
        XCTAssertTrue(engine.state.neutralFourStayedWitness)
    }
}
