import XCTest
@testable import AvasiaEngine

/// Saga foreshadowing beats — gate guard, beach awakening, civic anchors.
final class SagaSeedTests: XCTestCase {

    func testGateGuardNorthBlockedUntilTalk() {
        let engine = GameEngine()
        engine.load(room: .graveyard)
        XCTAssertFalse(engine.state.gateGuardLoreHeard)

        let blocked = engine.submit("north")
        XCTAssertEqual(engine.state.currentRoom, .graveyard)
        XCTAssertFalse(engine.state.gateGuardLoreHeard)
        XCTAssertTrue(blocked.contains { $0.text.contains("words with me first") })

        let talk = engine.submit("talk")
        XCTAssertTrue(engine.state.gateGuardLoreHeard)
        XCTAssertTrue(talk.contains { $0.text.contains("Agroman") })
        XCTAssertTrue(engine.lastEvents.contains(.heardGateGuardLore))
        XCTAssertTrue(KonCodex.isUnlocked(.gateGuard, state: engine.state))
        XCTAssertTrue(KonCodex.isUnlocked(.schismLore, state: engine.state))

        _ = engine.submit("north")
        XCTAssertEqual(engine.state.currentRoom, .splitpath)
    }

    func testGateGuardTalkWithoutLeavingGraveyard() {
        var state = GameState()
        state.currentRoom = .graveyard
        let room = GraveyardRoom()

        let result = room.handle(Parser.parse("talk guard", mode: .normalized), &state)

        XCTAssertTrue(state.gateGuardLoreHeard)
        XCTAssertEqual(result.transition, .stay)
        XCTAssertTrue(result.lines.contains { $0.text.contains("middle name was Agroman") })
    }

    func testGateGuardRepeatTalkIsAbbreviated() {
        var state = GameState()
        state.gateGuardLoreHeard = true
        state.currentRoom = .graveyard
        let room = GraveyardRoom()

        let result = room.handle(Parser.parse("talk guard", mode: .normalized), &state)

        XCTAssertTrue(result.lines.contains { $0.text.contains("Same schism") })
        XCTAssertFalse(result.lines.contains { $0.text.contains("Welcome to Oceandale") })
    }

    func testGateGuardNorthSkippedDuringEscort() {
        var state = GameState()
        state.escortActive = true
        state.currentRoom = .graveyard
        let room = GraveyardRoom()

        let result = room.handle(Parser.parse("north", mode: .normalized), &state)

        XCTAssertFalse(state.gateGuardLoreHeard)
        if case .move(.splitpath) = result.transition {
            XCTAssertEqual(result.lines.count, 1)
        } else {
            XCTFail("Expected move to splitpath without gate speech")
        }
    }

    func testBeachOpeningIncludesYogaAndAwakening() {
        let engine = GameEngine()
        engine.restart()
        XCTAssertEqual(engine.state.currentRoom, .beach)

        let opening = engine.describeCurrent()
        XCTAssertTrue(engine.state.beachIntroShown)
        XCTAssertTrue(opening.contains { $0.text == "The Shore" })
        XCTAssertTrue(opening.contains { $0.text.contains("YOGA") })

        let yoga = engine.submit("yoga")
        XCTAssertTrue(yoga.contains { $0.text.contains("Crow Pose") })
        XCTAssertTrue(engine.lastEvents.contains(.didBeachYoga))
    }

    func testBeachFirstVisitShowsAwakening() {
        let engine = GameEngine()
        engine.load(room: .oceandale)

        let lines = engine.submit("south")

        XCTAssertTrue(engine.state.beachIntroShown)
        XCTAssertEqual(engine.state.currentRoom, .beach)
        XCTAssertTrue(lines.contains { $0.text == "The Shore" })
        XCTAssertTrue(KonCodex.isUnlocked(.beachAwakening, state: engine.state))
    }

    func testChurchLookMentionsCivicAnchor() {
        let engine = GameEngine()
        engine.load(room: .church)

        let lines = engine.submit("look shrine")

        XCTAssertTrue(lines.contains { $0.text.contains("Civic faith") })
        XCTAssertTrue(lines.contains { $0.text.contains("matron") })
    }

    func testChurchAskMatronMentionsAnchors() {
        let engine = GameEngine()
        engine.load(room: .church)

        let lines = engine.submit("ask matron")

        XCTAssertTrue(lines.contains { $0.text.contains("anchors") })
    }

    func testOceandaleLookMentionsColonyAndSchism() {
        let engine = GameEngine()
        engine.load(room: .oceandale)

        let lines = engine.submit("look")

        XCTAssertTrue(lines.contains { $0.text.contains("fishing colony") })
        XCTAssertTrue(lines.contains { $0.text.contains("schism") })
    }

    func testGateGuardLoreCanonicalSpeechIncludesOfelos() {
        let speech = KoNGateGuardLore.schismSpeech().map(\.text).joined(separator: " ")
        XCTAssertTrue(speech.contains("Ofelos"))
        XCTAssertTrue(speech.contains("Power must cling"))
    }
}
