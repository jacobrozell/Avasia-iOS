import Foundation
import AvasiaEngine

/// Optional coda — return to Cataracta after victory.
struct SoCCataractaRuinsRoom: SoCRoomScript {
    let id: SoCRoomID = .cataractaRuins
    var parseMode: Parser.Mode { .raw }

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard !state.ruinsVisited else { return nil }
        return arrivalLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.ruinsVisited {
            return [
                .title("Cataracta Ruins"),
                .body("Ash and silence. You have paid your respects."),
                .hint("RETURN to Aylova.")
            ]
        }
        return [.hint("CONTINUE through the ruins, or RETURN to Aylova.")]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if input.contains("RETURN") || input.contains("AYLOVA") || input.contains("LEAVE") {
            return SoCTurnResult([.body("You turn back toward Aylova's lights.")], .move(.ageEpilogue))
        }

        guard input.contains("CONTINUE") || input.contains("EXPLORE") || input.contains("WALK") else {
            return SoCTurnResult([.hint("CONTINUE through the ruins, or RETURN to Aylova.")])
        }

        if !state.ruinsVisited {
            state.ruinsVisited = true
            state.unlockTrophy(.returnedToAshes)
            var lines = pilgrimageLines(state)
            lines.append(contentsOf: SoCQuestProgress.grantQuestExp(30, state: &state))
            lines.append(.symbol("Trophy: Returned to Ashes"))
            return SoCTurnResult(lines)
        }

        return SoCTurnResult([.body("There is nothing left to find here.")])
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Cataracta Ruins"),
            .body("You travel alone from Aylova along the Varatho — the bridge still stands, charred at the rails."),
            .body("The city you volunteered from is unrecognizable.")
        ]
    }

    private func pilgrimageLines(_ state: SoCGameState) -> [StyledLine] {
        let dentros: String
        switch state.throneRecountStyle {
        case .honorDentros:
            dentros = "You kneel where Dentros fell and whisper thanks only a survivor can give."
        default:
            dentros = "You find the courtyard stones where Dentros died. The silence is accusation and blessing at once."
        }
        return [
            .blank,
            .body("The keep is a black tooth against the sky."),
            .body(dentros),
            .body("At the garden, Anula's fountain is cracked — blue crystal dull in the rubble."),
            .blank,
            .speech("A coalition scout finds you: Kaefden asked that any Cataractan survivor be brought home safely."),
            .body("You are not home. But you are remembered."),
            .blank,
            .body("War took Cataracta. You carried its name to victory anyway.")
        ]
    }
}
