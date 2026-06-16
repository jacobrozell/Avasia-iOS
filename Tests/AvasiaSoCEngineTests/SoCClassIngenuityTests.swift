import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

final class SoCClassIngenuityTests: XCTestCase {
    func testNorthernMarchHunterBypass() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.aylovaMusterComplete = true
        state.ofelosAllianceComplete = true
        state.currentRoom = .northernMarch
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("hunt")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.northernMarchCleared)
        XCTAssertFalse(engine.state.inCombat)
        XCTAssertEqual(engine.state.currentRoom, .oceandaleFront)
    }

    func testNorthernMarchGuardianBypass() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.aylovaMusterComplete = true
        state.ofelosAllianceComplete = true
        state.currentRoom = .northernMarch
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("shield")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.northernMarchCleared)
        XCTAssertFalse(engine.state.inCombat)
    }

    func testVaratroHunterBypassesWarden() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.currentRoom = .varatroFalls
        state.varatroFallsPhase = .tomb
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("hunt")

        XCTAssertTrue(engine.state.trophies.contains(.bladeBearer))
        XCTAssertTrue(engine.state.inventory[.bladeOfCourage, default: 0] > 0)
        XCTAssertFalse(engine.state.inCombat)
        XCTAssertEqual(engine.state.varatroFallsPhase, .recovered)
    }

    func testOceandaleScoutBypassesWaveOne() {
        var state = SoCGameState()
        state.applyClass(.scout)
        state.currentRoom = .oceandaleFront
        state.oceandaleFrontPhase = .charge
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("scout")

        XCTAssertEqual(engine.state.oceandaleFrontPhase, .betweenWaves)
        XCTAssertFalse(engine.state.inCombat)
    }

    func testMageOutpostGuardianIntel() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.oceandaleFrontCleared = true
        state.currentRoom = .mageOutpost
        state.mageOutpostPhase = .infiltration
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("shield")

        XCTAssertTrue(engine.state.mageOutpostCleared)
        XCTAssertFalse(engine.state.inCombat)
    }

    func testOceandalePaladinPrepWeakensFight() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.currentRoom = .oceandaleFront
        state.oceandaleFrontPhase = .betweenWaves
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("hunt")
        XCTAssertEqual(engine.state.oceandalePaladinAdvantage, .hunterOpening)

        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.inCombat)
        XCTAssertEqual(engine.state.enemy?.hp, 17)
        XCTAssertEqual(engine.state.oceandalePaladinAdvantage, .none)
    }

    func testOceandaleGuardianPrepRefreshesBlock() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.currentRoom = .oceandaleFront
        state.oceandaleFrontPhase = .betweenWaves
        state.combatGuardianBlockAvailable = false
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("shield")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.combatGuardianBlockAvailable)
    }

    func testClassIngenuityQuickVerb() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.currentRoom = .varatroFalls
        state.varatroFallsPhase = .tomb
        XCTAssertEqual(SoCClassIngenuity.quickVerb(for: state), "Hunt")
    }
}
