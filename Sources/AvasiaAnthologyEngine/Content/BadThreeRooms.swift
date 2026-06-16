import Foundation
import AvasiaEngine

// MARK: - Bad #3 — Many Hands Oath

struct BadThreeMarchRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeMarch
    private let advance = ["CONTINUE", "MARCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Western March"),
            .body("The column leaves Cataracta's foothills — your map folded in a sergeant's kit."),
            .body("Paladins talk about wolf-names and bear-oaths. You remember the courtyard overlook: recruits choosing war before they know its shape."),
            .hint("CONTINUE toward camp · LOOK at the column · TALK to a soldier.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("COLUMN") {
            return AnthologyTurnResult([
                .body("Your Cataracta map folded in a sergeant's kit — every gate marked or softened at your briefing."),
                .body("Ash ghosts some brows. The rite ground waits."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("TALK") || input.contains("SOLDIER") {
            return AnthologyTurnResult([
                .speech("Soldier: Vashirr says binding beats hesitation. The ring tonight asks if you believe it."),
                .hint("CONTINUE toward camp.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badThreeCamp))
    }
}

struct BadThreeCampRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeCamp
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Western Camp"),
            .body("Cataracta's lights glimmer from the hills you watched. Cook-fires burn without hurry — victory measured in patience."),
            .speech("Vashirr: \"You saw the druid city. Now the Many Hands must see you.\""),
            .hint("CONTINUE to Vashirr's tent.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badThreeVashirrTent))
    }
}

struct BadThreeVashirrTentRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeVashirrTent
    private let advance = ["CONTINUE", "YES", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Vashirr's Tent"),
            .speech("Vashirr: \"FOLLOW bought you a seat at my fire. It did not buy you my trust.\""),
            .body("He taps the map you made at Cataracta — every gate marked.")
        ]
        if state.badTwoSanitizedReport {
            lines.append(.speech("Vashirr: \"You warned them once. The rite asks whether you still serve two masters.\""))
        } else {
            lines.append(.speech("Vashirr: \"You gave me the perfect map. The rite asks whether your hand is truly ours.\""))
        }
        lines.append(.hint("CONTINUE to the rite ground."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badThreeRite))
    }
}

struct BadThreeRiteRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeRite
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Rite Ground"),
            .body("Paladins kneel in a ring. Ash marks each forehead — the same mark Vashirr wore at the ridge parley."),
            .body("This is not battle drill. This is binding: Many Hands, one will, no private mercy."),
            .hint("CONTINUE to the oath stone · LOOK at the ring.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("RING") {
            return AnthologyTurnResult([
                .body("They breathe in unison. Mira's face flashes unbidden — she broke away when you FOLLOWed. You are still here."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badThreeOath))
    }
}

struct BadThreeOathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeOath
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badThreeOathResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Oath Stone"),
            .speech("Vashirr: \"SWEAR the Many Hands — share breath, share blame, share the westward road. Or REFUSE — and remain eyes only, never fist.\""),
            .hint("SWEAR the oath · REFUSE binding.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badThreeOathResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badThreeAfterOath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("SWEAR") || input.contains("OATH") || input.contains("BIND") {
            state.badThreeOathResolved = true
            state.badThreeSworeOath = true
            return AnthologyTurnResult([
                .body("Ash on your brow. The ring exhales as one — your breath among theirs."),
                .speech("Vashirr: \"Good. The west remembers fists that hesitate.\""),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("REFUSE") || input.contains("EYES") || input.contains("OBSERVE") {
            state.badThreeOathResolved = true
            state.badThreeSworeOath = false
            return AnthologyTurnResult([
                .body("You kneel but do not speak the words. Vashirr's gaze weighs you — not angry, measuring."),
                .speech("Vashirr: \"Then stay useful. Observers also serve.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("SWEAR · REFUSE")])
    }
}

struct BadThreeAfterOathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeAfterOath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badThreeSworeOath {
            return [
                .title("Ring Dispersal"),
                .body("Paladins clasp forearms — your wrist among theirs. The ash mark itches like a brand."),
                .body("Mira is a ghost in the column now. You chose a ring that does not forgive looking back."),
                .hint("CONTINUE.")
            ]
        }
        return [
            .title("Ring Dispersal"),
            .body("The Paladins rise without you. Vashirr assigns latrine duty to a boy who flinched — mercy disguised as discipline."),
            .body("You remain unmarked. Useful, unbound."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badThreeEpilogue))
    }
}

struct BadThreeEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badThreeEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badThreeComplete {
            return [.body("Many Hands Oath — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badThreeSworeOath
            ? "The mark dries on your skin. You are Agroman now in a way REPORT never made you — bound, not merely aligned."
            : "You leave the ring unmarked. Vashirr assigns you recon again — trust without chain."
        return [.title("Camp Quiet"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badThreeComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badThree, state: &state)
        return AnthologyTurnResult([
            .title("Many Hands Oath — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badThree).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
