import XCTest
@testable import AvasiaAnthologyEngine

final class CaveRecordTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testCaveRecordRequiresElkFeast() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        XCTAssertFalse(AnthologyCatalog.canPlay(.caveRecord, state: engine.state).allowed)
    }

    func testCaveRecordFullPath() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REFUSE")
        AnthologyTestPaths.finishElkFeast(engine)
        XCTAssertEqual(engine.state.factionPoints, 500)
        _ = engine.launchStory(.caveRecord)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "COPY")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.caveRecordComplete)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertEqual(engine.state.factionPoints, 500)
    }
}
