import Foundation
import AvasiaEngine

// MARK: - Bad #6 — Western Throne

struct BadSixOccupiedHallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixOccupiedHall
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Occupied Hall"),
            .body("Cataracta's breached gates stand open. Agroman banners hang where druid sigils once grew."),
            .speech("Vashirr: \"Many Hands took the city. Now the west asks who keeps it.\""),
        ]
        if state.badFiveAcceptedCommand {
            lines.append(.body("Officers salute you — the seal on your kit is no longer ceremonial."))
        }
        lines.append(.hint("CONTINUE to the throne room."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badSixThroneRoom))
    }
}

struct BadSixThroneRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixThroneRoom
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badSixThroneResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Western Seat"),
            .speech("Vashirr: \"RULE the occupied hall — keep order without my shadow. Or YIELD the seat — stay fist, never crown.\""),
            .hint("RULE the hall · YIELD the seat.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badSixThroneResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badSixEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("RULE") || input.contains("CROWN") || input.contains("KEEP") {
            state.badSixThroneResolved = true
            state.badSixAcceptedRule = true
            return AnthologyTurnResult([
                .body("You take the western seat. Paladins kneel — not to you alone, but to the order you represent."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("YIELD") || input.contains("REFUSE") || input.contains("SHADOW") {
            state.badSixThroneResolved = true
            state.badSixAcceptedRule = false
            return AnthologyTurnResult([
                .speech("Vashirr: \"Good. Crowns rust. Eyes do not.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("RULE · YIELD")])
    }
}

struct BadSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badSixComplete {
            return [.body("Western Throne — complete.")]
        }
        let line = state.badSixAcceptedRule
            ? "Cataracta's hall answers to your voice. Agroman loyalty became governance — for better or for fire."
            : "You refuse the seat. Vashirr keeps the crown's weight — you keep the westward road."
        return [.title("Occupied Dawn"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badSixComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badSix, state: &state)
        var lines: [StyledLine] = [
            .title("Western Throne — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badSix).fpReward) faction points.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
