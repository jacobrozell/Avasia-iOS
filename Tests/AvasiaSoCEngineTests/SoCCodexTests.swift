import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

final class SoCCodexTests: XCTestCase {

    func testFreshGameLocksAllEntries() {
        let state = SoCGameState()
        XCTAssertEqual(SoCCodex.unlockedCount(for: state), 0)
        for entry in SoCCodexEntry.allCases {
            XCTAssertFalse(SoCCodex.isUnlocked(entry, state: state), "\(entry) should be locked")
        }
    }

    func testActOneCharacterUnlocks() {
        var state = SoCGameState()
        state.ulric = true
        state.doran = true
        XCTAssertTrue(SoCCodex.isUnlocked(.ulric, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.doran, state: state))
        XCTAssertFalse(SoCCodex.isUnlocked(.thekia, state: state))
    }

    func testCourtyardCompleteUnlocksKimiousAndMassacre() {
        var state = SoCGameState()
        state.courtyardComplete = true
        XCTAssertTrue(SoCCodex.isUnlocked(.kimious, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.courtyardMassacre, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.enlistment, state: state))
    }

    func testEnlistmentUnlocksFromClassAlone() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        XCTAssertTrue(SoCCodex.isUnlocked(.enlistment, state: state))
        XCTAssertFalse(SoCCodex.isUnlocked(.courtyardMassacre, state: state))
    }

    func testWarCampaignUnlockChain() {
        var state = SoCGameState()
        state.applyClass(.scout)
        state.metThekia = true
        state.throneAudience = true
        state.throneRecountStyle = .honorDentros
        state.aylovaMusterComplete = true
        state.silvariumEldersPhase = .audience
        state.varatroFallsCleared = true
        state.ofelosAllianceComplete = true
        state.vashirrDefeated = true

        XCTAssertTrue(SoCCodex.isUnlocked(.thekia, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.kaefden, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.dentros, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.throneAudience, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.warCamp, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.sylvianElders, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.bladeRecovered, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.ofelosAlliance, state: state))
        XCTAssertTrue(SoCCodex.isUnlocked(.vashirrFall, state: state))
        XCTAssertFalse(SoCCodex.isUnlocked(.campaignComplete, state: state))
    }

    func testVashirrUnlocksWhenStandPhaseBegins() {
        var state = SoCGameState()
        state.vashirrStandPhase = .arrival
        XCTAssertTrue(SoCCodex.isUnlocked(.vashirr, state: state))
    }

    func testBladeRecoveredViaTrophy() {
        var state = SoCGameState()
        state.unlockTrophy(.bladeBearer)
        XCTAssertTrue(SoCCodex.isUnlocked(.bladeRecovered, state: state))
    }

    func testEntriesForCategoryPartitionAllCases() {
        let characters = SoCCodex.entries(for: .character)
        let beats = SoCCodex.entries(for: .storyBeat)
        XCTAssertEqual(characters.count + beats.count, SoCCodexEntry.allCases.count)
    }

    func testLockedEntriesExposeHints() {
        for entry in SoCCodexEntry.allCases {
            XCTAssertFalse(entry.lockedHint.isEmpty, "\(entry) needs a locked hint")
        }
    }

    func testGameCompleteOnlyAddsCampaignBeat() {
        var state = SoCGameState()
        state.ulric = true
        state.courtyardComplete = true
        let before = SoCCodex.unlockedCount(for: state)
        state.gameComplete = true
        XCTAssertEqual(SoCCodex.unlockedCount(for: state), before + 1)
        XCTAssertTrue(SoCCodex.isUnlocked(.campaignComplete, state: state))
    }
}
