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
        advance(engine, "CONTINUE")
        advance(engine, "SIGN")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.goodSixComplete)
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.loyalist, state: engine.state))
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
        advance(engine, "CONTINUE")
        advance(engine, "PUBLISH")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.neutralSixComplete)
        XCTAssertTrue(engine.state.neutralSixPublishedLedger)
        XCTAssertTrue(AnthologyPathProgress.isPathComplete(.neutral, state: engine.state))
    }
}
