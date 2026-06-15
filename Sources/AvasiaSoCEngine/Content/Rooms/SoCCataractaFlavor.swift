import Foundation
import AvasiaEngine

/// Shared Act I flavor — bridge crossings, room LOOK text.
enum SoCCataractaFlavor {
    static func varathoCrossingLines(_ state: inout SoCGameState) -> [StyledLine] {
        guard !state.varathoCrossed else { return [] }
        state.varathoCrossed = true
        var lines: [StyledLine] = [
            .blank,
            .body("You cross the ornate Varatho bridge. Rapids churn below the planks."),
            .body("Fishermen wave from Doran's pier. Legion banners snap above the northern keep."),
            .body("For a moment, Cataracta feels eternal.")
        ]
        lines.append(contentsOf: SoCQuestProgress.grantQuestExp(5, state: &state))
        return lines
    }

    static func housingLookLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "volunteer" : state.playerName
        return [
            .body("Your small druid house is tidy — bed made, pack ready by the door."),
            .body("A note from your mother wishes luck at the courtyard muster."),
            .body("\"\(name), come home when the war is won.\"")
        ]
    }

    static func northLookLines() -> [StyledLine] {
        [
            .body("The keep towers over northern Cataracta, blue crystal glinting in the garden."),
            .body("Legionnaires drill in the distant courtyard. War talk hums in the market air.")
        ]
    }

    static func shoppingLookLines() -> [StyledLine] {
        [
            .body("Merchants hawk wares, but half the stalls are empty."),
            .body("Everyone speaks of Agromanian raids and King Kimious's hidden defenses.")
        ]
    }
}
