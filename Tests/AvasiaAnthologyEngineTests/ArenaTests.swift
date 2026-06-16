import XCTest
@testable import AvasiaAnthologyEngine

final class ArenaTests: XCTestCase {
    private func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }

    func testArenaClearsThreeWaves() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        _ = engine.launchArena()
        engine.setArenaHp(999)
        XCTAssertEqual(engine.state.currentRoom, .arenaPit)

        for _ in 0..<80 {
            if engine.state.currentRoom == .storyHub { break }
            if engine.state.arenaInCombat {
                engine.setArenaHp(999)
                advance(engine, "ATTACK")
            } else {
                advance(engine, "CONTINUE")
            }
        }

        XCTAssertEqual(engine.state.currentRoom, .storyHub)
        XCTAssertFalse(engine.state.arenaRunActive)
        XCTAssertGreaterThanOrEqual(engine.state.anthologyGold, AnthologyCatalog.arenaGoldReward)
        XCTAssertTrue(engine.state.arenaFirstClearDone)
    }
}
