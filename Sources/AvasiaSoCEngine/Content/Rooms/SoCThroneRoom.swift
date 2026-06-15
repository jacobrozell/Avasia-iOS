import Foundation
import AvasiaEngine

/// Throne audience with Kaefden IV — authored Act III climax (iOS; extends Python stub).
struct SoCThroneRoom: SoCRoomScript {
    let id: SoCRoomID = .throneRoom
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "SPEAK", "YES", "PROCEED"]
    private let departTriggers = ["MARCH", "DEPART", "LEAVE", "AYLOVA"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard !state.throneAudience, state.thronePhase == .notStarted else { return nil }
        state.thronePhase = .atThrone
        state.metThekia = true
        return entryLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.throneAudience {
            return epilogueLines(state)
        }
        switch state.thronePhase {
        case .notStarted, .atThrone:
            return throneRoomLines() + [.hint("CONTINUE to speak before the king.")]
        case .recountChoice:
            return recountChoiceLines()
        case .deliverVashirr:
            return [.hint("CONTINUE to deliver Vashirr's message.")]
        case .classService:
            return [.hint("CONTINUE to pledge your service.")]
        case .done:
            return epilogueLines(state)
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.throneAudience {
            if departs(input) {
                return SoCTurnResult(departureLines(), .move(.aylovaWarCamp))
            }
            if advances(input) {
                return SoCTurnResult(epilogueLines(state))
            }
            return SoCTurnResult([.hint("MARCH to Aylova when you are ready.")])
        }
        guard advances(input) || recountChoice(input) else {
            return SoCTurnResult([.hint("CONTINUE when you are ready.")])
        }

        switch state.thronePhase {
        case .notStarted, .atThrone:
            state.thronePhase = .recountChoice
            return SoCTurnResult(recountChoiceLines())

        case .recountChoice:
            if input.contains("DENTROS") || input.contains("HONOR") {
                state.throneRecountStyle = .honorDentros
            } else {
                state.throneRecountStyle = .reportFacts
            }
            state.thronePhase = .deliverVashirr
            return SoCTurnResult(recountLines(state))

        case .deliverVashirr:
            state.thronePhase = .classService
            return SoCTurnResult(vashirrMessageLines() + kaefdenResponseLines())

        case .classService:
            state.thronePhase = .done
            state.throneAudience = true
            state.warCampBriefed = true
            var lines = classServiceLines(state) + mobilizationLines(state)
            lines.append(.title("Act III Complete"))
            lines.append(.body("The coalition marches at dawn."))
            return SoCTurnResult(lines)

        case .done:
            return SoCTurnResult(epilogueLines(state))
        }
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func departs(_ input: ParsedInput) -> Bool {
        departTriggers.contains { input.contains($0) }
    }

    private func entryLines() -> [StyledLine] {
        [
            .body("You push through the jewel-encrusted doors."),
            .body("Guards snap their spears toward you."),
            .speech("Halt! Identify yourself!"),
            .blank,
            .body("Before you can answer, the woman from the library hurries between you and the blades."),
            .speech("Thekia: Stand down! This druid came through the portal — I vouch for them."),
            .blank,
            .body("The guards hesitate, then part. Thekia leads you toward the dais.")
        ]
    }

    private func throneRoomLines() -> [StyledLine] {
        [
            .title("Nascastrum Throne Room"),
            .body("Blue crystal light washes the hall — the same hue as Anula's fountain, far away in Cataracta."),
            .body("Upon the dais sits King Kaefden IV."),
            .body("His pointed ears mark him as mage-blood; the crown he wears is still new, but the grief in his eyes is not."),
            .body("He studies you in silence. Thekia bows and withdraws to the council benches.")
        ]
    }

    private func recountChoice(_ input: ParsedInput) -> Bool {
        advances(input) || input.contains("DENTROS") || input.contains("HONOR")
            || input.contains("FACTS") || input.contains("REPORT")
    }

    private func recountChoiceLines() -> [StyledLine] {
        [
            .speech("Kaefden IV: Before Vashirr's message — how do you carry Cataracta?"),
            .hint("HONOR DENTROS for his sacrifice, or REPORT FACTS for a soldier's account.")
        ]
    }

    private func recountLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "You" : state.playerName
        var lines: [StyledLine] = [
            .speech("\(name), survivor of Cataracta. Tell us what happened."),
            .blank
        ]
        if state.throneRecountStyle == .honorDentros {
            lines += [
                .body("You speak of Dentros first — how he shoved you from Vashirr's bolt and died for it."),
                .speech("Kaefden IV: ...I know that kind of sacrifice. Go on."),
                .blank
            ]
        } else {
            lines += [
                .body("You give a soldier's report: timestamps, positions, enemy numbers."),
                .speech("Kaefden IV: Clear. Continue."),
                .blank
            ]
        }
        lines += [
            .body("You tell them everything."),
            .body("Kimious's speech. The portal. Vashirr's army."),
            .body("The executions. Waking alone in the ashes."),
            .body("Thekia's face has gone pale; Kaefden's jaw tightens with every word.")
        ]
        if state.throneRecountStyle == .honorDentros {
            lines.append(.speech("Kaefden IV: Dentros bought you time. I will not waste it."))
        }
        return lines
    }

    private func vashirrMessageLines() -> [StyledLine] {
        [
            .speech("Kaefden IV: Then give me his words. Every one."),
            .blank,
            .body("You steady your voice and repeat what Vashirr forced upon you."),
            .blank,
            .speech("Tell King Kaefden IV of the horrors his ignorance has brought."),
            .speech("Tell him that Cataracta and its king have fallen."),
            .speech("Tell him that so long as he holds his unearned claim on this land..."),
            .blank,
            .speech("I will not stop.")
        ]
    }

    private func kaefdenResponseLines() -> [StyledLine] {
        [
            .blank,
            .body("The throne room is utterly still."),
            .speech("Kaefden IV: ...Vashirr always did love his speeches."),
            .speech("I wore this crown at Oceandale's ashes once. I will not let him salt another kingdom."),
            .speech("He mistakes rebuilding for weakness. He mistakes mercy for ignorance."),
            .speech("Kimious is dead. Cataracta is ash. And still the traitor thinks he can frighten a crown I bled to earn."),
            .blank,
            .speech("The coalition marches. Aylova will not wait for another city to burn."),
            .speech("I will not let Nacastrum fall twice.")
        ]
    }

    private func classServiceLines(_ state: SoCGameState) -> [StyledLine] {
        let pledge: String
        switch state.playerClass {
        case .hunter:
            pledge = "I can fight on the front line. Put me where the wolves are needed."
        case .guardian:
            pledge = "I will hold the line. Assign me to the shield wall — I will not break."
        case .scout:
            pledge = "I know how I escaped the castle vents. I can scout ahead and report what the Agromanians are planning."
        case .none:
            pledge = "I will serve however the Legion needs me."
        }
        return [
            .speech("Kaefden IV: And you, druid — what will you do?"),
            .blank,
            .speech(pledge),
            .blank,
            .speech("Kaefden IV: Good. You will march with the Cataractan remnant under coalition command."),
            .speech("Thekia will see you provisioned. When the horns sound for Aylova, you will be ready.")
        ]
    }

    private func mobilizationLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .blank,
            .body("Court scribes scatter to carry orders."),
            .body("For the first time since the ashes, you feel the war has a direction — not just a wound."),
            .blank,
            .symbol("War camp muster at Aylova awaits.")
        ]
    }

    private func epilogueLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Nascastrum Throne Room"),
            .body("The audience is over. Horns echo somewhere beyond the castle walls."),
            .body("Kaefden IV has returned to the map table with his generals."),
            .hint("MARCH to Aylova war camp.")
        ]
    }

    private func departureLines() -> [StyledLine] {
        [
            .body("Thekia meets you at the castle gate with travel papers stamped in coalition wax."),
            .speech("Thekia: Aylova first. The war won't wait for grief."),
            .blank,
            .body("You join the column marching south toward the capital.")
        ]
    }
}
