import Foundation

public enum KonCodexCategory: String, CaseIterable, Sendable {
    case character
    case storyBeat

    public var title: String {
        switch self {
        case .character: return "Characters"
        case .storyBeat: return "Story"
        }
    }
}

/// Unlockable journal entries for King of Nacastrum — derived from save state.
public enum KonCodexEntry: String, CaseIterable, Sendable {
    case oldMage
    case dentros
    case vashirr
    case thekia
    case sylvianPriestess
    case suformin
    case gateGuard
    case father

    case beachAwakening
    case mageQuest
    case schismLore
    case silvariumSeal
    case cataractaGate
    case memoryFlash
    case nacastrumReturn
    case victory

    public var category: KonCodexCategory {
        switch self {
        case .oldMage, .dentros, .vashirr, .thekia, .sylvianPriestess, .suformin, .gateGuard, .father:
            return .character
        case .beachAwakening, .mageQuest, .schismLore, .silvariumSeal, .cataractaGate,
             .memoryFlash, .nacastrumReturn, .victory:
            return .storyBeat
        }
    }

    public var title: String {
        switch self {
        case .oldMage: return "The Old Mage"
        case .dentros: return "Dentros"
        case .vashirr: return "Vashirr"
        case .thekia: return "Thekia"
        case .sylvianPriestess: return "Sylvian Priestess"
        case .suformin: return "Suformin"
        case .gateGuard: return "Gate Guard"
        case .father: return "Your Father"
        case .beachAwakening: return "Beach Awakening"
        case .mageQuest: return "Magehouse Quest"
        case .schismLore: return "Schism at the Gate"
        case .silvariumSeal: return "Blood Seal"
        case .cataractaGate: return "Western Gate"
        case .memoryFlash: return "Memory Restored"
        case .nacastrumReturn: return "Return to Nacastrum"
        case .victory: return "King of Nacastrum"
        }
    }

    public var symbolName: String {
        switch self {
        case .oldMage, .thekia: return "wand.and.stars"
        case .dentros: return "leaf.fill"
        case .vashirr: return "bolt.fill"
        case .sylvianPriestess: return "tree.fill"
        case .suformin: return "scissors"
        case .gateGuard: return "shield.lefthalf.filled"
        case .father: return "heart.fill"
        case .beachAwakening: return "water.waves"
        case .mageQuest: return "house.fill"
        case .schismLore: return "book.closed.fill"
        case .silvariumSeal: return "drop.fill"
        case .cataractaGate: return "door.left.hand.open"
        case .memoryFlash: return "sparkles"
        case .nacastrumReturn: return "building.columns.fill"
        case .victory: return "crown.fill"
        }
    }

    public var summary: String {
        switch self {
        case .oldMage:
            return "Exiled mage in the Oceandale magehouse. She gifts Levitate, names Vashirr's betrayal, and escorts you toward the Rings of Malkos."
        case .dentros:
            return "Druid scout from Cataracta — fox-form messenger. He gives the lantern and warns that reopening Nacastrum will wake old debts."
        case .vashirr:
            return "Ex-King of Nacastrum. Memory returns at the Ring: he scattered the city, allied Agroman, and murdered your father before your exile."
        case .thekia:
            return "Council elder who walked beside you as the Old Mage. In ruined Nacastrum she reveals herself and rallies Aylova to rebuild."
        case .sylvianPriestess:
            return "Voice of the Great Tree. She teaches Sylvian history — Anula as gift, towers versus earth, and why Stonebend waits on consent."
        case .suformin:
            return "Butcher of the living tree. His Anula dagger is the price of passage deeper into Silvarium's upper chambers."
        case .gateGuard:
            return "Broken-gate witness to the schism fable — Kaefden, Agroman, and the banished prince whose middle name became a faction."
        case .father:
            return "Memory-ghost at Aylova's portal. His pendant — earth-crystal in silver — is the anchor you carry into the war to come."
        case .beachAwakening:
            return "You wake on Oceandale shore with no name and no past. Blue glass, a missing pendant, and a dying town frame the quest."
        case .mageQuest:
            return "The Old Mage names your exile and sets the quest: unlock Nacastrum, reunite the mages, and learn Levitate."
        case .schismLore:
            return "At the western gate, guards recount how brother turned on brother — the wound Vashirr later claims he would heal by force."
        case .silvariumSeal:
            return "Crimson consent at the blood seal. Stonebend is earned, not taken — Sylvian law against the Many Hands doctrine."
        case .cataractaGate:
            return "Dentros opens the Anula-enriched western gate. Cataracta's druids guard crystal as gift, not commodity."
        case .memoryFlash:
            return "The Ring of Malkos restores what exile stole: graduation day, Vashirr's coup, your mother's portal, your father's death."
        case .nacastrumReturn:
            return "Ruined towers, Thekia unmasked, Aylova rallied — banished mages remember home and swear to stop Vashirr."
        case .victory:
            return "Nacastrum stirs again. Power scatters to market and flesh — crowns only decide who pays first. Blade of Courage awaits."
        }
    }

