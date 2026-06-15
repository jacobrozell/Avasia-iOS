import Foundation
import AvasiaEngine

/// Dynamic objectives derived from save state — no separate quest log file.
public enum SoCJournal {
    public static func objectives(for state: SoCGameState) -> [String] {
        var goals: [String] = []
        if state.gameComplete {
            if !state.ruinsVisited {
                goals.append("Optional: VISIT RUINS from the epilogue square.")
            }
            goals.append("Age-era saga complete. Start New Game to replay another class.")
            return goals
        }
        if state.courtyardComplete {
            appendWarGoals(state, into: &goals)
            return goals
        }
        appendPeacefulGoals(state, into: &goals)
        goals.append("Critical: North → Courtyard → enlist (Wolf, Bear, or Fox).")
        return goals
    }

    private static func appendPeacefulGoals(_ state: SoCGameState, into goals: inout [String]) {
        if !state.varathoCrossed { goals.append("Optional: cross the Varatho bridge to northern town.") }
        if !state.fountain { goals.append("Optional: toss a coin at the castle garden fountain (North).") }
        if !state.barracksTalked { goals.append("Optional: speak with the guards at the barracks (North → West).") }
        if state.athalosVisitCount < 2 { goals.append("Optional: visit Athalos (Shopping → South) — return to buy supplies.") }
        if !state.ulric { goals.append("Optional: visit Ulric the blacksmith (Shopping → East).") }
        if !state.trophies.contains(.brother), state.ulric {
            goals.append("Optional: accept Doran's fishing rod at the pier.")
        }
        if !state.trophies.contains(.fished), state.doran {
            goals.append("Optional: fish until bait runs out at Doran's pier.")
        }
    }

    private static func appendWarGoals(_ state: SoCGameState, into goals: inout [String]) {
        switch state.currentRoom {
        case .portalRoom where !state.portalRoom:
            goals.append("Search the portal room, then reach the library (books or vent).")
        case .library:
            goals.append("Follow Thekia south to alert the king.")
        case .westHallway:
            goals.append("East to the throne room.")
        case .throneRoom where !state.throneAudience:
            goals.append("Audience with Kaefden IV — honor Dentros or report the facts.")
        case .throneRoom:
            goals.append("MARCH to Aylova war camp.")
        case .aylovaWarCamp where !state.aylovaMusterComplete:
            goals.append("Briefing → quartermaster (BUY supplies) → march east to Silvarium.")
        case .silvariumElders where !state.silvariumEldersComplete:
            goals.append("Audience with Sylvian elders — earn the Varatro quest.")
        case .silvariumElders:
            goals.append("MARCH to Varatro Falls for Kaefden's Blade.")
        case .varatroFalls where !state.varatroFallsCleared:
            goals.append("Reach the tomb and recover the Blade of Courage.")
        case .varatroFalls:
            goals.append("MARCH to Ofelos with the Blade.")
        case .ofelos where !state.ofelosAllianceComplete:
            goals.append("PRESENT the Blade before Ofelos council.")
        case .ofelos:
            goals.append("MARCH north to join the war front.")
        case .northernMarch where !state.northernMarchCleared:
            goals.append("Reach Oceandale ridge (fight or SCOUT past the patrol).")
        case .oceandaleFront where !state.oceandaleFrontCleared:
            goals.append("Break the ridge: two waves, then ADVANCE.")
        case .mageOutpost where !state.mageOutpostCleared:
            goals.append("Steal maps at the mage outpost (SCOUT to infiltrate as Fox).")
        case .vashirrStand where !state.vashirrDefeated:
            goals.append("Vashirr's redoubt — hold the line with Kaefden.")
        case .ageEpilogue:
            goals.append("CONTINUE through the memorial and victory speech.")
        default:
            if !state.throneAudience {
                goals.append("Warn King Kaefden IV in Nacastrum.")
            } else if !state.vashirrDefeated {
                goals.append("Win the coalition war campaign.")
            }
        }
    }

    public static func objectiveLines(for state: SoCGameState) -> [StyledLine] {
        let goals = objectives(for: state)
        guard !goals.isEmpty else {
            return [.body("No active objectives.")]
        }
        var lines: [StyledLine] = [.title("Objectives")]
        for (index, goal) in goals.enumerated() {
            lines.append(.body("\(index + 1). \(goal)"))
        }
        return lines
    }
}
