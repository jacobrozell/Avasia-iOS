import Foundation
import AvasiaEngine

public enum AnthologyAlignment: String, Codable, Sendable {
    case none
    case loyalist
    case agroman
    case neutral
}

public enum AnthologyParleyPhase: String, Codable, Sendable {
    case notStarted
    case arrival
    case schism
    case doctrine
    case offer
    case done
}

public enum ScoutRidgeOutcome: String, Codable, Sendable {
    case captured
    case withdrew
}

public enum MiraStatus: String, Codable, Sendable {
    case partner
    case brokeAway
    case unknown
}

public struct AnthologyGameState: Codable, Sendable {
    public var currentRoom: AnthologyRoomID = .storyHub
    public var textDelay: TextDelay = .on
    public var factionPoints: Int = 0
    public var alignment: AnthologyAlignment = .none
    public var currentStory: AnthologyStoryID?
    public var completedStories: Set<AnthologyStoryID> = []
    /// FP granted once per story (replay does not re-award).
    public var storiesRewarded: Set<AnthologyStoryID> = []

    // Story #0
    public var parleyPhase: AnthologyParleyPhase = .notStarted
    public var forkResolved = false
    public var storyZeroComplete = false
    public var ridgeOutcome: ScoutRidgeOutcome = .captured
    public var miraStatus: MiraStatus = .partner
    public var parleyHeardFullSermon = false
    public var scoutSignalSent = false

    // Good #1
    public var goodOnePierResolved = false
    public var goodOneEvacuatedPier = false
    public var goodOneComplete = false

    // Good #2
    public var goodTwoGateResolved = false
    public var goodTwoFullTruth = false
    public var goodTwoComplete = false

    // Bad #2
    public var badTwoBriefingResolved = false
    public var badTwoSanitizedReport = false
    public var badTwoComplete = false

    // Bad #1
    public var badOneReconResolved = false
    public var badOneTruthfulRecon = false
    public var badOneComplete = false

    // Elk Feast
    public var elkFeastComplete = false

    // Neutral #2 — Cave Record
    public var caveRecordArchiveResolved = false
    public var caveRecordCopiedArchive = false
    public var caveRecordComplete = false

    // Arena (training mode)
    public var anthologyGold: Int = 0
    public var arenaUpgrades: Set<AnthologyTrainingUpgrade> = []
    public var arenaRunActive = false
    public var arenaWave: Int = 0
    public var arenaHp: Int = 20
    public var arenaInCombat = false
    public var arenaEnemyHp: Int = 0
    public var arenaEnemyAtk: Int = 0
    public var arenaEnemyName: String = ""
    public var arenaFirstClearDone = false

    // Good #3
    public var goodThreeVerdictResolved = false
    public var goodThreePublicTestimony = false
    public var goodThreeComplete = false

    // Bad #3
    public var badThreeOathResolved = false
    public var badThreeSworeOath = false
    public var badThreeComplete = false

    // Neutral #3
    public var neutralThreeStallResolved = false
    public var neutralThreeBrokersPeace = false
    public var neutralThreeComplete = false

    // Good #4
    public var goodFourBriefingResolved = false
    public var goodFourHoldLine = false
    public var goodFourComplete = false

    // Bad #4
    public var badFourGateResolved = false
    public var badFourMeasuredAssault = false
    public var badFourComplete = false

    // Neutral #4
    public var neutralFourCrowdResolved = false
    public var neutralFourStayedWitness = false
    public var neutralFourComplete = false

    // Ring passes (gold shop — excuse one FP unlock each)
    public var ringPasses: Int = 0
    public var ringPassLastGrantDay: String?

    public init() {}

    public var arenaMaxHp: Int {
        20 + (arenaUpgrades.contains(.sturdyBoots) ? 5 : 0)
    }

    public var arenaPlayerDamageRange: ClosedRange<Int> {
        let low = arenaUpgrades.contains(.whetstone) ? 3 : 2
        return low...6
    }

    public func arenaMitigatedEnemyDamage(_ raw: Int) -> Int {
        let reduced = raw - (arenaUpgrades.contains(.trainingMail) ? 1 : 0)
        return max(1, reduced)
    }

    public mutating func resetAllProgress() {
        self = AnthologyGameState()
    }

    public mutating func resetActiveStoryProgress() {
        clearInProgressStoryFlags()
        goodOneEvacuatedPier = false
        goodTwoFullTruth = false
        badTwoSanitizedReport = false
        badOneTruthfulRecon = false
        caveRecordCopiedArchive = false
        goodThreePublicTestimony = false
        badThreeSworeOath = false
        neutralThreeBrokersPeace = false
        goodFourHoldLine = false
        badFourMeasuredAssault = false
        neutralFourStayedWitness = false
    }

    /// Clears room-phase flags when a story ends; keeps outcome choices for debrief/replay memory.
    public mutating func clearInProgressStoryFlags() {
        parleyPhase = .notStarted
        forkResolved = false
        goodOnePierResolved = false
        goodTwoGateResolved = false
        badTwoBriefingResolved = false
        badOneReconResolved = false
        caveRecordArchiveResolved = false
        goodThreeVerdictResolved = false
        badThreeOathResolved = false
        neutralThreeStallResolved = false
        goodFourBriefingResolved = false
        badFourGateResolved = false
        neutralFourCrowdResolved = false
    }

    public mutating func resetArenaRun() {
        arenaRunActive = false
        arenaWave = 0
        arenaHp = arenaMaxHp
        arenaInCombat = false
        arenaEnemyHp = 0
        arenaEnemyAtk = 0
        arenaEnemyName = ""
    }

    public mutating func beginArenaRun() {
        resetArenaRun()
        arenaRunActive = true
        arenaWave = 1
    }

    public mutating func prepareStoryZeroReplay() {
        resetActiveStoryProgress()
        ridgeOutcome = .captured
        miraStatus = .partner
        parleyHeardFullSermon = false
        scoutSignalSent = false
        currentStory = .storyZero
    }
}
