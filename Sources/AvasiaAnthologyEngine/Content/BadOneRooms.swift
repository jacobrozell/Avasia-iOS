import Foundation
import AvasiaEngine

// MARK: - Bad #1 — Walking with Vashirr

struct BadOneColumnRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneColumn
    private let advance = ["CONTINUE", "MARCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Agroman Column"),
            .body("Pamphlets in every kit. Shared rations. Vashirr's voice ahead: no looting, no torching granaries."),
            .body("Discipline — not mercy, but something like order."),
            .body("A soldier mutters about a Sylvian scout seen near the Suformin road — Mira's name never spoken, but your ribs tighten."),
            .hint("CONTINUE with the march.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badOneTraining))
    }
}

struct BadOneTrainingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneTraining
    private let advance = ["CONTINUE", "WATCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Training Yard"),
            .body("A farmhand learns to spark his gauntlet. Sergeant Dentros barks corrections — not the Cataracta recruiter, but the name stings."),
            .body("Many Hands works. That is the horror."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badOneAudience))
    }
}

struct BadOneAudienceRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneAudience
    private let advance = ["CONTINUE", "TALK", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Vashirr's Tent"),
            .speech("Vashirr: Do you still think mages should gatekeep while soldiers bleed?"),
            .body("You do not answer quickly enough."),
            .speech("Vashirr: I already know Silvarium watches this ridge. Map what you choose to mark — truth or mercy. I will know which you are."),
            .hint("CONTINUE to the recon task.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badOneRecon))
    }
}

struct BadOneReconRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneRecon
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badOneReconResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Northern Ridge"),
            .body("Silvarium pickets below. You hold a charcoal map and Vashirr's trust — such as it is."),
            .hint("REPORT truthfully · LIE to protect Silvarium.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badOneReconResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badOneEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("TRUTH") || input.contains("REPORT") || input.contains("HONEST") {
            state.badOneReconResolved = true
            state.badOneTruthfulRecon = true
            return AnthologyTurnResult([
                .body("You mark every outpost. Vashirr reads your map without praise or anger."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("LIE") || input.contains("FALSE") || input.contains("PROTECT") {
            state.badOneReconResolved = true
            state.badOneTruthfulRecon = false
            let miraLine = state.miraStatus == .brokeAway
                ? "You erase two camps from the map — one near where Mira fled. You may have bought her a week."
                : "You erase two camps from the map. Mira's face flashes unbidden — you may have bought Silvarium a week."
            return AnthologyTurnResult([
                .body(miraLine),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("REPORT truthfully · LIE to protect Silvarium.")])
    }
}

struct BadOneEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badOneComplete {
            return [.body("Walking with Vashirr — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badOneTruthfulRecon
            ? "Vashirr assigns you another march. You are useful — that is not the same as forgiven."
            : "Vashirr almost smiles. Silvarium will bleed sooner. You feel the weight in your ribs."
        return [
            .title("Column Dust"),
            .body(line),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badOneComplete else {
            return AnthologyTurnResult([.body("Use the menu to return to Story Adventures.")])
        }
        AnthologyCatalog.complete(.badOne, state: &state)
        return AnthologyTurnResult([
            .title("Walking with Vashirr — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badOne).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
