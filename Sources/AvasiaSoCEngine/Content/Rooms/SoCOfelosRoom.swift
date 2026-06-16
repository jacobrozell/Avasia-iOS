import Foundation
import AvasiaEngine

/// Neutral city Ofelos — present the Blade; win the coalition alliance (iOS authored).
struct SoCOfelosRoom: SoCRoomScript {
    let id: SoCRoomID = .ofelos
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "PRESENT", "YES", "PROCEED"]
    private let departTriggers = ["MARCH", "NORTH", "DEPART", "LEAVE", "ARMY"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.ofelosPhase == .notStarted else { return nil }
        state.ofelosPhase = .gates
        return arrivalLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.ofelosAllianceComplete {
            return [
                .title("Ofelos"),
                .body("Neutral banners now fly beside Kaefden colors. The northern army waits."),
                .hint("MARCH north to join the coalition front.")
            ]
        }
        switch state.ofelosPhase {
        case .notStarted, .gates:
            return [.hint("CONTINUE into the city.")]
        case .council:
            return [.hint("CONTINUE before the council.")]
        case .presentation:
            return [.hint("PRESENT the Blade or CONTINUE.")]
        case .alliance:
            return [.hint("CONTINUE to seal the pact.")]
        case .done:
            return [.hint("MARCH north.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.ofelosAllianceComplete {
            if departs(input) {
                return SoCTurnResult(marchNorthLines(state), .move(.northernMarch))
            }
            return SoCTurnResult([.hint("MARCH north to the war front.")])
        }

        if departs(input), state.ofelosPhase == .done {
            state.ofelosAllianceComplete = true
            return SoCTurnResult(marchNorthLines(state), .move(.northernMarch))
        }

        if advances(input) || (input.contains("PRESENT") && state.ofelosPhase == .presentation) {
            return advanceScene(&state)
        }

        return SoCTurnResult([.hint("CONTINUE.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func departs(_ input: ParsedInput) -> Bool {
        departTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.ofelosPhase {
        case .notStarted, .gates:
            state.ofelosPhase = .council
            return SoCTurnResult(councilLines(state))

        case .council:
            state.ofelosPhase = .presentation
            return SoCTurnResult(presentationPromptLines())

        case .presentation:
            guard state.inventory[.bladeOfCourage, default: 0] > 0 else {
                return SoCTurnResult([.body("You reach for the Blade — but it is not at your hip.")])
            }
            state.ofelosPhase = .alliance
            return SoCTurnResult(presentationLines())

        case .alliance:
            state.ofelosPhase = .done
            state.ofelosAllianceComplete = true
            state.unlockTrophy(.ofelosMarches)
            var lines = allianceLines(state)
            lines.append(.title("Ofelos joins the coalition"))
            lines.append(.hint("MARCH north to the war front."))
            return SoCTurnResult(lines)

        case .done:
            return SoCTurnResult([.hint("MARCH north.")])
        }
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Ofelos"),
            .body("White stone walls ring a city that refused every faction for generations."),
            .body("Sylvian elders travel at your side — their word opened the gates."),
            .body("Neutral guards salute the Blade at your hip before they salute you.")
        ]
    }

    private func councilLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .blank,
            .body("The council chamber is round — no head of table, no throne."),
            .speech("\(SoCStoryVoice.ofelosAddress(state))"),
            .speech("Council Speaker Maelen: Paladins ended our complacency. The Sylvians vouch for this druid — we will hear proof, not promise."),
            .blank,
            .speech("Elder Venna: Present what Varatro guarded. Let Ofelos see Kaefden's honor with its own eyes.")
        ]
    }

    private func presentationPromptLines() -> [StyledLine] {
        [
            .hint("PRESENT the Blade before the council."),
            .body("Every council member leans forward as you step into the light.")
        ]
    }

    private func presentationLines() -> [StyledLine] {
        [
            .body("You draw Kaefden's Blade of Courage. Blue crystal dust along the fuller catches the sun from the high windows."),
            .blank,
            .speech("Council Speaker Maelen: ...That is the sword from the first king's tomb."),
            .speech("Elder Venna: Kaefden IV rebuilds Nacastrum. Cataracta burned. The coalition fights — but it needs Ofelos."),
            .speech("Council Speaker Maelen: When Oceandale fell, we stayed out. We will not march for revenge alone — but we will march for this symbol.")
        ]
    }

    private func allianceLines(_ state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .blank,
            .body("Hands clasp across the chamber — neutral, Sylvian, and Kaefden envoys alike."),
            .speech("Council Speaker Maelen: Ofelos joins the coalition. Our spears go north with yours."),
            .speech("Council Speaker Maelen: Tell King Kaefden IV the neutrals remember who united Avasia first.")
        ]
        if state.throneRecountStyle == .honorDentros {
            lines.append(.speech("Council Speaker Maelen: And tell him a Cataractan who honors the dead is worth ten who only count heads."))
        }
        lines += [
            .blank,
            .symbol("The northern war front awaits."),
            .body("Neutral companies already form in the square behind you — late, but not too late.")
        ]
        return lines
    }

    private func marchNorthLines(_ state: SoCGameState) -> [StyledLine] {
        let sergeantLine: String
        switch state.throneRecountStyle {
        case .honorDentros:
            sergeantLine = "Coalition Sergeant: Dentros would be proud you're still standing. Ridge won't hold itself."
        default:
            sergeantLine = "Coalition Sergeant: About time. Ridge won't hold itself."
        }
        return [
            .body("You fall in with Ofelos columns and Kaefden scouts on the road toward Oceandale country."),
            .speech(sergeantLine)
        ]
    }
}
