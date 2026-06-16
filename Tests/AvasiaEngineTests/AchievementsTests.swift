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

    func testGrimCatalogUnlocksAfterAllDeathCauses() {
        var p = AchievementState()
        let s = GameState()
        let causes = DeathCause.konAchievable.sorted { $0.rawValue < $1.rawValue }
        for cause in causes.dropLast() {
            _ = AchievementTracker.apply([.died(cause)], state: s, into: &p)
            XCTAssertFalse(p.has(.grimCatalog))
            XCTAssertTrue(p.deathCausesExperienced.contains(cause))
        }
        let last = causes.last!
        let newly = AchievementTracker.apply([.died(last)], state: s, into: &p)
        XCTAssertTrue(newly.contains(.grimCatalog))
        XCTAssertEqual(p.deathCausesExperienced, DeathCause.konAchievable)
    }

    func testGenericDeathDoesNotCountTowardGrimCatalog() {
        var p = AchievementState()
        let s = GameState()
        for cause in DeathCause.konAchievable {
            _ = AchievementTracker.apply([.died(cause)], state: s, into: &p)
        }
        XCTAssertTrue(p.has(.grimCatalog))
        p = AchievementState()
        for cause in DeathCause.konAchievable.dropLast() {
            _ = AchievementTracker.apply([.died(cause)], state: s, into: &p)
        }
        _ = AchievementTracker.apply([.died(.generic)], state: s, into: &p)
        XCTAssertFalse(p.has(.grimCatalog))
        XCTAssertFalse(p.deathCausesExperienced.contains(.generic))
    }

    func testFlavorUnlocks() {
        var p = AchievementState()
        let s = GameState()
        XCTAssertEqual(AchievementTracker.apply([.heard42], state: s, into: &p), [.meaningOfLife])
        XCTAssertEqual(AchievementTracker.apply([.caughtGoldFish], state: s, into: &p), [.goldRush])
        _ = AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p)
        _ = AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p)
        XCTAssertTrue(AchievementTracker.apply([.tossedOrangeFish], state: s, into: &p).contains(.persistentAngler))
        XCTAssertEqual(AchievementTracker.apply([.didBeachYoga], state: s, into: &p), [.crowPose])
        XCTAssertEqual(AchievementTracker.apply([.admittedNoIdea], state: s, into: &p), [.thanksForHonesty])
        XCTAssertEqual(AchievementTracker.apply([.swamDreamBridge], state: s, into: &p), [.againstInstinct])
        XCTAssertEqual(AchievementTracker.apply([.heardGateGuardLore], state: s, into: &p), [.schismScholar])
        XCTAssertEqual(AchievementTracker.apply([.relitLanternAtPedestal], state: s, into: &p), [.alreadyLitFam])
        XCTAssertEqual(AchievementTracker.apply([.caughtOldShoe], state: s, into: &p), [.soleSurvivor])
        XCTAssertEqual(AchievementTracker.apply([.survivedFishingCrab], state: s, into: &p), [.clawAndOrder])
        XCTAssertEqual(AchievementTracker.apply([.gained(.rod)], state: s, into: &p), [.goneFishin])
        XCTAssertEqual(AchievementTracker.apply([.provedWithEars], state: s, into: &p), [.earApparent])
        XCTAssertEqual(AchievementTracker.apply([.heardTradingPostGrief], state: s, into: &p), [.widowersLament])
    }

    func testFullyLoadedUnlocksWithFullKit() {
        var p = AchievementState()
        var state = GameState()
        for flag in [Flag.levitate, .sword, .lantern, .dagger, .rod, .fireball] {
            state.gain(flag)
            _ = AchievementTracker.apply([.gained(flag)], state: state, into: &p)
        }
        XCTAssertFalse(p.has(.fullyLoaded))
        state.gain(.stonebend)
        let newly = AchievementTracker.apply([.gained(.stonebend)], state: state, into: &p)
        XCTAssertTrue(newly.contains(.fullyLoaded))
        XCTAssertTrue(newly.contains(.fullArsenal))
    }

    func testCleanCoronationRequiresFlawlessRun() {
        var p = AchievementState()
        var state = GameState()
        state.deathCount = 1
        _ = AchievementTracker.apply([.won], state: state, into: &p)
        XCTAssertTrue(p.has(.kingOfNacastrum))
        XCTAssertFalse(p.has(.cleanCoronation))

        state.deathCount = 0
        let newly = AchievementTracker.apply([.won], state: GameState(), into: &p)
        XCTAssertTrue(newly.contains(.cleanCoronation))
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
        engine.restart()
        var p = AchievementState()
        func go(_ cmd: String) {
            _ = engine.submit(cmd)
            _ = AchievementTracker.apply(engine.lastEvents, state: engine.state, into: &p)
        }
        for cmd in [
            "north","west","kaefden","north","east","take","talk","north","east","levitate",
            "east","talk","north","light lantern","E","back","W","back","NW","back","NE","back",
            "N","1", engine.state.symbolAnswer, "S","back","south","back",
            "north","cut with sword","forward","up","up","left","talk","up","up","cut hand with dagger",
            "down","down","down","back","back","west","north","inflame","stonebend","swim",
            "continue","back","east","south","south","west","ready",
            "north","north","west","north","continue","continue","continue","continue"
        ] { go(cmd) }

        XCTAssertTrue(p.has(.kingOfNacastrum))
        XCTAssertTrue(p.has(.cleanCoronation))
        XCTAssertTrue(p.has(.againstInstinct))
        XCTAssertTrue(p.has(.schismScholar))
        XCTAssertTrue(p.has(.fullArsenal))
        XCTAssertTrue(p.has(.firekeeper))
        XCTAssertTrue(p.has(.earthshaper))
        XCTAssertTrue(p.has(.druidFriend))
    }
}
