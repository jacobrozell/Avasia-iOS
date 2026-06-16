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
            .body("Agroman banners hang where druid sigils once grew. Officers argue over desks before the counterattack comes."),
            .speech("Vashirr: \"Many Hands won the gate. Now the west asks who leads the next march.\"")
        ]
        if state.badFourMeasuredAssault {
            lines.append(.body("Discipline at the gate bought respect. The column listens when you speak."))
        } else {
            lines.append(.body("Fire climbed the groves last night. The column celebrates — you taste ash on your tongue."))
        }
        if state.badThreeSworeOath {
            lines.append(.body("The ash mark on your brow has faded to memory. The ring has not."))
        }
        lines.append(.hint("CONTINUE to the command fire · LOOK at the camp."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CAMP") || input.contains("BANNER") {
            return AnthologyTurnResult([
                .body("A governor's desk sits empty under canvas — Vashirr has not named who sits there yet."),
                .body("Mira is still a ghost in the column. You chose FOLLOW. The west chose you back."),
                .hint("CONTINUE to the command fire.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the camp.")])
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
            .body("Officers wait in a ring — not Paladin binding, but close. Vashirr offers a field seal: interlocking hands cast in metal."),
            .speech("Vashirr: \"ACCEPT western command — order strikes without my voice. Or DECLINE — stay scout, never general.\""),
            .body("The seal is warm before you touch it. Orders will obey you now — or never."),
            .hint("ACCEPT command · DECLINE the seal · TALK to Vashirr.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badFiveCommandResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badFiveEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("TALK") || input.contains("ASK") || input.contains("VASHIRR") {
            return AnthologyTurnResult([
                .speech("Vashirr: Generals hunger. Scouts see. I need both — I cannot be both."),
                .speech("Vashirr: Choose which hunger you feed."),
                .hint("ACCEPT · DECLINE.")
            ])
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
        return AnthologyTurnResult([.hint("ACCEPT · DECLINE · TALK.")])
    }
}

struct BadFiveEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFiveEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badFiveComplete {
            return [.body("Western Command — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badFiveAcceptedCommand
            ? "Horns answer your gesture. You are Agroman's fist now — not Vashirr's shadow."
            : "The seal stays with Vashirr. You remain the scout who walks between fires — close, uncrowned."
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
            .body("+\(AnthologyCatalog.meta(for: .badFive).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
