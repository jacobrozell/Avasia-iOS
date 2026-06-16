import Foundation
import AvasiaEngine

// MARK: - Good #1 — The Oceandale Warning

struct GoodOneSilvariumRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneSilvarium
    private let advance = ["CONTINUE", "YES", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        debriefLines(state) + [.hint("CONTINUE — march for the coast.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("You descend the great tree with the elders' seal on your report.")],
            .move(.goodOneSplitpath)
        )
    }

    private func debriefLines(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [.title("Silvarium — Elders' Hall")]

        if state.miraStatus == .brokeAway {
            lines.append(.speech("Elder Venna: You came alone. Where is your partner?"))
            lines.append(.body("You have no good answer — only the count."))
        } else if state.ridgeOutcome == .withdrew {
            if state.scoutSignalSent {
                lines.append(.speech("Elder Venna: Green smoke on the ridge — thin truth, but timely. How many fires?"))
            } else {
                lines.append(.speech("Elder Venna: You kept orders and returned. How many fires?"))
            }
            lines.append(.body("You give the count. Mira's bark tally matches yours."))
        } else if state.parleyHeardFullSermon {
            lines.append(.speech("Elder Venna: Hundreds of fires. Many Hands banners. You are certain?"))
            lines.append(.speech("Elder Venna: You repeat his sermon too cleanly. What did you see with your own eyes?"))
            lines.append(.body("You strip the poetry. Mira's tally confirms the numbers."))
        } else {
            lines.append(.speech("Elder Venna: Hundreds of fires. Many Hands banners. You are certain?"))
            lines.append(.body("You nod. Mira's written tally confirms yours."))
        }

        lines.append(.speech("Elder Venna: Oceandale must hear this before the ships turn shoreward. Run."))
        return lines
    }
}

struct GoodOneSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneSplitpath
    private let advance = ["CONTINUE", "GO", "EAST"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Coastal Road"),
            .body("Two days hard march. Smoke on the horizon — nets burning, not campfires."),
            .body("Agroman sails still sit on the water. You are late for the ridge, not yet for the pier."),
            .hint("CONTINUE toward Oceandale.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("The colony clamors at the shoreline — chaos, but not overrun.")],
            .move(.goodOneOceandale)
        )
    }
}

struct GoodOneOceandaleRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneOceandale
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Oceandale Front"),
            .body("Fishers pack the pier — children, elders, nets still dripping."),
            .body("Agroman sails sit on the horizon. You have minutes, not hours."),
            .hint("CONTINUE to the pier.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodOnePier))
    }
}

struct GoodOnePierRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOnePier
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodOnePierResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("The Pier"),
            .speech("Fisher: Do we run or hold the church?"),
            .hint("EVACUATE the pier · HOLD the church.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodOnePierResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodOneEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("EVACUATE") || input.contains("PIER") || input.contains("BOATS") {
            state.goodOnePierResolved = true
            state.goodOneEvacuatedPier = true
            return AnthologyTurnResult([
                .body("You drive families toward the boats. Most reach open water before the first landing craft."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("CHURCH") || input.contains("HOLD") {
            state.goodOnePierResolved = true
            state.goodOneEvacuatedPier = false
            return AnthologyTurnResult([
                .body("You bar the church doors. Some survive the night inside — many do not reach it."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("EVACUATE the pier · HOLD the church.")])
    }
}

struct GoodOneEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodOneComplete {
            return [.body("The Oceandale Warning — complete."), .hint("Return to the story hub from the menu.")]
        }
        let outcome = state.goodOneEvacuatedPier
            ? "Most fishers live to curse the horizon another day."
            : "The church stands charred. You saved who you could."
        return [
            .title("Dawn After"),
            .body(outcome),
            .body("Kaefden's war is still distant — but Oceandale will not forget who ran toward the smoke."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodOneComplete else {
            return AnthologyTurnResult([.body("Use the menu to return to Story Adventures.")])
        }
        AnthologyCatalog.complete(.goodOne, state: &state)
        return AnthologyTurnResult([
            .title("The Oceandale Warning — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodOne).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
