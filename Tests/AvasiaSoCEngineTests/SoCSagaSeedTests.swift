import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

/// Act I saga seeds and journal wiring.
final class SoCSagaSeedTests: XCTestCase {

    func testPierOnEnterSetsDoranFlag() {
        var state = SoCGameState()
        state.currentRoom = .cataractaPier
        let room = SoCCataractaPier()

        _ = room.onEnter(&state)

        XCTAssertTrue(state.doran)
    }

    func testPierLookMentionsAnulaRequisition() {
        var state = SoCGameState()
        state.doran = true
        state.currentRoom = .cataractaPier
        let room = SoCCataractaPier()

        let result = room.handle(Parser.parse("look", mode: .normalized), &state)

        XCTAssertTrue(result.lines.contains { $0.text.contains("Anula requisition") })
        XCTAssertTrue(result.lines.contains { $0.text.contains("war chest") })
    }

    func testPierTalkMentionsUseAndChain() {
        var state = SoCGameState()
        state.doran = true
        state.currentRoom = .cataractaPier
        let room = SoCCataractaPier()

        let result = room.handle(Parser.parse("talk doran", mode: .normalized), &state)

        XCTAssertTrue(result.lines.contains { $0.text.contains("chain what you can") })
        XCTAssertTrue(result.lines.contains { $0.text.contains("Varatho") })
    }

    func testPierPaidFishingCostsGold() {
        var state = SoCGameState()
        state.doran = true
        state.currentRoom = .cataractaPier
        let room = SoCCataractaPier()

        let result = room.handle(Parser.parse("yes", mode: .normalized), &state)

        XCTAssertEqual(state.gold, 85)
        if case .move(.cataractaFishing) = result.transition {
            XCTAssertTrue(result.lines.contains { $0.text.contains("15 gold") })
        } else {
            XCTFail("Expected move to fishing pier")
        }
    }

    func testPortalSearchMentionsAnchors() {
        var state = SoCGameState()
        state.courtyardComplete = true
        state.currentRoom = .portalRoom
        let engine = SoCGameEngine(state: state)

        let lines = engine.submit("search")

        XCTAssertTrue(lines.contains { $0.text.contains("anchor") || $0.text.contains("chain") })
    }

    func testJournalPeacefulObjectivesMentionOptionalBeats() {
        let state = SoCGameState()
        let goals = SoCJournal.objectives(for: state)
        let joined = goals.joined(separator: " ")
        XCTAssertTrue(joined.contains("Courtyard"))
        XCTAssertTrue(joined.contains("Ulric") || joined.contains("blacksmith"))
        XCTAssertTrue(joined.contains("Varatho") || joined.contains("fountain"))
        XCTAssertTrue(joined.contains("Hunter's Path"))
    }

    func testJournalWarObjectivesAfterCourtyard() {
        var state = SoCGameState()
        state.courtyardComplete = true
        state.currentRoom = .throneRoom
        state.throneAudience = false

        let goals = SoCJournal.objectives(for: state)

        XCTAssertTrue(goals.contains { $0.contains("Kaefden") || $0.contains("throne") })
        XCTAssertFalse(goals.contains { $0.contains("Wolf, Bear, or Fox") })
    }

    func testJournalCompleteSuggestsRuins() {
        var state = SoCGameState()
        state.gameComplete = true
        state.ruinsVisited = false

        let goals = SoCJournal.objectives(for: state)

        XCTAssertTrue(goals.contains { $0.contains("RUINS") })
    }

    func testDoranCodexUnlocksWhenFlagSet() {
        var state = SoCGameState()
        state.doran = true
        XCTAssertTrue(SoCCodex.isUnlocked(.doran, state: state))
    }
}
