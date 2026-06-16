import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyTierFiveTests: FullAnthologyTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodFiveRequiresGoodFourAndFP() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        AnthologyTestPaths.finishGoodThree(engine)
        AnthologyTestPaths.finishGoodFour(engine)
        var blocked = engine.state
        blocked.ringPasses = 0
        engine.load(blocked)
        XCTAssertFalse(AnthologyCatalog.canPlay(.goodFive, state: engine.state).allowed)
        var boosted = engine.state
        boosted.factionPoints = 10_000
        engine.load(boosted)
        XCTAssertTrue(AnthologyCatalog.canPlay(.goodFive, state: engine.state).allowed)
    }

    func testGoodFiveSwearPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        AnthologyTestPaths.finishGoodThree(engine)
        AnthologyTestPaths.finishGoodFour(engine)
        var boosted = engine.state
        boosted.factionPoints = 10_000
        engine.load(boosted)
        _ = engine.launchStory(.goodFive)
        advance(engine, "CONTINUE")
        advance(engine, "SWEAR")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.goodFiveComplete)
        XCTAssertTrue(engine.state.goodFiveSworeWitness)
    }

    func testBadFiveDeclinePath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        AnthologyTestPaths.finishBadOne(engine)
        AnthologyTestPaths.finishBadTwo(engine)
        AnthologyTestPaths.finishBadThree(engine)
        AnthologyTestPaths.finishBadFour(engine)
        var boosted = engine.state
        boosted.factionPoints = 10_000
        engine.load(boosted)
        _ = engine.launchStory(.badFive)
        advance(engine, "CONTINUE")
        advance(engine, "DECLINE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.badFiveComplete)
        XCTAssertFalse(engine.state.badFiveAcceptedCommand)
    }

    func testNeutralFiveStayPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        AnthologyTestPaths.finishCaveRecord(engine)
        AnthologyTestPaths.finishNeutralThree(engine)
        AnthologyTestPaths.finishNeutralFour(engine)
        var boosted = engine.state
        boosted.factionPoints = 10_000
        engine.load(boosted)
        _ = engine.launchStory(.neutralFive)
        advance(engine, "CONTINUE")
        advance(engine, "STAY")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.neutralFiveComplete)
        XCTAssertTrue(engine.state.neutralFiveStayedOnRoad)
    }
}
