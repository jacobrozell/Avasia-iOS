import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

final class SoCEngineTests: XCTestCase {
    func testCourtyardClassPickOnFirstCommand() {
        var state = SoCGameState()
        state.currentRoom = .cataractaCourtyard
        let room = SoCCourtyardRoom()

        let result = room.handle(Parser.parse("wolf", mode: .normalized), &state)

        XCTAssertEqual(state.playerClass, .hunter)
        XCTAssertEqual(state.courtyardPhase, .combat1)
        XCTAssertTrue(state.inCombat)
        XCTAssertFalse(result.playerDied)
        XCTAssertTrue(result.lines.contains { $0.text.contains("Kimious") })
        XCTAssertTrue(result.lines.contains { $0.text.contains("Dentros") })
    }

    func testGardenLookMentionsRequisition() {
        var state = SoCGameState()
        state.currentRoom = .cataractaGarden
        let engine = SoCGameEngine(state: state)

        let lines = engine.submit("look")

        XCTAssertTrue(lines.contains { $0.text.contains("requisition") })
        XCTAssertTrue(lines.contains { $0.text.contains("Gift becomes ledger") })
    }

    func testCourtyardMassacreEndsInPortalRoom() {
        var state = SoCGameState()
        state.currentRoom = .cataractaCourtyard
        state.inventory[.potion] = 2
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("bear")
        engine.fightToVictory()
        engine.fightToVictory()

        XCTAssertTrue(engine.state.courtyardComplete)
        XCTAssertEqual(engine.state.currentRoom, .portalRoom)
        XCTAssertEqual(engine.state.playerClass, .guardian)
    }

    func testPortalBooksReachLibrary() {
        var state = SoCGameState()
        state.currentRoom = .portalRoom
        state.playerClass = .guardian
        let room = SoCPortalRoom()

        let result = room.handle(Parser.parse("move books", mode: .raw), &state)

        XCTAssertTrue(state.portalRoom)
        if case .move(.library) = result.transition {
            XCTAssertTrue(result.lines.contains { $0.text.contains("library") })
        } else {
            XCTFail("Expected move to library")
        }
    }

    func testPortalVentBlockedForScout() {
        var state = SoCGameState()
        state.currentRoom = .portalRoom
        state.playerClass = .scout
        state.ventFound = true
        let room = SoCPortalRoom()

        let result = room.handle(Parser.parse("vent", mode: .raw), &state)

        XCTAssertEqual(result.transition, SoCTransition.stay)
        XCTAssertTrue(result.lines.contains { $0.text.contains("reach") })
    }

    func testPortalFirstVisitMentionsMission() {
        var state = SoCGameState()
        state.courtyardComplete = true
        state.currentRoom = .portalRoom
        let room = SoCPortalRoom()

        let lines = room.describe(state)

        XCTAssertTrue(lines.contains { $0.text.contains("Vashirr") })
        XCTAssertTrue(lines.contains { $0.text.contains("Kaefden") })
    }

    func testAthalosLookMentionsLedger() {
        var state = SoCGameState()
        state.athalosVisitCount = 2
        state.currentRoom = .cataractaAthalos
        let engine = SoCGameEngine(state: state)

        let lines = engine.submit("look")

        XCTAssertTrue(lines.contains { $0.text.contains("ledger") || $0.text.contains("Ledger") })
    }

