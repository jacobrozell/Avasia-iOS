import Foundation
import AvasiaEngine

// MARK: - Good #5 — Witness Stone

struct GoodFiveSilvariumRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFiveSilvarium
    private let advance = ["CONTINUE", "GO", "ENTER"]
    private let talk = ["TALK", "VENNA", "ELDER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Silvarium — Witness Stone"),
            .body("The elders' hall smells of sap and smoke from distant Oceandale. War reached the trees at last — bark strips replace gossip."),
            .body("Witness flags hang heavy with names you helped save, and names you could not."),
            .speech("Elder Venna: \"Restoration moves because you made them. Now Sylvarium asks for a name that outlives us.\"")
        ]
        if state.goodFourHoldLine {
            lines.append(.body("Your hold order saved barges — elders remember the living, not only the testimony."))
        } else if state.goodThreePublicTestimony {
            lines.append(.body("The court heard you in glass. The stone hears you in bark — older law, slower mercy."))
        }
        lines.append(.hint("CONTINUE to the stone · TALK to Elder Venna."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Elder Venna: SWEAR and scouts a century from now read your ridge count in living bark."),
                .speech("Elder Venna: REFUSE and serve Sylva as witness only — no carving, no legend, no lie."),
                .hint("CONTINUE to the stone.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to Elder Venna.")])
        }
        return AnthologyTurnResult([], .move(.goodFiveWitnessStone))
    }
}

struct GoodFiveWitnessStoneRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFiveWitnessStone
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFiveStoneResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("The Witness Stone"),
            .body("Names carved in living bark — scouts, fishers, couriers who told truth when banners demanded lies."),
            .body("Mira's name is not here — she broke away or stayed partner, but the stone only records those who reported."),
            .speech("Elder Venna: \"SWEAR your ridge report into the stone. Or REFUSE — walk as witness only, never martyr.\""),
            .hint("SWEAR into the stone · REFUSE permanent mark · LOOK at the names.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodFiveStoneResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodFiveEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LOOK") || input.contains("NAMES") || input.contains("READ") {
            return AnthologyTurnResult([
                .body("A fisher from Oceandale — pier or church, the carving does not say. A courier who told Thekia every ship."),
                .body("The bark bleeds sap when you touch it. Living memory, not monument."),
                .hint("SWEAR · REFUSE.")
            ])
        }
        if input.contains("SWEAR") || input.contains("CARVE") || input.contains("MARK") {
            state.goodFiveStoneResolved = true
            state.goodFiveSworeWitness = true
            return AnthologyTurnResult([
                .body("Sap burns your palm as the bark accepts your name. Future scouts will read what you saw at the ridge."),
                .body("Every fire counted. Every banner noted. Poetry stripped — numbers remain."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("REFUSE") || input.contains("WALK") || input.contains("UNMARKED") {
            state.goodFiveStoneResolved = true
            state.goodFiveSworeWitness = false
            return AnthologyTurnResult([
                .speech("Elder Venna: \"Then serve living Sylva — not dead ink. We still need you.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("SWEAR · REFUSE · LOOK.")])
    }
}

struct GoodFiveEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFiveEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFiveComplete {
            return [.body("Witness Stone — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.goodFiveSworeWitness
            ? "Your name joins the stone. Loyalty becomes legend — whether you wanted it or not."
            : "The stone stays blank under your hand. Loyalty, for you, remains a living duty — not a carving."
        return [.title("Elders' Dusk"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodFiveComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodFive, state: &state)
        return AnthologyTurnResult([
            .title("Witness Stone — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodFive).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
