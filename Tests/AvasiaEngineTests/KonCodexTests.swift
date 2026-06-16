import XCTest
@testable import AvasiaEngine

final class KonCodexTests: XCTestCase {

    func testFreshGameLocksAllEntries() {
        let state = GameState()
        XCTAssertEqual(KonCodex.unlockedCount(for: state), 0)
        for entry in KonCodexEntry.allCases {
            XCTAssertFalse(KonCodex.isUnlocked(entry, state: state), "\(entry) should be locked")
        }
    }

    func testMagehouseProgressUnlocksOldMageAndQuest() {
        var state = GameState()
        state.gain(.levitate)
        XCTAssertTrue(KonCodex.isUnlocked(.oldMage, state: state))
        XCTAssertTrue(KonCodex.isUnlocked(.mageQuest, state: state))
        XCTAssertFalse(KonCodex.isUnlocked(.vashirr, state: state))
    }

    func testGateGuardUnlocksSchismLoreTogether() {
        var state = GameState()
        state.gateGuardLoreHeard = true
        XCTAssertTrue(KonCodex.isUnlocked(.gateGuard, state: state))
        XCTAssertTrue(KonCodex.isUnlocked(.schismLore, state: state))
    }

    func testCampaignProgressUnlockChain() {
        var state = GameState()
        state.gain(.metDentros)
        XCTAssertTrue(KonCodex.isUnlocked(.dentros, state: state))

        state.gain(.forestLoreHeard)
        XCTAssertTrue(KonCodex.isUnlocked(.sylvianPriestess, state: state))

        state.gain(.dagger)
        XCTAssertTrue(KonCodex.isUnlocked(.suformin, state: state))

        state.gain(.stonebend)
        XCTAssertTrue(KonCodex.isUnlocked(.silvariumSeal, state: state))

        state.cataractaGateDone = true
        XCTAssertTrue(KonCodex.isUnlocked(.cataractaGate, state: state))

        state.teleporterDiscovered = true
        XCTAssertTrue(KonCodex.isUnlocked(.vashirr, state: state))
        XCTAssertTrue(KonCodex.isUnlocked(.memoryFlash, state: state))

        state.metThekia = true
        XCTAssertTrue(KonCodex.isUnlocked(.thekia, state: state))
        XCTAssertTrue(KonCodex.isUnlocked(.nacastrumReturn, state: state))

        state.aylovaRallySeen = true
        XCTAssertTrue(KonCodex.isUnlocked(.father, state: state))

        state.gameComplete = true
        XCTAssertTrue(KonCodex.isUnlocked(.victory, state: state))
    }

    func testTimelineEntriesAreChronological() {
        let ordered = KonCodex.timelineEntries(for: GameState())
        let orders = ordered.compactMap(\.timelineOrder)
        XCTAssertEqual(orders, orders.sorted())
        XCTAssertTrue(ordered.contains(.beachAwakening))
        XCTAssertTrue(ordered.contains(.victory))
    }

    func testEntriesForCategoryPartitionAllCases() {
        let characters = KonCodex.entries(for: .character)
        let beats = KonCodex.entries(for: .storyBeat)
        XCTAssertEqual(characters.count + beats.count, KonCodexEntry.allCases.count)
        XCTAssertTrue(characters.allSatisfy { $0.category == .character })
        XCTAssertTrue(beats.allSatisfy { $0.category == .storyBeat })
    }

    func testLockedEntriesExposeHints() {
        for entry in KonCodexEntry.allCases {
            XCTAssertFalse(entry.lockedHint.isEmpty, "\(entry) needs a locked hint")
        }
    }

    func testVictoryDoesNotUnlockFullCodex() {
        var state = GameState()
        state.gameComplete = true
        XCTAssertTrue(KonCodex.isUnlocked(.victory, state: state))
        XCTAssertLessThan(KonCodex.unlockedCount(for: state), KonCodexEntry.allCases.count)
    }
}
