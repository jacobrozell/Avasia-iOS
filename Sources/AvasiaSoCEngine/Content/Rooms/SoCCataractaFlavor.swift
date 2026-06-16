import Foundation
import AvasiaEngine

/// Shared Act I flavor — bridge crossings, room LOOK text.
enum SoCCataractaFlavor {
    static func actOneOpeningLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "volunteer" : state.playerName
        return [
            .title("Blade of Courage"),
            .body("Seven years since Oceandale burned and a mage-king was crowned at Aylova."),
            .body("The border held — until Paladins walked out of Agroman's forges."),
            .body("You are \(name), a druid of Cataracta, and you have chosen to volunteer before the draft finds you."),
            .body("Kimious rallies the Legion. Sylvian Anula still glints in the garden fountain — gift, not coin, for now."),
            .blank
        ]
    }

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
            .body("\"\(name), come home when the war is won.\""),
            .body("Tucked under the note: a clipping about Sylvian crystal shipments — the elders already count crates for Kaefden's war.")
        ]
    }

    static func northLookLines() -> [StyledLine] {
        [
            .body("The keep towers over northern Cataracta, blue crystal glinting in the garden."),
            .body("Legionnaires drill in the distant courtyard. War talk hums in the market air."),
            .body("Coalition couriers have been seen at the keep — requisition forms, not feast invitations.")
        ]
    }

    static func shoppingLookLines() -> [StyledLine] {
        [
            .body("Merchants hawk wares, but half the stalls are empty."),
            .body("Everyone speaks of Agromanian raids and King Kimious's hidden defenses."),
            .body("A tinker prices lamp wicks by weight of blue dust — Anula shavings, he says, ward off bad luck. Business is good.")
        ]
    }
}
