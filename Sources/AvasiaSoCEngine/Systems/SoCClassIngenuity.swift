import Foundation
import AvasiaEngine

/// Class-specific verbs that skip or soften authored fights when the player thinks first.
public enum SoCClassIngenuity {
    static let scoutTriggers = ["SCOUT", "STEALTH", "SNEAK"]
    static let hunterTriggers = ["HUNT", "TRACK", "STALK", "AMBUSH", "FLANK"]
    static let guardianTriggers = ["SHIELD", "HOLD", "GUARD", "PROTECT", "TAUNT", "DISTRACT"]

    static func matches(_ input: ParsedInput, playerClass: DruidClass) -> Bool {
        let triggers: [String]
        switch playerClass {
        case .scout: triggers = scoutTriggers
        case .hunter: triggers = hunterTriggers
        case .guardian: triggers = guardianTriggers
        case .none: return false
        }
        return triggers.contains { input.contains($0) }
    }

    static func verb(for playerClass: DruidClass) -> String? {
        switch playerClass {
        case .scout: return "SCOUT"
        case .hunter: return "HUNT"
        case .guardian: return "SHIELD"
        case .none: return nil
        }
    }

    static func quickVerbLabel(for playerClass: DruidClass) -> String? {
        switch playerClass {
        case .scout: return "Scout"
        case .hunter: return "Hunt"
        case .guardian: return "Shield"
        case .none: return nil
        }
    }

    /// iOS quick-action chip when a bypass is available on the current beat.
    public static func quickVerb(for state: SoCGameState) -> String? {
        guard let label = quickVerbLabel(for: state.playerClass) else { return nil }
        switch state.currentRoom {
        case .northernMarch
            where !state.northernMarchCleared && [.notStarted, .refugees].contains(state.northernMarchPhase):
            return label
        case .varatroFalls where state.varatroFallsPhase == .tomb:
            return label
        case .oceandaleFront where state.oceandaleFrontPhase == .charge:
            return label
        case .oceandaleFront
            where state.oceandaleFrontPhase == .betweenWaves && state.oceandalePaladinAdvantage == .none:
            return label
        case .mageOutpost where state.mageOutpostPhase == .infiltration:
            return label
        default:
            return nil
        }
    }

    static func bypassHint(for state: SoCGameState) -> StyledLine? {
        if state.currentRoom == .oceandaleFront, state.oceandaleFrontPhase == .betweenWaves {
            return paladinPrepHint(for: state)
        }
        guard let verb = verb(for: state.playerClass) else { return nil }
        let action: String
        switch state.playerClass {
        case .scout: action = "slip past without fighting"
        case .hunter: action = "outmaneuver the enemy"
        case .guardian: action = "hold the line for the column"
        case .none: return nil
        }
        return .hint("\(verb) to \(action).")
    }

    static func paladinPrepHint(for state: SoCGameState) -> StyledLine? {
        guard state.oceandalePaladinAdvantage == .none,
              let verb = verb(for: state.playerClass) else { return nil }
        switch state.playerClass {
        case .scout:
            return .hint("\(verb) the Paladin's ward gap before you charge.")
        case .hunter:
            return .hint("\(verb) for an opening shot on the crest.")
        case .guardian:
            return .hint("\(verb) up and brace — you'll need every inch of plate.")
        case .none:
            return nil
        }
    }
}
