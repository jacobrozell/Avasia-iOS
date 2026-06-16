import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyEconomyTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testGoodOneUnlocksForLoyalist() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        XCTAssertEqual(engine.state.factionPoints, 500)

        let (allowed, _) = AnthologyCatalog.canPlay(.goodOne, state: engine.state)
        XCTAssertTrue(allowed)

        advance(engine, "PLAY GOOD")
        XCTAssertEqual(engine.state.currentRoom, .goodOneSilvarium)
        XCTAssertEqual(engine.state.factionPoints, 0)
    }

    func testBadOneUnlocksForAgroman() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        advance(engine, "PLAY BAD")
        XCTAssertEqual(engine.state.currentRoom, .badOneColumn)
    }

    func testElkFeastUnlocksForNeutral() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        advance(engine, "PLAY ELK")
        XCTAssertEqual(engine.state.currentRoom, .elkSplitpath)
        XCTAssertEqual(engine.state.factionPoints, 250)
    }

    func testWrongAlignmentBlocksGoodOne() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "FOLLOW")
        let (allowed, reason) = AnthologyCatalog.canPlay(.goodOne, state: engine.state)
        XCTAssertFalse(allowed)
        XCTAssertNotNil(reason)
    }

    func testGoodOneFullPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        XCTAssertTrue(engine.state.goodOneComplete)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertEqual(engine.state.factionPoints, 500)
    }
}
