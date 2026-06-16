import Foundation
import AvasiaEngine

// MARK: - Good #6 — The Restoration Accord

struct GoodSixAccordHallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixAccordHall
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Accord Hall"),
            .body("Nacastrum ministers and Sylvian elders share a table — the first since Oceandale burned."),
            .speech("Thekia: \"Your witness stone, your testimony, your hold order — all led here. One signature binds Restoration to Sylva.\""),
            .speech("Elder Venna: \"Or we walk away before the accord becomes another lie.\""),
        ]
        if state.goodFiveSworeWitness {
            lines.append(.body("Your name on the witness stone earns you a seat — not a title, but a voice."))
        }
        lines.append(.hint("CONTINUE to the signing floor."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodSixSigningFloor))
    }
}

struct GoodSixSigningFloorRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixSigningFloor
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodSixAccordResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Signing Floor"),
            .hint("SIGN as Sylvian witness · WALK from the accord.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodSixAccordResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodSixEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("SIGN") || input.contains("WITNESS") || input.contains("ACCORD") {
            state.goodSixAccordResolved = true
            state.goodSixSignedAccord = true
            return AnthologyTurnResult([
                .body("You sign beside Venna and Thekia — scout, courier, witness. The accord is imperfect and real."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("WALK") || input.contains("LEAVE") || input.contains("REFUSE") {
            state.goodSixAccordResolved = true
            state.goodSixSignedAccord = false
            return AnthologyTurnResult([
                .speech("Elder Venna: \"Then bear the truth outside their ink. Sylva survives without their permission.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("SIGN · WALK")])
    }
}

struct GoodSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodSixComplete {
            return [.body("The Restoration Accord — complete.")]
        }
        let line = state.goodSixSignedAccord
            ? "Two banners share a table at last. Loyalty, for you, meant staying until the ink dried."
            : "You leave ministers whispering. Loyalty, for you, meant refusing a peace that forgets Oceandale."
        return [.title("Accord Night"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodSixComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodSix, state: &state)
        var lines: [StyledLine] = [
            .title("The Restoration Accord — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodSix).fpReward) faction points.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
