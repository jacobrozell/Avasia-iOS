import Foundation

/// The achievement catalog. Criteria live in `AchievementTracker`; this enum
/// holds presentation metadata. Secret achievements hide their description (and
/// optionally their name) until unlocked. See docs/ACHIEVEMENTS.md.
public enum Achievement: String, Codable, CaseIterable, Sendable {
    // Progression
    case firstSteps        // learn Levitate
    case armed             // take the Long Sword
    case firekeeper        // learn Inflame
    case earthshaper       // learn Stonebend
    case fullArsenal       // know all three spells
    case kingOfNacastrum   // complete the game

    // Exploration
    case druidFriend       // meet Dentros (gain the lantern)
    case wanderer          // visit 8 distinct regions
    case worldsEnd         // visit every region

    // Flavor / secret
    case meaningOfLife     // hear "42"
    case goldRush          // catch the golden fish
    case persistentAngler  // throw back the orange fish three times

    // Death (mostly secret — discovered by dying)
    case firstBlood        // die for the first time
    case intoTheDeep       // die in the chasm
    case crabDinner        // die to the fishing crab
    case swallowedWhole    // die to the sea serpent
    case pointedEnd        // die to the cave stalactites
    case tooGreedy         // die mining the crystals
    case theWrongCut       // die cutting your neck
    case ambushed          // die in the road ambush
    case burnedToAsh       // die at the fireball pedestal
    case martyr            // die 10 times (lifetime)

    public var title: String {
        switch self {
        case .firstSteps:       return "First Steps"
        case .armed:            return "Armed"
        case .firekeeper:       return "Firekeeper"
        case .earthshaper:      return "Earthshaper"
        case .fullArsenal:      return "Full Arsenal"
        case .kingOfNacastrum:  return "King of Nacastrum"
        case .druidFriend:      return "Friend of the Druids"
        case .wanderer:         return "Wanderer"
        case .worldsEnd:        return "To the World's End"
        case .meaningOfLife:    return "The Meaning of Life"
        case .goldRush:         return "Gold Rush"
        case .persistentAngler: return "Persistent Angler"
        case .firstBlood:       return "First Blood"
        case .intoTheDeep:      return "Into the Deep"
        case .crabDinner:       return "Crab Dinner"
        case .swallowedWhole:   return "Swallowed Whole"
        case .pointedEnd:       return "A Pointed End"
        case .tooGreedy:        return "Too Greedy"
        case .theWrongCut:      return "The Wrong Cut"
        case .ambushed:         return "Ambushed"
        case .burnedToAsh:      return "Burned to Ash"
        case .martyr:           return "Martyr"
        }
    }

    public var detail: String {
        switch self {
        case .firstSteps:       return "Learn the spell Levitate."
        case .armed:            return "Take the Long Sword."
        case .firekeeper:       return "Learn the spell Inflame."
        case .earthshaper:      return "Learn the spell Stonebend."
        case .fullArsenal:      return "Master all three spells."
        case .kingOfNacastrum:  return "Reunite the mages and reclaim Nacastrum."
        case .druidFriend:      return "Earn Dentros's trust and his lantern."
        case .wanderer:         return "Visit eight distinct regions of Avasia."
        case .worldsEnd:        return "Set foot in every region of Avasia."
        case .meaningOfLife:    return "Ask the right question of the right priestess."
        case .goldRush:         return "Reel in a fish worth a fortune."
        case .persistentAngler: return "Throw back the useless orange fish three times."
        case .firstBlood:       return "Die for the first time."
        case .intoTheDeep:      return "Test the depth of the chasm. Personally."
        case .crabDinner:       return "Become a meal for a crab."
        case .swallowedWhole:   return "Disturb something far larger than a fish."
        case .pointedEnd:       return "Discover what hangs from a cave ceiling."
        case .tooGreedy:        return "Mine the crystals, despite the warning."
        case .theWrongCut:      return "Bring the wrong part of yourself to the seal."
        case .ambushed:         return "Fall to the Agromanians on the road."
        case .burnedToAsh:      return "Run out of guesses at the pedestal."
        case .martyr:           return "Die ten times across your attempts."
        }
    }

    /// Secret achievements hide their detail until unlocked.
    public var isSecret: Bool {
        switch self {
        case .firstSteps, .armed, .firekeeper, .earthshaper, .fullArsenal,
             .kingOfNacastrum, .druidFriend, .wanderer, .worldsEnd:
            return false
        default:
            return true   // flavor & death achievements are surprises
        }
    }
}

/// Persistent, cross-run achievement progress. Unlike `GameState` (which resets
/// each new game), this accumulates over the player's lifetime and is saved
/// separately (see `SaveStore`).
public struct AchievementState: Codable, Sendable {
    public var unlocked: Set<Achievement> = []
    public var totalDeaths: Int = 0
    public var regionsVisited: Set<Region> = []
    public var orangeFishTossed: Int = 0

    public init() {}

    public func has(_ a: Achievement) -> Bool { unlocked.contains(a) }
    public var unlockedCount: Int { unlocked.count }
    public var total: Int { Achievement.allCases.count }
}
