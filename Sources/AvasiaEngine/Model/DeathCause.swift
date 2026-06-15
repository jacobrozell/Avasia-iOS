import Foundation

/// A structured cause of death. Carries a short screen title and a sardonic
/// epitaph for the death overlay, and a stable key used by achievements. The
/// room still prints its own verbatim death narration into the transcript; this
/// powers the overlay and the achievement triggers.
public enum DeathCause: String, Codable, Sendable, CaseIterable {
    case chasm        // jumping off the mountain bridge
    case crab         // the fishing crab-monster
    case seaSerpent   // the fishing sea serpent
    case stalactite   // levitating inside the dark cave
    case mining       // taking the pickaxe to the crystals
    case neckCut      // cutting your neck at the blood seal
    case ambush       // the Agromanian road ambush
    case fireball     // out of guesses at the pedestal
    case generic

    public var title: String {
        switch self {
        case .chasm:      return "Into the Chasm"
        case .crab:       return "Crab Dinner"
        case .seaSerpent: return "Swallowed Whole"
        case .stalactite: return "A Pointed End"
        case .mining:     return "Too Greedy"
        case .neckCut:    return "The Wrong Cut"
        case .ambush:     return "Ambushed"
        case .fireball:   return "Burned to Ash"
        case .generic:    return "You Have Died"
        }
    }

    public var epitaph: String {
        switch self {
        case .chasm:      return "The water was farther down than it looked."
        case .crab:       return "Snapped clean in half. Should have brought a blade."
        case .seaSerpent: return "The serpent was hungrier than you were patient."
        case .stalactite: return "You flew up. The ceiling had opinions."
        case .mining:     return "The shards were guarded. The miner could have told you."
        case .neckCut:    return "The seal asked for blood, not all of it."
        case .ambush:     return "You needed fire, and brought everything but."
        case .fireball:   return "Like the mage in the corner before you."
        case .generic:    return "The quest ends here. For now."
        }
    }
}