    func testThroneAudienceCompletes() {
        var state = SoCGameState()
        state.applyClass(.scout)
        state.playerName = "Lira"
        state.currentRoom = .westHallway
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("east")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.throneAudience)
        XCTAssertTrue(engine.state.warCampBriefed)
        XCTAssertTrue(engine.state.metThekia)
    }

    func testThroneEpilogueAfterComplete() {
        var state = SoCGameState()
        state.throneAudience = true
        state.currentRoom = .throneRoom
        let engine = SoCGameEngine(state: state)
        let lines = engine.submit("continue")
        XCTAssertTrue(lines.contains { $0.text.contains("Aylova") })
    }

    func testThroneMarchesToAylova() {
        var state = SoCGameState()
        state.throneAudience = true
        state.currentRoom = .throneRoom
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("march")
        XCTAssertEqual(engine.state.currentRoom, .aylovaWarCamp)
    }

    func testAylovaCampReachesSilvarium() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.warCampBriefed = true
        state.currentRoom = .aylovaWarCamp
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        _ = engine.submit("continue")

        XCTAssertTrue(engine.state.aylovaProvisioned)
        XCTAssertTrue(engine.state.aylovaMusterComplete)
        XCTAssertEqual(engine.state.currentRoom, .silvariumElders)
    }

    func testNorthernMarchPatrolCombat() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.aylovaMusterComplete = true
        state.ofelosAllianceComplete = true
        state.currentRoom = .northernMarch
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.inCombat)

        while engine.state.inCombat {
            _ = engine.submit("attack")
        }

        XCTAssertFalse(engine.state.inCombat)
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.northernMarchCleared)
    }

    func testHunterPathLeaveReturns() {
        let engine = SoCGameEngine()
        engine.load(SoCGameState())

        _ = engine.submit("west")
        XCTAssertEqual(engine.state.currentRoom, .cataractaHunterPath)
        XCTAssertTrue(engine.state.hunterPathVisited)

        _ = engine.submit("leave")
        XCTAssertEqual(engine.state.currentRoom, .cataractaHousing)
    }

    func testHunterPathHunterLookMentionsWolfCry() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.currentRoom = .cataractaHunterPath
        let engine = SoCGameEngine(state: state)

        let lines = engine.submit("look")

        XCTAssertEqual(engine.state.playerClass, .hunter)
        XCTAssertTrue(lines.contains { $0.text.contains("wolf") && $0.text.contains("treeline") })
    }

    func testWestHallwayLookForeshadowsPortal() {
        var state = SoCGameState()
        state.currentRoom = .westHallway
        let room = SoCCataractaWestHallway()

        let result = room.handle(Parser.parse("look", mode: .normalized), &state)

        XCTAssertTrue(result.lines.contains { $0.text.contains("portal room") })
        XCTAssertTrue(result.lines.contains { $0.text.contains("fountain cracked") })
    }

    func testAthalosShopOnReturnVisit() {
        var state = SoCGameState()
        state.currentRoom = .cataractaShopping
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("south")
        XCTAssertEqual(engine.state.currentRoom, .cataractaShopping)

        _ = engine.submit("south")
        XCTAssertEqual(engine.state.currentRoom, .cataractaAthalos)

        let goldBefore = engine.state.gold
        _ = engine.submit("buy potion")
        XCTAssertEqual(engine.state.gold, goldBefore - 25)
        XCTAssertEqual(engine.state.inventory[.potion], 2)
    }

    func testVarathoBridgeGrantsExpOnce() {
        let engine = SoCGameEngine()
        engine.load(SoCGameState())

        _ = engine.submit("north")
        XCTAssertTrue(engine.state.varathoCrossed)
        XCTAssertGreaterThan(engine.state.questExp, 0)

        let exp = engine.state.questExp
        _ = engine.submit("south")
        _ = engine.submit("north")
        XCTAssertEqual(engine.state.questExp, exp)
    }

    func testBarracksGuardGossip() {
        var state = SoCGameState()
        state.currentRoom = .cataractaNorth
        let engine = SoCGameEngine(state: state)

        _ = engine.submit("west")
        _ = engine.submit("talk")
        XCTAssertTrue(engine.state.barracksTalked)
        XCTAssertGreaterThan(engine.state.questExp, 0)
    }

    func testAthalosAutoReturns() {
        let engine = SoCGameEngine()
        engine.load(SoCGameState())
        _ = engine.submit("east")
        _ = engine.submit("south")
        XCTAssertEqual(engine.state.currentRoom, .cataractaShopping)
    }

    func testUlricSetsReferralFlag() {
        var state = SoCGameState()
        state.currentRoom = .cataractaShopping
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("east")
        XCTAssertTrue(engine.state.ulric)
    }

    func testPierFreeFishingViaUlric() {
        var state = SoCGameState()
        state.ulric = true
        state.currentRoom = .cataractaPier
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("yes")
        XCTAssertEqual(engine.state.currentRoom, .cataractaFishing)
        XCTAssertTrue(engine.state.trophies.contains(.brother))
    }

    func testGlobalInventoryListsGold() {
        let engine = SoCGameEngine()
        let lines = engine.submit("inventory")
        XCTAssertTrue(lines.contains { $0.text.contains("Gold: 100") })
        XCTAssertTrue(lines.contains { $0.text.contains("Potion") })
    }

    func testEatPotionAfterClass() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.playerHp = 5
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("eat potion")
        XCTAssertEqual(engine.state.playerHp, 15)
        XCTAssertEqual(engine.state.inventory[.potion, default: 0], 0)
    }

    func testLibraryLookGrantsExpOnce() {
        var state = SoCGameState()
        state.currentRoom = .library
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("look")
        XCTAssertEqual(engine.state.questExp, 15)
        _ = engine.submit("look")
        XCTAssertEqual(engine.state.questExp, 15)
    }

    func testScoutStealthClearsMageOutpost() {
        var state = SoCGameState()
        state.applyClass(.scout)
        state.oceandaleFrontCleared = true
        state.currentRoom = .mageOutpost
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("continue")
        _ = engine.submit("scout")
        XCTAssertTrue(engine.state.mageOutpostCleared)
        XCTAssertEqual(engine.state.mageOutpostPhase, .done)
    }

    func testGameCompleteEpilogue() {
        var state = SoCGameState()
        state.playerName = "Aria"
        state.vashirrDefeated = true
        state.currentRoom = .ageEpilogue
        let engine = SoCGameEngine(state: state)
        _ = engine.submit("continue")
        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.gameComplete)
        XCTAssertTrue(engine.state.trophies.contains(.ageComplete))
    }

    func testCodexUnlocksFromSaveFlags() {
        var fresh = SoCGameState()
        XCTAssertFalse(SoCCodex.isUnlocked(.ulric, state: fresh))
        fresh.ulric = true
        XCTAssertTrue(SoCCodex.isUnlocked(.ulric, state: fresh))

        fresh.courtyardComplete = true
        XCTAssertTrue(SoCCodex.isUnlocked(.courtyardMassacre, state: fresh))
        XCTAssertTrue(SoCCodex.isUnlocked(.enlistment, state: fresh))
        XCTAssertTrue(SoCCodex.isUnlocked(.kimious, state: fresh))
        XCTAssertFalse(SoCCodex.isUnlocked(.campaignComplete, state: fresh))

        let before = SoCCodex.unlockedCount(for: fresh)
        XCTAssertEqual(before, 4, "ulric, kimious, enlistment, courtyardMassacre")

        fresh.gameComplete = true
        XCTAssertTrue(SoCCodex.isUnlocked(.campaignComplete, state: fresh))
        XCTAssertEqual(SoCCodex.unlockedCount(for: fresh), before + 1)
        XCTAssertLessThan(SoCCodex.unlockedCount(for: fresh), SoCCodexEntry.allCases.count)
    }

    func testVashirrStandCombatThenContinueDefeatsVashirr() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.playerName = "Hero"
        state.vashirrStandPhase = .finalCombat
        state.currentRoom = .vashirrStand
        state.inventory[.potion] = 3
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Vashirr's War Mage", atk: 11, speed: 8, hp: 28, luck: 6),
            deathText: "The war mage's bolt tears through your line.",
            state: &state
        )
        let engine = SoCGameEngine(state: state)

        engine.fightToVictory()
        XCTAssertEqual(engine.state.vashirrStandPhase, .resolution)
        XCTAssertFalse(engine.state.vashirrDefeated)

        _ = engine.submit("continue")
        XCTAssertTrue(engine.state.vashirrDefeated)
        XCTAssertEqual(engine.state.vashirrStandPhase, .done)
    }

    private func fightUntilClear(_ engine: SoCGameEngine) {
        engine.fightToVictory()
    }
}
