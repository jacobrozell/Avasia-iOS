import Foundation
import AvasiaEngine

/// Age-era epilogue at Aylova — closes Sword of Courage (iOS authored).
struct SoCAgeEpilogueRoom: SoCRoomScript {
    let id: SoCRoomID = .ageEpilogue
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "YES", "PROCEED"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.ageEpiloguePhase == .notStarted else { return nil }
        state.ageEpiloguePhase = .memorial
        return returnLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.gameComplete {
            if !state.ruinsVisited {
                return epilogueCompleteLines(state) + [.hint("VISIT RUINS for a final pilgrimage, or stay in Aylova.")]
            }
            return epilogueCompleteLines(state)
        }
        switch state.ageEpiloguePhase {
        case .notStarted, .memorial:
            return [.hint("CONTINUE to the memorial.")]
        case .kaefdenSpeech:
            return [.hint("CONTINUE.")]
        case .done:
            return epilogueCompleteLines(state)
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.gameComplete {
            if !state.ruinsVisited,
               input.contains("VISIT") || input.contains("RUINS") || input.contains("CATARACTA") {
                return SoCTurnResult([.body("You request leave to walk the road to Cataracta one last time.")], .move(.cataractaRuins))
            }
            return SoCTurnResult(epilogueCompleteLines(state))
        }

        guard advances(input) else {
            return SoCTurnResult([.hint("CONTINUE.")])
        }

        switch state.ageEpiloguePhase {
        case .notStarted, .memorial:
            state.ageEpiloguePhase = .kaefdenSpeech
            return SoCTurnResult(memorialLines(state))

        case .kaefdenSpeech:
            state.ageEpiloguePhase = .done
            state.gameComplete = true
            state.unlockTrophy(.ageComplete)
            var lines = kaefdenSpeechLines(state)
            lines.append(.title("Sword of Courage — Complete"))
            lines.append(.body("The Age-era text saga ends here. A new era awaits in a different form."))
            if !state.ruinsVisited {
                lines.append(.hint("Optional: VISIT RUINS before you rest."))
            }
            return SoCTurnResult(lines)

        case .done:
            return SoCTurnResult(epilogueCompleteLines(state))
        }
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func returnLines() -> [StyledLine] {
        [
            .title("Aylova"),
            .body("Weeks later, you march through Aylova's gates behind Kaefden's victorious column."),
            .body("Citizens line the streets. Some cheer. Many weep for names on the memorial lists.")
        ]
    }

    private func memorialLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .blank,
            .body("In the square, a new stone lists the fallen of Cataracta — Kimious, Dentros, and thousands without names."),
            .body("Thekia lights a blue crystal at the base. You stand with the handful who survived the courtyard."),
            .speech("Thekia: We carry them forward. All of them."),
            .blank,
            .body("Kaefden IV takes the dais. He looks older than the throne room, and more certain.")
        ]
    }

    private func kaefdenSpeechLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "Survivor" : state.playerName
        var lines: [StyledLine] = [
            .speech("Kaefden IV: Cataracta burned so this coalition could learn the cost of delay."),
            .speech("Vashirr's portals are shattered. His war mages scatter. He will answer to Kaefden law."),
            .blank,
            .speech("\(name) — you delivered his threat to my throne, and you held Oceandale when I asked.")
        ]
        if state.throneRecountStyle == .honorDentros {
            lines.append(.speech("Kaefden IV: You honored Dentros before my court. That matters to me."))
        }
        lines += [
            .speech("The Druid Legion of Cataracta is not ended. It is reborn in those who lived."),
            .blank,
            .body("The crowd erupts. You feel Dentros's sacrifice, Kimious's speech, and the ashes — all carried to this moment."),
            .blank,
            .symbol("The Age of Courage closes.")
        ]
        return lines
    }

    private func epilogueCompleteLines(_ state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Aylova"),
            .body("The celebration fades. You remain — a soldier who saw the war from enlistment to victory."),
            .body("Deaths suffered: \(state.deathCount) · Level \(state.playerLevel) · Trophies: \(state.trophies.count)/\(SoCTrophy.allCases.count)")
        ]
        if state.ruinsVisited {
            lines.append(.body("You walked Cataracta's ruins and closed the circle."))
        }
        lines.append(.hint("Thank you for playing Avasia: Sword of Courage."))
        return lines
    }
}
