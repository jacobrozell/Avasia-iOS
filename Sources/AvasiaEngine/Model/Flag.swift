import Foundation

/// Binary progress markers: spells learned, items held, and one-shot world
/// state. In the original game each of these was a `0/1` global; here they live
/// in a typed `Set<Flag>` on `GameState`.
///
/// Dead flags from the original (`slipp`, `tunnel`, `tran`, `blood`, `roadgeo`,
/// `roadlev`) are intentionally omitted — they carried no logic. Road progress
/// is modeled by `GameState.roadProgress` instead (see ENGINE_SPEC §A.4).
public enum Flag: String, Codable, CaseIterable, Sendable {
    // Spells
    case levitate          // lev   — gift of the Old Mage
    case fireball          // fireball / Inflame — cave symbol puzzle
    case stonebend         // geo   — tree blood seal

    // Items
    case sword             // sword — graveyard corpse
    case lantern           // lant  — Dentros
    case dagger            // dagger — Suformin's Dagger, tree butcher
    case rod               // rod   — beach hut

    // World state / one-shots
    case metDentros        // druid       — met the druid scout
    case northCaveGateOpen // ndoor       — N cave stone gate opened
    case grassCut          // grass       — forest entrance grass cut
    case forestLoreHeard   // forestlore  — heard the Silvarium intro
    case armoryVisited     // armory      — talked to the tree armory guard

    /// Whether this flag represents a castable spell.
    public var isSpell: Bool {
        switch self {
        case .levitate, .fireball, .stonebend: return true
        default: return false
        }
    }

    /// Whether this flag represents a carryable item.
    public var isItem: Bool {
        switch self {
        case .sword, .lantern, .dagger, .rod: return true
        default: return false
        }
    }

    /// Display name for inventory / spellbook UI.
    public var displayName: String {
        switch self {
        case .levitate: return "Levitate"
        case .fireball: return "Inflame"
        case .stonebend: return "Stonebend"
        case .sword: return "Long Sword"
        case .lantern: return "Lantern"
        case .dagger: return "Suformin's Dagger"
        case .rod: return "Fishing Rod"
        default: return rawValue
        }
    }

    /// Input synonyms accepted when casting a spell (matched as substrings,
    /// faithfully reproducing the original's cast-name lists).
    public var castSynonyms: [String] {
        switch self {
        case .levitate: return ["LEVITATE", "LEV"]
        case .fireball: return ["INFLAME", "IN-FLAME"]
        case .stonebend: return ["STONEBEND", "STONE-BEND"]
        default: return []
        }
    }
}
