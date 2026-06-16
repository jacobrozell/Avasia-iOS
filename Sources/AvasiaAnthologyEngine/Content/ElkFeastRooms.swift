import Foundation
import AvasiaEngine

// MARK: - Elk Feast

struct ElkSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkSplitpath
    private let advance = ["CONTINUE", "GO", "WALK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Splitpath Dusk"),
            .body("War banners nowhere near — only cook-smoke and a elk horn call."),
            .hint("CONTINUE toward the firelight.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.elkHoldfast))
    }
}

struct ElkHoldfastRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkHoldfast
    private let advance = ["CONTINUE", "TALK", "ASK", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Neutral Holdfast"),
            .body("Hunters gut an elk while children chase each other between tents."),
            .speech("Elder Suformin: Traveler? Truce week still means a seat if you leave swords at the gate."),
            .body("No one asks which sermon you walked out on — only whether you come in peace."),
            .hint("TALK or CONTINUE to accept.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("TALK or CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("You leave your knife with the gate guard and walk toward the spit.")],
            .move(.elkFeast)
        )
    }
}

struct ElkFeastRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkFeast
    private let advance = ["CONTINUE", "LISTEN", "EAT"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("The Elk Feast"),
            .body("Greasy warmth. Old songs. No one asks which army you refused."),
            .speech("Elder Suformin: Two hands of one body — the schism fable. We tell it as warning, not recruitment."),
            .body("For one night the war is a story told around fire, not a boot on your neck."),
            .hint("CONTINUE into the night.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("TALK") || input.contains("ASK") {
            return AnthologyTurnResult([
                .speech("Elder Suformin: Suformin's line founded this holdfast before Restoration split the roads."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("Dawn graying. You are full, and ashamed of how good that feels.")],
            .move(.elkEpilogue)
        )
    }
}

struct ElkEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.elkFeastComplete {
            return [.body("The Elk Feast — complete."), .hint("Return to the story hub from the menu.")]
        }
        return [
            .title("Cold Morning"),
            .body("Armies still exist beyond the treeline. You leave unchanged in allegiance — not unchanged in spirit."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.elkFeastComplete else {
            return AnthologyTurnResult([.body("Use the menu to return to Story Adventures.")])
        }
        AnthologyCatalog.complete(.elkFeast, state: &state)
        return AnthologyTurnResult([
            .title("The Elk Feast — complete"),
            .body("+\(AnthologyCatalog.meta(for: .elkFeast).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
