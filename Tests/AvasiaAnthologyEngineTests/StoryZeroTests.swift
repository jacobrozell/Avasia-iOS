import XCTest
@testable import AvasiaAnthologyEngine
import AvasiaEngine

final class StoryZeroTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    private func beginScoutPatrol(_ engine: AnthologyGameEngine) {
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        advance(engine, "PLAY SCOUT")
        XCTAssertEqual(engine.state.currentRoom, .patrolCamp)
    }

    func testLoyalistPathCompletesStoryZero() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutRidge)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutPicket)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .vashirrParley)

        for _ in 0..<4 { advance(engine, "CONTINUE") }
        XCTAssertEqual(engine.state.currentRoom, .scoutFork)

        advance(engine, "REPORT")
        XCTAssertEqual(engine.state.alignment, .loyalist)
        XCTAssertTrue(engine.state.forkResolved)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutCampExit)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutEpilogue)

        advance(engine, "CONTINUE")
        XCTAssertTrue(engine.state.storyZeroComplete)
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertEqual(engine.state.factionPoints, 500)
    }

    func testAgromanFork() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        for _ in 0..<4 { advance(engine, "CONTINUE") }
        advance(engine, "FOLLOW")
        XCTAssertEqual(engine.state.alignment, .agroman)
    }

    func testNeutralFork() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        for _ in 0..<4 { advance(engine, "CONTINUE") }
        advance(engine, "REFUSE")
        XCTAssertEqual(engine.state.alignment, .neutral)
    }

    func testWithdrawPathSkipsCaptureAndBlocksFollow() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)

        advance(engine, "CONTINUE")
        advance(engine, "WITHDRAW")
        XCTAssertEqual(engine.state.currentRoom, .scoutWithdraw)
        XCTAssertEqual(engine.state.ridgeOutcome, .withdrew)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutSignal)

        advance(engine, "SIGNAL")
        XCTAssertTrue(engine.state.scoutSignalSent)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutFork)
        XCTAssertFalse(engine.state.parleyHeardFullSermon)

        advance(engine, "FOLLOW")
        XCTAssertEqual(engine.state.alignment, .none)
        XCTAssertFalse(engine.state.forkResolved)

        advance(engine, "REPORT")
        XCTAssertEqual(engine.state.alignment, .loyalist)
        XCTAssertEqual(engine.state.miraStatus, .partner)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutCampExit)

        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.currentRoom, .scoutEpilogue)
    }

    func testCapturedPathSetsParleyFlag() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        XCTAssertEqual(engine.state.ridgeOutcome, .captured)
        advance(engine, "CONTINUE")
        for _ in 0..<4 { advance(engine, "CONTINUE") }
        XCTAssertTrue(engine.state.parleyHeardFullSermon)
    }

    func testFollowSetsMiraBrokeAway() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        for _ in 0..<4 { advance(engine, "CONTINUE") }
        advance(engine, "FOLLOW")
        XCTAssertEqual(engine.state.miraStatus, .brokeAway)
    }

    func testGoodOneDebriefReflectsCapturedSermon() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        XCTAssertTrue(engine.state.parleyHeardFullSermon)

        advance(engine, "PLAY GOOD")
        let lines = engine.describeCurrent().map(\.text).joined(separator: "\n")
        XCTAssertTrue(lines.contains("sermon too cleanly"))
    }

    func testGoodOneDebriefReflectsWithdrawSignal() {
        let engine = AnthologyGameEngine()
        beginScoutPatrol(engine)
        advance(engine, "CONTINUE")
        advance(engine, "WITHDRAW")
        advance(engine, "CONTINUE")
        advance(engine, "SIGNAL")
        advance(engine, "CONTINUE")
        advance(engine, "REPORT")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")

        advance(engine, "PLAY GOOD")
        let lines = engine.describeCurrent().map(\.text).joined(separator: "\n")
        XCTAssertTrue(lines.contains("Green smoke"))
    }

    func testVashirrSchismMentionsAnchorLaw() {
        var state = AnthologyGameState()
        state.currentRoom = .vashirrParley
        state.parleyPhase = .notStarted
        let room = StoryZeroVashirrParleyRoom()

        _ = room.onEnter(&state)
        let result = room.handle(Parser.parse("continue", mode: .raw), &state)

        let text = result.lines.map(\.text).joined(separator: " ")
        XCTAssertTrue(text.contains("anchor"))
        XCTAssertEqual(state.parleyPhase, .schism)
    }
}