    public var lockedHint: String {
        switch self {
        case .oldMage: return "Visit the magehouse and speak with KAEFDEN."
        case .dentros: return "Meet the druid scout in the mountain cave."
        case .vashirr: return "Activate the teleporter platform west of Splitpath."
        case .thekia: return "Reach ruined Nacastrum with the Old Mage."
        case .sylvianPriestess: return "Enter the Sylvian forest and hear the intro."
        case .suformin: return "Claim Suformin's Dagger in the Great Tree."
        case .gateGuard: return "Listen at the broken western gate."
        case .father: return "Continue through Aylova's rally scene."
        case .beachAwakening: return "Visit the beach south of Oceandale."
        case .mageQuest: return "Learn Levitate from the Old Mage."
        case .schismLore: return "Hear the gate guard's schism speech."
        case .silvariumSeal: return "Earn Stonebend at the blood seal."
        case .cataractaGate: return "Open the western gate with Dentros."
        case .memoryFlash: return "Step onto the Ring of Malkos platform."
        case .nacastrumReturn: return "Arrive at Nacastrum and meet Thekia."
        case .victory: return "Complete the canonical ending."
        }
    }

    /// Chronological position on the Age-era saga timeline (story beats only).
    public var timelineOrder: Int? {
        switch self {
        case .schismLore: return 10
        case .beachAwakening: return 20
        case .mageQuest: return 30
        case .silvariumSeal: return 40
        case .cataractaGate: return 50
        case .memoryFlash: return 60
        case .nacastrumReturn: return 70
        case .victory: return 80
        default: return nil
        }
    }

    public var timelineLabel: String? {
        guard timelineOrder != nil else { return nil }
        return "KoN"
    }
}

public enum KonCodex {
    public static func isUnlocked(_ entry: KonCodexEntry, state: GameState) -> Bool {
        switch entry {
        case .oldMage:
            return state.has(.levitate) || state.magehouseLocked
        case .dentros:
            return state.has(.metDentros)
        case .vashirr:
            return state.teleporterDiscovered
        case .thekia:
            return state.metThekia
        case .sylvianPriestess:
            return state.has(.forestLoreHeard)
        case .suformin:
            return state.has(.dagger)
        case .gateGuard:
            return state.gateGuardLoreHeard
        case .father:
            return state.aylovaRallySeen
        case .beachAwakening:
            return state.beachIntroShown
        case .mageQuest:
            return state.has(.levitate)
        case .schismLore:
            return state.gateGuardLoreHeard
        case .silvariumSeal:
            return state.has(.stonebend)
        case .cataractaGate:
            return state.cataractaGateDone
        case .memoryFlash:
            return state.teleporterDiscovered
        case .nacastrumReturn:
            return state.metThekia
        case .victory:
            return state.gameComplete
        }
    }

    public static func entries(for category: KonCodexCategory) -> [KonCodexEntry] {
        KonCodexEntry.allCases.filter { $0.category == category }
    }

    public static func timelineEntries(for state: GameState) -> [KonCodexEntry] {
        KonCodexEntry.allCases
            .filter { $0.timelineOrder != nil }
            .sorted { ($0.timelineOrder ?? 0) < ($1.timelineOrder ?? 0) }
    }

    public static func unlockedCount(for state: GameState) -> Int {
        KonCodexEntry.allCases.filter { isUnlocked($0, state: state) }.count
    }
}
