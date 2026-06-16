import Foundation
import AvasiaEngine

public struct SoCDeathInfo: Sendable, Equatable {
    public let epitaph: String
    public let number: Int
}

public enum SoCDeathCatalog {
    public static func info(for state: SoCGameState, narrative: [StyledLine]) -> SoCDeathInfo {
        let epitaph = epitaph(for: state)
        return SoCDeathInfo(epitaph: epitaph, number: state.deathCount)
    }

    private static func epitaph(for state: SoCGameState) -> String {
        if state.inCombat, let enemy = state.enemy {
            return combatEpitaph(enemy: enemy.name, state: state)
        }
        switch state.currentRoom {
        case .cataractaCourtyard:
            return "Cataracta fell around you before you could warn the world."
        case .oceandaleFront, .mageOutpost, .vashirrStand, .northernMarch, .varatroFalls:
            return "The war took another Cataractan name — but the coalition remembers."
        default:
            return "Your courage was not enough this time."
        }
    }

    private static func combatEpitaph(enemy: String, state: SoCGameState) -> String {
        switch state.playerClass {
        case .hunter:
            return "The \(enemy) outlasted your wolf fury on \(SoCChapter.title(for: state.currentRoom))."
        case .guardian:
            return "Your shield broke before the \(enemy) did. The line needed you longer."
        case .scout:
            return "You could not slip away from the \(enemy) in time."
        case .none:
            return "Fallen to \(enemy) before your spirit animal could guide you."
        }
    }
}
