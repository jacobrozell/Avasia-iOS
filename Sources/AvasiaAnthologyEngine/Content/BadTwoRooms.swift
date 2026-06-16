import Foundation
import AvasiaEngine

// MARK: - Bad #2 — Cataracta Periphery

struct BadTwoPeripheryRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badTwoPeriphery
    private let advance = ["CONTINUE", "GO", "CLIMB"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Cataracta Foothills"),
            .body("The druid city sits in its mountain bowl — peaceful from a distance, which is the lie."),
            .body("Vashirr's officer points: map the gates, the garden paths, the courtyard where legions enlist."),
            .hint("CONTINUE to the overlook.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badTwoOverlook))
    }
}

struct BadTwoOverlookRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badTwoOverlook
    private let advance = ["CONTINUE", "WATCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Courtyard Overlook"),
            .body("Wolf, Bear, Fox — recruits choose names before they choose war."),
            .body("You remember Scout Patrol's valley. This city does not know yet."),
            .hint("CONTINUE to the briefing.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badTwoBriefing))
    }
}

struct BadTwoBriefingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badTwoBriefing
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badTwoBriefingResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Vashirr's Briefing"),
            .speech("Vashirr: When the portals open, Cataracta falls in one night. Your map decides how few Agroman soldiers burn."),
            .hint("FULL map for Vashirr · SANITIZE to warn the city quietly.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badTwoBriefingResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badTwoEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("FULL") || input.contains("MAP") || input.contains("VASHIRR") {
            state.badTwoBriefingResolved = true
            state.badTwoSanitizedReport = false
            return AnthologyTurnResult([
                .body("You mark every weak gate. Vashirr rolls the parchment without looking at you."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("SANITIZE") || input.contains("WARN") || input.contains("SLIP") {
            state.badTwoBriefingResolved = true
            state.badTwoSanitizedReport = true
            return AnthologyTurnResult([
                .body("You smuggle a thin warning toward a garden patrol — treason with a merciful face."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("FULL map · SANITIZE to warn Cataracta.")])
    }
}

struct BadTwoEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badTwoEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badTwoComplete {
            return [.body("Cataracta Periphery — complete.")]
        }
        let line = state.badTwoSanitizedReport
            ? "A fox scout may find your scrap of truth. You will not be there to see if it matters."
            : "The map is perfect. Cataracta's ashes are already written in your hand."
        return [.title("Hills at Dusk"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badTwoComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badTwo, state: &state)
        return AnthologyTurnResult([
            .title("Cataracta Periphery — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badTwo).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
