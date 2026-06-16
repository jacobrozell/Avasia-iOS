import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyTierThreeTests: FullAnthologyTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodThreeRequiresGoodTwoAndFP() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        var blocked = engine.state
        blocked.ringPasses = 0
        engine.load(blocked)
        XCTAssertFalse(AnthologyCatalog.canPlay(.goodThree, state: engine.state).allowed)
        var boosted = engine.state
        boosted.factionPoints = 2_500
        engine.load(boosted)
        XCTAssertTrue(AnthologyCatalog.canPlay(.goodThree, state: engine.state).allowed)
    }

    func testGoodThreeEpilogueCompletesDirectly() {
        var state = AnthologyGameState()
        state.currentStory = .goodThree
        state.goodThreeVerdictResolved = true
        state.goodThreePublicTestimony = true
        state.currentRoom = .goodThreeEpilogue
        let engine = AnthologyGameEngine(state: state)
        _ = engine.submit("CONTINUE")
        XCTAssertTrue(engine.state.goodThreeComplete)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }

    func testGoodThreePetitionPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        AnthologyTestPaths.finishGoodTwo(engine)
        var boosted = engine.state
        boosted.factionPoints = 2_500
        engine.load(boosted)
        _ = engine.launchStory(.goodThree)
        XCTAssertEqual(engine.state.currentRoom, .goodThreeLanding)
        for _ in 0..<5 { advance(engine, "CONTINUE") }
        XCTAssertEqual(engine.state.currentRoom, .goodThreeVerdict)
        advance(engine, "PETITION")
        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .goodThreeAftermath)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.goodThreeComplete)
        XCTAssertTrue(engine.state.goodThreePublicTestimony)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }

    func testBadThreeSwearPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        AnthologyTestPaths.finishBadOne(engine)
        AnthologyTestPaths.finishBadTwo(engine)
        var boosted = engine.state
        boosted.factionPoints = 2_500
        engine.load(boosted)
        _ = engine.launchStory(.badThree)
        XCTAssertEqual(engine.state.currentRoom, .badThreeMarch)
        for _ in 0..<4 { advance(engine, "CONTINUE") }
        XCTAssertEqual(engine.state.currentRoom, .badThreeOath)
        advance(engine, "SWEAR")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.badThreeComplete)
        XCTAssertTrue(engine.state.badThreeSworeOath)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }
}
