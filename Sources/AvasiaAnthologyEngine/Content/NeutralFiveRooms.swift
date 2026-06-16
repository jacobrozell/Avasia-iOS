import Foundation
import AvasiaEngine

// MARK: - Neutral #5 — The Unmarked Road

struct NeutralFiveSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveSplitpath
    private let advance = ["CONTINUE", "GO", "WALK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Splitpath Crossroads"),
            .body("War maps redrawn again. Market awnings fold. Traders pack before the next sermon becomes law."),
            .body("Three roads: north to Sylva, west to Agroma, east to the coast and away from both.")
        ]
        if state.neutralFourStayedWitness {
            lines.append(.body("Cellious's ledger still lists your signature — neutral ink in an partisan age."))
        }
        lines.append(.hint("CONTINUE to the mile marker."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralFiveMileMarker))
    }
}

struct NeutralFiveMileMarkerRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveMileMarker
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFiveRoadResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Mile Marker"),
            .speech("Suformin: \"LEAVE — walk east until banners blur. Or STAY — Splitpath still needs brokers who refuse sermons.\""),
            .hint("LEAVE the war behind · STAY on the unmarked road.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralFiveRoadResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralFiveEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LEAVE") || input.contains("EAST") || input.contains("DEPART") {
            state.neutralFiveRoadResolved = true
            state.neutralFiveStayedOnRoad = false
            return AnthologyTurnResult([
                .body("You choose distance — not denial. The coast road swallows your footprints."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("STAY") || input.contains("REMAIN") || input.contains("BROKER") {
            state.neutralFiveRoadResolved = true
            state.neutralFiveStayedOnRoad = true
            return AnthologyTurnResult([
                .speech("Suformin: \"Then keep the market honest. Neutrality is work, not absence.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("LEAVE · STAY")])
    }
}

struct NeutralFiveEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFiveComplete {
            return [.body("The Unmarked Road — complete.")]
        }
        let line = state.neutralFiveStayedOnRoad
            ? "Splitpath keeps you — not as hero, but as hinge. Neutrality ends where your work begins."
            : "The coast wind erases ash smell. You leave no carving, no oath — only the stories you carry unnamed."
        return [.title("Road's End"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.neutralFiveComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.neutralFive, state: &state)
        return AnthologyTurnResult([
            .title("The Unmarked Road — complete"),
            .body("+\(AnthologyCatalog.meta(for: .neutralFive).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
