import Foundation
import AvasiaEngine

// MARK: - Good #4 — Restoration Mobilization

struct GoodFourMobilizationCampRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourMobilizationCamp
    private let advance = ["CONTINUE", "GO", "MARCH"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Oceandale Front"),
            .body("Sylvian militia dig in where fishers once mended nets. Restoration banners mix with elder witness flags."),
            .speech("Thekia: \"The court heard you — or enough. Now the shore must decide whether to hold or push.\"")
        ]
        if state.goodThreePublicTestimony {
            lines.append(.body("Your public testimony still burns in ministerial dispatches."))
        }
        lines.append(.hint("CONTINUE to command."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodFourCommandTent))
    }
}

struct GoodFourCommandTentRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourCommandTent
    private let advance = ["CONTINUE", "ENTER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Command Tent"),
            .body("Maps show Agroman columns west and Restoration reserves east. Neither side has won — both sides are counting bodies."),
            .speech("Officer: \"We can HOLD the pier line and evacuate more coast. Or PUSH now — hit their camp before Paladins consolidate.\""),
            .hint("CONTINUE to the briefing.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodFourBriefing))
    }
}

struct GoodFourBriefingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourBriefing
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFourBriefingResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Mobilization Briefing"),
            .speech("Thekia: \"HOLD — save civilians, bleed them slowly. PUSH — strike before Many Hands swells the valley.\""),
            .hint("HOLD the pier line · PUSH the western camp.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodFourBriefingResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodFourEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("HOLD") || input.contains("DEFEND") || input.contains("EVACUATE") {
            state.goodFourBriefingResolved = true
            state.goodFourHoldLine = true
            return AnthologyTurnResult([
                .body("You argue for time — nets before glory. The officer grumbles but reroutes barges."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("PUSH") || input.contains("STRIKE") || input.contains("ATTACK") {
            state.goodFourBriefingResolved = true
            state.goodFourHoldLine = false
            return AnthologyTurnResult([
                .body("You mark the Agroman camp for dawn assault. Thekia's face hardens — she wanted survivors first."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("HOLD · PUSH")])
    }
}

struct GoodFourEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFourComplete {
            return [.body("Restoration Mobilization — complete.")]
        }
        let line = state.goodFourHoldLine
            ? "Smoke rises from evacuation barges, not victory pyres. Loyalty measured in lives landed — not headlines."
            : "Horns at dawn. You chose the fist Restoration wanted. The shore will learn if it was mercy or appetite."
        return [.title("Shore Wind"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodFourComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodFour, state: &state)
        return AnthologyTurnResult([
            .title("Restoration Mobilization — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodFour).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
