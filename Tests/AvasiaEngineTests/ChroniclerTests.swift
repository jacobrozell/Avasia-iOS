import XCTest
@testable import AvasiaEngine

final class ChroniclerTests: XCTestCase {

    func testRankCurve() {
        XCTAssertEqual(ChroniclerRank.rank(from: 0), 1)
        XCTAssertEqual(ChroniclerRank.rank(from: 99), 1)
        XCTAssertEqual(ChroniclerRank.rank(from: 100), 2)
        XCTAssertEqual(ChroniclerRank.rank(from: 900), 4)
        XCTAssertEqual(ChroniclerRank.subtitle(for: 1), "Stranger")
        XCTAssertEqual(ChroniclerRank.subtitle(for: 10), "Chronicler")
    }

    func testProgressToNextRank() {
        let progress = ChroniclerRank.progressToNextRank(from: 250)
        XCTAssertGreaterThan(progress, 0)
        XCTAssertLessThan(progress, 1)
    }

    func testKonWinGrantsCompletionXP() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .kon, profile: &profile)
        var state = GameState()
        state.deathCount = 0

        let entries = SagaXPTracker.apply([.won], state: state, profile: &profile)

        XCTAssertEqual(profile.completionsKon, 1)
        XCTAssertEqual(profile.sagaXP, SagaXPTracker.konWinXP + SagaXPTracker.konCleanWinBonusXP)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.amount, SagaXPTracker.konWinXP + SagaXPTracker.konCleanWinBonusXP)
    }

    func testLifetimeSecretOnlyOnce() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .kon, profile: &profile)

        let first = SagaXPTracker.apply([.didBeachYoga], state: GameState(), profile: &profile)
        SagaXPTracker.beginRun(product: .kon, profile: &profile)
        let second = SagaXPTracker.apply([.didBeachYoga], state: GameState(), profile: &profile)

        XCTAssertEqual(first.count, 1)
        XCTAssertTrue(second.isEmpty)
        XCTAssertEqual(profile.sagaXP, 80)
    }

    func testDeathXPGrantCap() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .kon, profile: &profile)

        XCTAssertNotNil(SagaXPTracker.recordKonDeath(cause: .chasm, profile: &profile))
        XCTAssertNotNil(SagaXPTracker.recordKonDeath(cause: .crab, profile: &profile))
        XCTAssertNotNil(SagaXPTracker.recordKonDeath(cause: .ambush, profile: &profile))
        XCTAssertNil(SagaXPTracker.recordKonDeath(cause: .chasm, profile: &profile))

        XCTAssertEqual(profile.deathXPGrantsThisRun, 3)
        XCTAssertEqual(profile.sagaXP, 9)
    }

    func testAchievementClaimOnce() {
        var profile = SagaProfile()
        let first = SagaXPTracker.claimAchievement(.crowPose, profile: &profile)
        let second = SagaXPTracker.claimAchievement(.crowPose, profile: &profile)

        XCTAssertNotNil(first)
        XCTAssertNil(second)
        XCTAssertTrue(profile.achievementXPClaimed.contains("kon.crowPose"))
    }

    func testLedgerCap() {
        var profile = SagaProfile()
        profile.ledger = (0..<600).map { i in
            SagaXPEntry(label: "Line \(i)", amount: 1, category: .exploration)
        }
        SagaXPTracker.beginRun(product: .kon, profile: &profile)
        _ = SagaXPTracker.apply([.didBeachYoga], state: GameState(), profile: &profile)

        XCTAssertLessThanOrEqual(profile.ledger.count, SagaProfile.ledgerCap)
    }

    func testChroniclerUnlocksOpenInMVP() {
        let profile = SagaProfile()
        XCTAssertTrue(ChroniclerUnlocks.isUnlocked(.paladinClass, profile: profile))
        XCTAssertTrue(ChroniclerUnlocks.isUnlocked(.anthologyTier1, profile: profile))
    }

    func testSocWin() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .soc, profile: &profile)
        let entry = SagaXPTracker.recordSocWin(profile: &profile)
        XCTAssertNotNil(entry)
        XCTAssertEqual(profile.sagaXP, SagaXPTracker.socWinXP)
        XCTAssertEqual(profile.completionsSoc, 1)
    }

    func testAnthologyStoryXP() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .stories, profile: &profile)
        let entry = SagaXPTracker.recordAnthologyStoryComplete(
            storyKey: "story_zero",
            title: "Scout Patrol",
            profile: &profile
        )
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.amount, 120)
        XCTAssertEqual(profile.completionsStories, 1)
    }

    func testKonEngineYogaGrantsChroniclerXP() {
        var profile = SagaProfile()
        SagaXPTracker.beginRun(product: .kon, profile: &profile)
        let engine = GameEngine()
        engine.restart()
        _ = engine.submit("yoga")

        let yoga = SagaXPTracker.apply(engine.lastEvents, state: engine.state, profile: &profile)
        XCTAssertFalse(yoga.isEmpty)
        XCTAssertEqual(profile.sagaXP, 80)
    }
}
