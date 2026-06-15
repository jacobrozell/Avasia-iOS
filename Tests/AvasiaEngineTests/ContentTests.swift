import XCTest
@testable import AvasiaEngine

/// Exercises the full content graph by scripting a complete playthrough from the
/// beach to the canonical ending. If any room is mis-wired, the asserted room or
/// flag transitions will fail. This doubles as a living walkthrough.
final class ContentTests: XCTestCase {

    func testFireballPuzzleSolveAndFail() {
        let engine = GameEngine()
        engine.load(room: .fireballRoom) { $0.gain(.northCaveGateOpen) }

        // Wrong answer burns a guess but does not grant the spell.
        let wrong = engine.state.symbolAnswer == "0000" ? "1111" : "0000"
        _ = engine.submit(wrong)
        XCTAssertEqual(engine.state.guesses, 2)
        XCTAssertFalse(engine.state.has(.fireball))

        // Correct answer grants Inflame.
        _ = engine.submit(engine.state.symbolAnswer)
        XCTAssertTrue(engine.state.has(.fireball))
        XCTAssertEqual(engine.state.currentRoom, .mainCave)
    }

    func testFireballOutOfGuessesIsLethal() {
        let engine = GameEngine()
        engine.load(room: .fireballRoom)
        let wrong = "9999"
        _ = engine.submit(wrong)  // 2
        _ = engine.submit(wrong)  // 1
        _ = engine.submit(wrong)  // 0 -> death
        XCTAssertEqual(engine.state.deathCount, 1)
    }

    func testAmbushUnwinnableWithoutInflame() {
        let engine = GameEngine()
        engine.load(room: .roadToNacastrum) { $0.gain(.sword) }
        _ = engine.submit("sword")   // roadProgress 0 -> 1 (cornered)
        XCTAssertEqual(engine.state.roadProgress, 1)
        _ = engine.submit("sword")   // cornered -> death
        XCTAssertEqual(engine.state.deathCount, 1)
    }

    /// The complete critical path (see WORLD_MAP "Critical-path summary").
    func testFullPlaythroughReachesWin() {
        let engine = GameEngine()
        func go(_ cmd: String) { _ = engine.submit(cmd) }
        func room(_ id: RoomID, _ msg: String = "") {
            XCTAssertEqual(engine.state.currentRoom, id, msg.isEmpty ? "expected \(id)" : msg)
        }

        // Oceandale: learn Levitate, take the sword.
        go("west"); go("kaefden")
        XCTAssertTrue(engine.state.has(.levitate))
        go("north"); go("east"); go("take")
        XCTAssertTrue(engine.state.has(.sword))

        // To the mountain via the bridge.
        go("north"); room(.splitpath)
        go("east"); go("levitate"); room(.mountain)

        // Dentros -> lantern; into the cave.
        go("east"); go("talk")
        XCTAssertTrue(engine.state.has(.lantern))
        go("north"); go("light lantern"); room(.mainCave)

        // Visit the four clue rooms (the runes are read from state).
        go("E"); go("back")
        go("W"); go("back")
        go("NW"); go("back")
        go("NE"); go("back")

        // North gate -> fireball room -> learn Inflame.
        go("N"); go("1"); room(.fireballRoom)
        go(engine.state.symbolAnswer)
        XCTAssertTrue(engine.state.has(.fireball))

        // Back out to the Splitpath, then north to the forest.
        go("S"); go("back"); room(.mountain)
        go("south"); go("back"); room(.splitpath)
        go("north"); room(.forestEntrance)

        // Cut the grass, into Silvarium and up the tree.
        go("cut with sword"); go("forward"); room(.silvarium)
        go("up"); go("up"); room(.treeFloor2)
        go("left"); go("talk")
        XCTAssertTrue(engine.state.has(.dagger))
        go("up"); go("up"); room(.treeFloor4)
        go("cut hand with dagger")
        XCTAssertTrue(engine.state.has(.stonebend))

        // Back down and out to the western road.
        go("down"); go("down"); go("down"); room(.silvarium)
        go("back"); go("back"); room(.splitpath)
        go("west"); room(.westernRoad)

        // The gauntlet: Inflame -> Stonebend -> dream-swim.
        go("north"); room(.roadToNacastrum)
        go("inflame")
        XCTAssertEqual(engine.state.roadProgress, 2)
        go("stonebend")
        XCTAssertEqual(engine.state.roadProgress, 3)
        go("swim"); room(.teleporter)

        // First teleporter visit -> go fetch the Old Mage.
        go("continue")
        XCTAssertTrue(engine.state.teleporterDiscovered)
        go("back"); room(.westernRoad)
        go("east"); go("south"); go("south"); room(.oceandale)
        go("west"); go("ready")
        XCTAssertTrue(engine.state.escortActive)

        // Escort to the platform and through to the ending.
        go("north"); go("north"); go("west"); room(.westernRoad)
        go("north"); room(.teleporter)
        go("continue"); room(.nacastrum)
        go("continue"); room(.aylova)
        go("continue"); room(.ending)
        let final = engine.submit("continue")
        XCTAssertTrue(final.contains { $0.text.contains("Congratulations") },
                      "ending should produce the win message")
    }

    func testEveryRoomIDHasAScript() {
        let world = World.build()
        for id in RoomID.allCases {
            XCTAssertNotNil(world[id], "missing room script for \(id)")
        }
    }
}
