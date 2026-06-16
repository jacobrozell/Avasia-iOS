import Foundation
import AvasiaEngine

/// Sylvian elders hold sway over Ofelos — audience before the Varatro quest (iOS authored).
struct SoCSilvariumEldersRoom: SoCRoomScript {
    let id: SoCRoomID = .silvariumElders
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "YES", "PROCEED"]
    private let departTriggers = ["MARCH", "DEPART", "LEAVE", "EAST", "VARATRO"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.silvariumEldersPhase == .notStarted else { return nil }
        state.silvariumEldersPhase = .arrived
        return arrivalLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.silvariumEldersComplete {
            return [
                .title("Silvarium — Elders' Hall"),
                .body("The great tree creaks overhead. Varatro Falls awaits downriver."),
                .hint("MARCH to Varatro Falls.")
            ]
        }
        switch state.silvariumEldersPhase {
        case .notStarted, .arrived:
            return [.hint("CONTINUE before the elders.")]
        case .audience:
            return [.hint("CONTINUE to hear their terms.")]
        case .commission:
            return [.hint("CONTINUE to accept the quest.")]
        case .done:
            return [.hint("MARCH to Varatro Falls.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.silvariumEldersComplete {
            if departs(input) {
                return SoCTurnResult(departureLines(), .move(.varatroFalls))
            }
            return SoCTurnResult([.hint("MARCH to Varatro Falls.")])
        }

        if departs(input), state.silvariumEldersPhase == .done {
            state.silvariumEldersComplete = true
            return SoCTurnResult(departureLines(), .move(.varatroFalls))
        }

        guard advances(input) else {
            return SoCTurnResult([.hint("CONTINUE when you are ready.")])
        }

        switch state.silvariumEldersPhase {
        case .notStarted, .arrived:
            state.silvariumEldersPhase = .audience
            return SoCTurnResult(audienceLines())

        case .audience:
            state.silvariumEldersPhase = .commission
            return SoCTurnResult(commissionLines())

        case .commission:
            state.silvariumEldersPhase = .done
            state.silvariumEldersComplete = true
            var lines = acceptanceLines()
            lines.append(.title("Quest accepted"))
            lines.append(.hint("MARCH to Varatro Falls."))
            return SoCTurnResult(lines)

        case .done:
            return SoCTurnResult([.hint("MARCH to Varatro Falls.")])
        }
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func departs(_ input: ParsedInput) -> Bool {
        departTriggers.contains { input.contains($0) }
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Silvarium"),
            .body("You ride east from Aylova with coalition papers and Thekia's seal."),
            .body("The forest deepens until the great tree of Silvarium rises — wider than any keep, older than Kaefden's crown."),
            .body("At the rope bridge, a Sylvian marksman checks your papers and nods."),
            .speech("Marksman: Kaefden to Kaefden. We heard Cataracta burned — the elders are waiting."),
            .speech("Marksman: Suformin led our hunters to this tree. The druids' Anula still glints in our shrines."),
            .speech("Marksman: I stood on this bridge when a lost mage cut blood on the fourth floor. Your war is our war now."),
            .body("Sylvian hunters guide you up into the elders' hall.")
        ]
    }

    private func audienceLines() -> [StyledLine] {
        [
            .blank,
            .body("Three elders sit in carved thrones grown from living wood."),
            .body("The marksman from the bridge stands at the wall, arms folded."),
            .speech("Elder Venna: We heard the Agromanian defector from Silvarium's border. Paladins in the northwest — we believe it."),
            .speech("Elder Venna: Ofelos will not march for banners alone. They want proof Kaefden still honors the old compact."),
            .speech("Elder Venna: Bring Kaefden's Blade of Courage from Varatro Falls, where the first king of the bloodline sleeps."),
            .speech("Elder Venna: The Blade is civic anchor — honor made steel. Ofelos trusts oaths, not towers."),
            .blank,
            .speech("Elder: Thekia's letter names you. We trust her word — not yet yours."),
            .speech("Marksman: They survived Cataracta's courtyard. That is proof enough for me.")
        ]
    }

    private func commissionLines() -> [StyledLine] {
        [
            .speech("Elder Venna: Varatro is warded. Agromanian scouts watch the falls since the Paladins rose."),
            .speech("Elder Venna: If Kaefden wins, do not let Aylova grade our Anula like ore. Gift becomes goods once, and never returns."),
            .speech("Elder Venna: Vashirr waited seven years to strike — he will not let the Blade reach Ofelos without a fight."),
            .speech("Elder: Return with the sword, and we will speak for Ofelos in the coalition council."),
            .blank,
            .body("The marksman marks a trail on your map — downriver, through mist and old stone.")
        ]
    }

    private func acceptanceLines() -> [StyledLine] {
        [
            .speech("You: I survived Cataracta. I will bring the Blade or die on the path."),
            .blank,
            .speech("Elder: Then go. Aylova's northern army cannot wait forever — neither can we."),
            .symbol("Varatro Falls lies downriver.")
        ]
    }

    private func departureLines() -> [StyledLine] {
        [
            .body("You descend the great tree and take the hunters' trail toward the sound of falling water.")
        ]
    }
}
