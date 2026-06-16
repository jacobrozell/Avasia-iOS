import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyTierSixTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodSixCompletesLoyalistPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        AnthologyTestPaths.finishGoodThree(engine)
        AnthologyTestPaths.finishGoodFour(engine)
        AnthologyTestPaths.finishGoodFive(engine)
        var boosted = engine.state
        boosted.factionPoints = 17_500
        boosted.ringPasses = 0
        engine.load(boosted)
        _ = engine.launchStory(.goodSix)
        advance(engine, "CONTINUE") // hall → antechamber
        advance(engine, "CONTINUE") // antechamber → witness prep
        advance(engine, "CONTINUE") // witness prep → signing floor
        advance(engine, "SIGN")
        advance(engine, "CONTINUE") // signing → aftermath
        advance(engine, "CONTINUE") // aftermath → epilogue
        advance(engine, "CONTINUE") // complete
        XCTAssertTrue(engine.state.goodSixComplete)
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.loyalist, state: engine.state))
    }

    func testBadSixYieldPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        AnthologyTestPaths.finishBadOne(engine)
        AnthologyTestPaths.finishBadTwo(engine)
        AnthologyTestPaths.finishBadThree(engine)
        AnthologyTestPaths.finishBadFour(engine)
        AnthologyTestPaths.finishBadFive(engine)
        var boosted = engine.state
        boosted.factionPoints = 17_500
        engine.load(boosted)
        _ = engine.launchStory(.badSix)
        advance(engine, "CONTINUE") // hall → street
        advance(engine, "CONTINUE") // street → officers
        advance(engine, "CONTINUE") // officers → throne
        advance(engine, "YIELD")
        advance(engine, "CONTINUE") // throne → aftermath
        advance(engine, "CONTINUE") // aftermath → epilogue
        advance(engine, "CONTINUE") // complete
        XCTAssertTrue(engine.state.badSixComplete)
        XCTAssertFalse(engine.state.badSixAcceptedRule)
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.agroman, state: engine.state))
    }

    func testNeutralSixPublishPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        AnthologyTestPaths.finishCaveRecord(engine)
        AnthologyTestPaths.finishNeutralThree(engine)
        AnthologyTestPaths.finishNeutralFour(engine)
        AnthologyTestPaths.finishNeutralFive(engine)
        var boosted = engine.state
        boosted.factionPoints = 17_500
        engine.load(boosted)
        _ = engine.launchStory(.neutralSix)
        advance(engine, "CONTINUE") // archive → record hall
        advance(engine, "CONTINUE") // record hall → witness table
        advance(engine, "CONTINUE") // witness table → binding
        advance(engine, "PUBLISH")
        advance(engine, "CONTINUE") // binding → aftermath
        advance(engine, "CONTINUE") // aftermath → epilogue
        advance(engine, "CONTINUE") // complete
        XCTAssertTrue(engine.state.neutralSixComplete)
        XCTAssertTrue(engine.state.neutralSixPublishedLedger)
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.neutral, state: engine.state))
    }
}
