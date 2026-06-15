import XCTest
@testable import AvasiaEngine

final class AchievementsTests: XCTestCase {

    func testSpellAndArsenalUnlocks() {
        var p = AchievementState()
        var state = GameState()
        state.gain(.levitate)
        XCTAssertEqual(AchievementTracker.apply([.gained(.levitate)], state: state, into: &p), [.firstSteps])

        state.gain(.fireball); state.gain(.stonebend)
        let newly = AchievementTracker.apply([.gained(.stonebend)], state: state, into: &p)
        XCTAssertTrue(newly.contains(.earthshaper))
        XCTAssertTrue(newly.contains(.fullArsenal))
        XCTAssertTrue(p.has(.fullArsenal))
    }

    func testDeathCauseUnlocks() {
        var p = AchievementState()
        let s = GameState()
        let newly = AchievementTracker.apply([.died(.chasm)], state: s, into: &p)
        XCTAssertTrue(newly.contains(.firstBlood))
        XCTAssertTrue(newly.contains(.intoTheDeep))
        XCTAssertEqual(p.totalDeaths, 1)
    }

    func testMartyrAtTenDeaths() {
        var p = AchievementState()
        let s = GameState()
        for _ in 0..<9 { _ = AchievementTracker.apply([.died(.generic)], state: s, into: &p) }
        XCTAssertFalse(p.has(.martyr))
        let newly = AchievementTracker.apply([.died(.generic)], state: s, into: &p)
        XCTAssertTrue(newly.contains(.martyr))
    }

    func testFlavorUnlocks() {
        var p = AchievementState()
        let s = GameState()
        XCTAssertEqual(AchievementTracker.apply([.heard42], state: s, into: &p), [.meaningOfLife])
        XCTAssertEqual(AchievementTracker.apply([.caughtGoldFish], state: s, into: &p), [.goldRush])
        _ = AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p)
        _ = AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p)
        XCTAssertTrue(AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p).contains(.persistentAngler))
    }

    func testRegionExploration() {
        var p = AchievementState()
        let s = GameState()
        for region in Region.konPlayable {
            _ = AchievementTracker.apply([.enteredRegion(region)], state: s, into: &p)
        }
        XCTAssertTrue(p.has(.wanderer))
        XCTAssertTrue(p.has(.worldsEnd))
        XCTAssertFalse(p.regionsVisited.contains(.cataracta))
    }

    /// Death rooms emit the right cause through the engine's event stream.
    func testEngineEmitsDeathCause() {
        let engine = GameEngine()
        engine.load(room: .bridge)
        _ = engine.submit("jump")
        XCTAssertTrue(engine.lastEvents.contains(.died(.chasm)))
    }

    /// A full playthrough folds events into achievements, ending in the win.
    func testFullPlaythroughUnlocksKing() {
        let engine = GameEngine()
        var p = AchievementState()
        func go(_ cmd: String) {
            _ = engine.submit(cmd)
            _ = AchievementTracker.apply(engine.lastEvents, state: engine.state, into: &p)
        }
        for cmd in [
            "west","kaefden","north","east","take","north","east","levitate",
            "east","talk","north","light lantern","E","back","W","back","NW","back","NE","back",
            "N","1", engine.state.symbolAnswer, "S","back","south","back",
            "north","cut with sword","forward","up","up","left","talk","up","up","cut hand with dagger",
            "down","down","down","back","back","west","north","inflame","stonebend","swim",
            "continue","back","east","south","south","west","ready",
            "north","north","west","north","continue","continue","continue","continue"
        ] { go(cmd) }

        XCTAssertTrue(p.has(.kingOfNacastrum))
        XCTAssertTrue(p.has(.fullArsenal))
        XCTAssertTrue(p.has(.firekeeper))
        XCTAssertTrue(p.has(.earthshaper))
        XCTAssertTrue(p.has(.druidFriend))
    }
}
