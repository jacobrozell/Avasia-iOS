import Foundation
import AvasiaEngine

// MARK: - Bad #5 — Western Command

struct BadFiveCampRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFiveCamp
    private let advance = ["CONTINUE", "GO", "MARCH"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Western Command"),
            .body("Cataracta's breach smoke still stains the horizon. Paladins treat you as proven — not probationary."),
            .speech("Vashirr: \"Many Hands won the gate. Now the west asks who leads the next march.\"")
        ]
        if state.badFourMeasuredAssault {
            lines.append(.body("Discipline at the gate bought respect. The column listens when you speak."))
        }
        lines.append(.hint("CONTINUE to the command fire."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badFiveCommandFire))
    }
}

struct BadFiveCommandFireRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFiveCommandFire
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badFiveCommandResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Command Fire"),
            .body("Officers wait. Vashirr offers a field seal — authority to order strikes without his voice."),
            .speech("Vashirr: \"ACCEPT western command. Or DECLINE — stay scout, never general.\""),
            .hint("ACCEPT command · DECLINE the seal.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badFiveCommandResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badFiveEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("ACCEPT") || input.contains("COMMAND") || input.contains("LEAD") {
            state.badFiveCommandResolved = true
            state.badFiveAcceptedCommand = true
            return AnthologyTurnResult([
                .body("The seal is warm — metal shaped like interlocking hands. Orders will obey you now."),
                .speech("Vashirr: \"Use it. Hesitation kills more than cruelty.\""),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("DECLINE") || input.contains("SCOUT") || input.contains("REFUSE") {
            state.badFiveCommandResolved = true
            state.badFiveAcceptedCommand = false
            return AnthologyTurnResult([
                .body("You push the seal back across the fire. Vashirr studies you — not displeased."),
                .speech("Vashirr: \"Then see clearly. Generals need eyes that do not hunger.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("ACCEPT · DECLINE")])
    }
}

struct BadFiveEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFiveEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badFiveComplete {
            return [.body("Western Command — complete.")]
        }
        let line = state.badFiveAcceptedCommand
            ? "Horns answer your gesture. You are Agroman's fist now — not Vashirr's shadow."
            : "The seal stays with Vashirr. You remain the scout who walks between fires — close, un crowned."
        return [.title("Camp Before Dawn"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badFiveComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badFive, state: &state)
        return AnthologyTurnResult([
            .title("Western Command — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badFive).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
