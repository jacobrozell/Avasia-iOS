import Foundation
import AvasiaEngine

public enum DruidClass: String, Codable, Sendable {
    case none
    case hunter
    case guardian
    case scout
}

public enum CourtyardPhase: String, Codable, Sendable {
    case notStarted
    case pickClass
    case preBattle
    case combat1
    case betweenCombats
    case combat2
    case vashirrScene
    case ashes
    case done
}

public struct SoCCombatant: Codable, Sendable, Equatable {
    public var name: String
    public var atk: Int
    public var speed: Int
    public var hp: Int
    public var maxHp: Int
    public var luck: Int

    public init(name: String, atk: Int, speed: Int, hp: Int, luck: Int = 3) {
        self.name = name
        self.atk = atk
        self.speed = speed
        self.hp = hp
        self.maxHp = hp
        self.luck = luck
    }

    public var isDead: Bool { hp <= 0 }
}

/// Serializable state for Blade of Courage. Mirrors Python `config.py` + player stats.
public struct SoCGameState: Codable, Sendable {
    public var currentRoom: SoCRoomID = .cataractaHousing
    public var textDelay: TextDelay = .on
    public var playerName: String = ""

    public var playerClass: DruidClass = .none
    public var playerAtk: Int = 0
    public var playerSpeed: Int = 0
    public var playerHp: Int = 0
    public var playerMaxHp: Int = 0
    public var playerLuck: Int = 0
    public var gold: Int = 100
    public var inventory: [SoCItem: Int] = [:]
    public var trophies: Set<SoCTrophy> = []

    public var fountain: Bool = false
    public var fountainLuck: Bool = false
    public var gardenInsight: Bool = false
    public var varathoCrossed: Bool = false
    public var barracksTalked: Bool = false
    public var hunterPathVisited: Bool = false
    public var actOneIntroShown: Bool = false
    public var athalosVisitCount: Int = 0
    public var ulric: Bool = false
    public var doran: Bool = false
    public var portalRoom: Bool = false
    public var ventFound: Bool = false
    public var libraryLooked: Bool = false
    public var courtyardComplete: Bool = false
    public var metThekia: Bool = false
    public var throneAudience: Bool = false
    public var warCampBriefed: Bool = false
    public var thronePhase: ThronePhase = .notStarted
    public var throneRecountStyle: ThroneRecountStyle = .none
    public var ruinsVisited: Bool = false
    public var warCampPhase: WarCampPhase = .notStarted
    public var aylovaProvisioned: Bool = false
    public var aylovaMusterComplete: Bool = false
    public var silvariumEldersPhase: SilvariumEldersPhase = .notStarted
    public var silvariumEldersComplete: Bool = false
    public var varatroFallsPhase: VaratroFallsPhase = .notStarted
    public var varatroFallsCleared: Bool = false
    public var ofelosPhase: OfelosPhase = .notStarted
    public var ofelosAllianceComplete: Bool = false
    public var northernMarchPhase: NorthernMarchPhase = .notStarted
    public var northernMarchCleared: Bool = false
    public var oceandaleFrontPhase: OceandaleFrontPhase = .notStarted
    public var oceandaleFrontCleared: Bool = false
    public var oceandalePaladinAdvantage: OceandalePaladinAdvantage = .none
    public var mageOutpostPhase: MageOutpostPhase = .notStarted
    public var mageOutpostCleared: Bool = false
    public var vashirrStandPhase: VashirrStandPhase = .notStarted
    public var vashirrDefeated: Bool = false
    public var ageEpiloguePhase: AgeEpiloguePhase = .notStarted
    public var gameComplete: Bool = false

    public var courtyardPhase: CourtyardPhase = .notStarted
    public var inCombat: Bool = false
    public var combatAllowsFlee: Bool = false
    public var combatHunterStrikeUsed: Bool = false
    public var combatGuardianBlockAvailable: Bool = false
    public var combatScoutEdgeUsed: Bool = false
    public var enemy: SoCCombatant?
    public var enemyDeathText: String = ""
    public var neededLuckToHit: Int = 5
    public var playerAttacksFirst: Bool = true

    public var deathCount: Int = 0
    public var scoutShortcut: Bool = false
    public var questExpHintShown: Bool = false
    public var playerLevel: Int = 1
    public var questExp: Int = 0

    public var fishingSession: SoCFishingSession?

    public init() {
        inventory[.potion] = 1
    }
}

public extension SoCGameState {
    mutating func applyClass(_ cls: DruidClass) {
        playerClass = cls
        switch cls {
        case .hunter:
            playerAtk = 10; playerSpeed = 10; playerMaxHp = 20; playerLuck = 5
        case .scout:
            playerAtk = 15; playerSpeed = 15; playerMaxHp = 15; playerLuck = 5
        case .guardian:
            playerAtk = 10; playerSpeed = 1; playerMaxHp = 25; playerLuck = 5
        case .none:
            break
        }
        playerHp = playerMaxHp
    }

    mutating func restoreHealthToMax() {
        playerHp = playerMaxHp
    }

    func isFasterThanEnemy() -> Bool {
        guard let enemy else { return true }
        return playerSpeed >= enemy.speed
    }

    func playerLuckBeatsRoll() -> Bool {
        playerLuck >= neededLuckToHit
    }

    func enemyLuckBeatsRoll() -> Bool {
        guard let enemy else { return false }
        return enemy.luck >= neededLuckToHit
    }
}
