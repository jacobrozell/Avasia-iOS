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
    case fullyLoaded       // all spells + all items
    case kingOfNacastrum   // complete the game
    case cleanCoronation   // win without dying that run

    // Exploration
    case druidFriend       // meet Dentros (gain the lantern)
    case wanderer          // visit 8 distinct regions
    case worldsEnd         // visit every region
    case schismScholar     // hear the gate guard's lore

    // Flavor / secret
    case meaningOfLife     // hear "42"
    case goldRush          // catch the golden fish
    case persistentAngler  // throw back the orange fish three times
    case crowPose          // yoga on the beach
    case thanksForHonesty  // NOIDEA at the fireball pedestal
    case againstInstinct   // swim through the dream bridge
    case alreadyLitFam     // relight lantern at the fireball pedestal
    case soleSurvivor      // reel in the old shoe
    case clawAndOrder      // survive the fishing crab
    case goneFishin        // take the fishing rod
    case earApparent       // prove yourself with pointed ears
    case widowersLament    // hear the trading-post merchant

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
    case grimCatalog       // die to every distinct cause

    public var title: String {
        switch self {
        case .firstSteps:       return "First Steps"
        case .armed:            return "Armed"
        case .firekeeper:       return "Firekeeper"
        case .earthshaper:      return "Earthshaper"
        case .fullArsenal:      return "Full Arsenal"
        case .fullyLoaded:      return "Fully Loaded"
        case .kingOfNacastrum:  return "King of Nacastrum"
        case .cleanCoronation:  return "Clean Coronation"
        case .druidFriend:      return "Friend of the Druids"
        case .wanderer:         return "Wanderer"
        case .worldsEnd:        return "To the World's End"
        case .schismScholar:    return "Schism Scholar"
        case .meaningOfLife:    return "The Meaning of Life"
        case .goldRush:         return "Gold Rush"
        case .persistentAngler: return "Persistent Angler"
        case .crowPose:         return "Crow Pose"
        case .thanksForHonesty: return "Thanks for Your Honesty"
        case .againstInstinct:  return "Against Instinct"
        case .alreadyLitFam:    return "Already Lit Fam"
        case .soleSurvivor:     return "Sole Survivor"
        case .clawAndOrder:     return "Claw and Order"
        case .goneFishin:       return "Gone Fishin'"
        case .earApparent:      return "Ear Apparent"
        case .widowersLament:   return "Widower's Lament"
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
        case .grimCatalog:      return "Grim Catalog"
        }
    }

    public var detail: String {
        switch self {
        case .firstSteps:       return "Learn the spell Levitate."
        case .armed:            return "Take the Long Sword."
        case .firekeeper:       return "Learn the spell Inflame."
        case .earthshaper:      return "Learn the spell Stonebend."
        case .fullArsenal:      return "Master all three spells."
        case .fullyLoaded:      return "Carry every spell and every tool."
        case .kingOfNacastrum:  return "Reunite the mages and reclaim Nacastrum."
        case .cleanCoronation:  return "Crown yourself without dying once."
        case .druidFriend:      return "Earn Dentros's trust and his lantern."
        case .wanderer:         return "Visit eight distinct regions of Avasia."
        case .worldsEnd:        return "Set foot in every region of Avasia."
        case .schismScholar:    return "Hear the gate guard's history of the schism."
        case .meaningOfLife:    return "Ask the right question of the right priestess."
        case .goldRush:         return "Reel in a fish worth a fortune."
        case .persistentAngler: return "Throw back the useless orange fish three times."
        case .crowPose:         return "Find your center on the Oceandale shore."
        case .thanksForHonesty: return "Admit defeat at the fireball pedestal."
        case .againstInstinct:  return "Break the dream bridge by swimming."
        case .alreadyLitFam:    return "Try to light an already lit lantern."
        case .soleSurvivor:     return "Reel in treasure of a different sole."
        case .clawAndOrder:     return "Survive the fishing crab without becoming dinner."
        case .goneFishin:       return "Take the rod from the beach hut."
        case .earApparent:      return "Flash your ears at the druid gate."
        case .widowersLament:   return "Hear the trading-post merchant's grief."
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
        case .grimCatalog:      return "Die to every distinct cause of death."
        }
    }

    /// Secret achievements hide their detail until unlocked.
    public var isSecret: Bool {
        switch self {
        case .firstSteps, .armed, .firekeeper, .earthshaper, .fullArsenal,
             .fullyLoaded, .kingOfNacastrum, .cleanCoronation, .druidFriend,
             .wanderer, .worldsEnd, .schismScholar, .goneFishin:
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
    public var deathCausesExperienced: Set<DeathCause> = []

    public init() {}

    public func has(_ a: Achievement) -> Bool { unlocked.contains(a) }
    public var unlockedCount: Int { unlocked.count }
    public var total: Int { Achievement.allCases.count }
}
