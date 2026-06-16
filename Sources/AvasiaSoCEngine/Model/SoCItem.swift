import Foundation

public enum SoCItem: String, Codable, CaseIterable, Sendable {
    case potion
    case fieldRations
    case smallFish
    case bigFish
    case crab
    case oldShoe
    case bladeOfCourage

    public var displayName: String {
        switch self {
        case .potion: return "Potion"
        case .fieldRations: return "Field Rations"
        case .smallFish: return "Small Fish"
        case .bigFish: return "Big Fish"
        case .crab: return "Crab"
        case .oldShoe: return "Old-shoe"
        case .bladeOfCourage: return "Kaefden's Blade of Courage"
        }
    }

    public var healAmount: Int? {
        switch self {
        case .potion: return 10
        case .fieldRations: return 8
        case .smallFish: return 5
        case .bigFish: return 10
        case .crab: return 15
        case .oldShoe, .bladeOfCourage: return nil
        }
    }

    public var goldValue: Int {
        switch self {
        case .potion: return 25
        case .fieldRations: return 15
        case .smallFish: return 5
        case .bigFish: return 10
        case .crab: return 15
        case .oldShoe: return 2
        case .bladeOfCourage: return 0
        }
    }
}

public enum SoCTrophy: String, Codable, CaseIterable, Sendable {
    case startedAdventure
    case fished
    case brother
    case oceandaleVictor
    case ageComplete
    case returnedToAshes
    case bladeBearer
    case ofelosMarches

    public var title: String {
        switch self {
        case .startedAdventure: return "Started the Adventure"
        case .fished: return "Gone Fishin'"
        case .brother: return "Brotherly Love"
        case .oceandaleVictor: return "Ridge Held"
        case .ageComplete: return "Age of Courage"
        case .returnedToAshes: return "Returned to Ashes"
        case .bladeBearer: return "Blade Bearer"
        case .ofelosMarches: return "Neutrals United"
        }
    }

    public var detail: String {
        switch self {
        case .startedAdventure: return "Volunteer for Cataracta's Legion."
        case .fished: return "Exhaust your bait at Doran's pier."
        case .brother: return "Let Ulric send you to fish with Doran."
        case .oceandaleVictor: return "Break the Agromanian line at Oceandale ridge."
        case .ageComplete: return "See the Age-era war to its end."
        case .returnedToAshes: return "Return to Cataracta's ruins after victory."
        case .bladeBearer: return "Lift Kaefden's Blade from Varatro Falls."
        case .ofelosMarches: return "Win Ofelos to the coalition with the Blade."
        }
    }

    public var unlockHint: String {
        switch self {
        case .startedAdventure: return "Start a new game."
        case .fished: return "Fish until you run out of bait."
        case .brother: return "Visit Ulric, then accept Doran's free rod."
        case .oceandaleVictor: return "Clear the Oceandale war front."
        case .ageComplete: return "Finish Blade of Courage."
        case .returnedToAshes: return "Visit the ruins from the epilogue."
        case .bladeBearer: return "Clear Varatro Falls tomb."
        case .ofelosMarches: return "Present the Blade before Ofelos."
        }
    }
}

public enum ThroneRecountStyle: String, Codable, Sendable {
    case none
    case honorDentros
    case reportFacts
}

public enum ThronePhase: String, Codable, Sendable {
    case notStarted
    case atThrone
    case deliverVashirr
    case recountChoice
    case classService
    case done
}

public enum WarCampPhase: String, Codable, Sendable {
    case notStarted
    case arrived
    case briefing
    case quartermaster
    case readyToMarch
    case done
}

public enum NorthernMarchPhase: String, Codable, Sendable {
    case notStarted
    case refugees
    case patrolCombat
    case aftermath
    case done
}

public enum OceandaleFrontPhase: String, Codable, Sendable {
    case notStarted
    case staging
    case charge
    case combat1
    case betweenWaves
    case combat2
    case victory
    case done
}

/// Class ingenuity spent on the Paladin before wave two begins.
public enum OceandalePaladinAdvantage: String, Codable, Sendable {
    case none
    case scoutWardGap
    case hunterOpening
    case guardianBrace
}

public enum MageOutpostPhase: String, Codable, Sendable {
    case notStarted
    case approach
    case infiltration
    case combat
    case intel
    case done
}

public enum VashirrStandPhase: String, Codable, Sendable {
    case notStarted
    case arrival
    case confrontation
    case playerBeat
    case finalCombat
    case resolution
    case done
}

public enum AgeEpiloguePhase: String, Codable, Sendable {
    case notStarted
    case memorial
    case kaefdenSpeech
    case done
}

public enum SilvariumEldersPhase: String, Codable, Sendable {
    case notStarted
    case arrived
    case audience
    case commission
    case done
}

public enum VaratroFallsPhase: String, Codable, Sendable {
    case notStarted
    case approach
    case tomb
    case combat
    case recovered
    case done
}

public enum OfelosPhase: String, Codable, Sendable {
    case notStarted
    case gates
    case council
    case presentation
    case alliance
    case done
}

public struct SoCFishingSession: Codable, Sendable, Equatable {
    public var baitRemaining: Int
    public var caughtOldShoe: Bool = false
    public var caughtSmallFish: Bool = false
    public var caughtBigFish: Bool = false
    public var caughtCrab: Bool = false

    public init(baitRemaining: Int) {
        self.baitRemaining = baitRemaining
    }
}

public extension SoCGameState {
    mutating func addItem(_ item: SoCItem, count: Int = 1) {
        inventory[item, default: 0] += count
    }

    mutating func removeItem(_ item: SoCItem, count: Int = 1) -> Bool {
        guard let have = inventory[item], have >= count else { return false }
        inventory[item] = have - count
        if inventory[item] == 0 { inventory.removeValue(forKey: item) }
        return true
    }

    mutating func unlockTrophy(_ trophy: SoCTrophy) {
        trophies.insert(trophy)
    }

    mutating func addGold(_ amount: Int) {
        gold += amount
    }

    @discardableResult
    mutating func spendGold(_ amount: Int) -> Bool {
        guard gold >= amount else { return false }
        gold -= amount
        return true
    }
}
