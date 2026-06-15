import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

/// Automated walkthrough helpers and E2E critical-path coverage.
final class SoCCriticalPathTests: XCTestCase {
    func testQuestLevelUpAtThreshold() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        let lines = SoCQuestProgress.grantQuestExp(100, state: &state)
        XCTAssertEqual(state.playerLevel, 2)
        XCTAssertEqual(state.playerAtk, 11)
        XCTAssertTrue(lines.contains { $0.text.contains("Level Up") })
    }

    func testNorthernMarchScoutBypass() {
        var state = SoCGameState()
        state.applyClass(.scout)
        state.aylovaMusterComplete = true
        state.currentRoom = .northernMarch
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("scout")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.scoutShortcut)
        XCTAssertTrue(engine.state.northernMarchCleared)
        XCTAssertEqual(engine.state.currentRoom, .oceandaleFront)
    }

    func testActIIIThroughEpilogue() {
        var state = SoCGameState()
        state.playerName = "Hero"
        state.applyClass(.guardian)
        state.courtyardComplete = true
        state.currentRoom = .portalRoom
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("search")
        _ = engine.submit("move books")
        XCTAssertEqual(engine.state.currentRoom, .library)

        _ = engine.submit("south")
        _ = engine.submit("east")

        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.throneAudience)

        _ = engine.submit("march")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        XCTAssertEqual(engine.state.currentRoom, .northernMarch)

        _ = engine.submit("continue")
        fightToVictory(engine)
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        XCTAssertEqual(engine.state.currentRoom, .oceandaleFront)

        _ = engine.submit("continue")
        _ = engine.submit("continue")
        fightToVictory(engine)
        _ = engine.submit("continue")
        fightToVictory(engine)
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.oceandaleFrontCleared)

        _ = engine.submit("advance")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        fightToVictory(engine)
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.mageOutpostCleared)

        _ = engine.submit("march")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        fightToVictory(engine)
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.vashirrDefeated)

        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.gameComplete)
        XCTAssertTrue(engine.state.trophies.contains(.ageComplete))
    }

    func testCourtyardThroughPortal() {
        var state = SoCGameState()
        state.playerName = "Hero"
        state.currentRoom = .cataractaNorth
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("east")
        _ = engine.submit("bear")
        fightToVictory(engine)
        fightToVictory(engine)

        XCTAssertTrue(engine.state.courtyardComplete)
        XCTAssertEqual(engine.state.currentRoom, .portalRoom)
    }

    func testEpilogueRuinsCoda() {
        var state = SoCGameState()
        state.playerName = "Hero"
        state.gameComplete = true
        state.ageEpiloguePhase = .done
        state.currentRoom = .ageEpilogue
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("visit ruins")
        XCTAssertEqual(engine.state.currentRoom, .cataractaRuins)

        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.ruinsVisited)
        XCTAssertTrue(engine.state.trophies.contains(.returnedToAshes))

        _ = engine.submit("return")
        XCTAssertEqual(engine.state.currentRoom, .ageEpilogue)
    }

    func testObjectivesCommand() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.courtyardComplete = true
        state.currentRoom = .portalRoom
        let engine = SoCGameEngine(state: state)
        let lines = engine.submit("objectives")
        XCTAssertTrue(lines.contains { $0.text.contains("Objectives") })
        XCTAssertTrue(lines.contains { $0.text.contains("portal") || $0.text.contains("library") })
    }

    private func fightToVictory(_ engine: SoCGameEngine, maxTurns: Int = 60) {
        var turns = 0
        while engine.state.inCombat, turns < maxTurns {
            _ = engine.submit("attack")
            turns += 1
        }
        XCTAssertFalse(engine.state.inCombat, "Combat did not end within \(maxTurns) turns")
    }
}
