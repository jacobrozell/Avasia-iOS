import XCTest
@testable import AvasiaAnthologyEngine

final class AnthologyReleaseTests: XCTestCase {
    override func tearDown() {
        AnthologyRelease.shipsFullAnthology = false
        super.tearDown()
    }

    func testDeferredStoriesBlockedInLeanRelease() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        AnthologyTestPaths.finishGoodOne(engine)
        var boosted = engine.state
        boosted.factionPoints = 10_000
        engine.load(boosted)

        XCTAssertFalse(AnthologyCatalog.canPlay(.goodTwo, state: engine.state).allowed)
        XCTAssertFalse(AnthologyCatalog.canPlay(.caveRecord, state: engine.state).allowed)
    }

    func testPickerSectionsOmitDeferredStories() {
        let shippedIDs = Set(
            AnthologyCatalog.pickerSections.flatMap(\.stories).map(\.id)
        )
        XCTAssertEqual(shippedIDs, Set(AnthologyCatalog.shipsIn100.map(\.id)))
    }

    func testLaunchSliceCompleteAfterTierOne() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.alignment = .loyalist
        state.completedStories = [.goodOne]
        XCTAssertTrue(AnthologyPathProgress.isLaunchSliceComplete(state: state))
    }

    func testListLinesOmitDeferredStories() {
        let engine = AnthologyGameEngine()
        let lines = AnthologyCatalog.listLines(state: engine.state)
        let body = lines
            .filter { $0.style == .body }
            .map(\.text)
            .joined(separator: "\n")
        XCTAssertTrue(body.contains("Scout Patrol"))
        XCTAssertFalse(body.contains("Nascastrum Courier"))
        XCTAssertFalse(body.contains("Cave Record"))
    }
}
