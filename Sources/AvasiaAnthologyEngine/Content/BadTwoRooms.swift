import Foundation
import AvasiaEngine

// MARK: - Bad #2 — Cataracta Periphery

struct BadTwoPeripheryRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badTwoPeriphery
    private let advance = ["CONTINUE", "GO", "CLIMB"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Cataracta Foothills"),
            .body("The druid city sits in its mountain bowl — Varatho mist on the lower gardens, peace from a distance, which is the lie that keeps recruits enlistment."),
            .body("Vashirr's officer points without ceremony: map the gates, the garden paths, the courtyard where legions enlist.")
        ]
        if state.badOneTruthfulRecon {
            lines.append(.body("He trusts your ridge honesty. This map will be worse — closer, named, irreversible."))
        } else {
            lines.append(.body("He almost smiled at your softened ridge map. Cataracta will not get the same mercy."))
        }
        lines.append(.hint("CONTINUE to the overlook · LOOK at the city."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CITY") || input.contains("CATARACTA") {
            return AnthologyTurnResult([
                .body("Anula blue on the garden gates — earth-anchor crystal Sylvians gift, not sell. SoC's courtyard is down there, unaware."),
                .hint("CONTINUE to the overlook.")
            ])
        }
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
            .body("Wolf, Bear, Fox — recruits choose class names before they choose war. Dentros will one day assign them in SoC's courtyard. Kimious will one day die in the massacre you are mapping."),
            .body("Fountain coin toss — a recruit throws copper, nothing happens. The joke SoC tells before the burn."),
            .body("You remember Scout Patrol's valley. This city does not know yet."),
            .hint("CONTINUE to the briefing · LOOK at the courtyard.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("COURTYARD") || input.contains("FOUNTAIN") {
            return AnthologyTurnResult([
                .body("Fox scouts practice silent movement. Bear guardians stack shields. Wolf hunters watch the gates — discipline without Paladin binding yet."),
                .body("If you SANITIZE the map, one of them may find your warning. If you FULL map, they will learn too late."),
                .hint("CONTINUE to the briefing.")
            ])
        }
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
