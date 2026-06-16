import Foundation
import AvasiaEngine

// MARK: - Elk Feast

struct ElkSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkSplitpath
    private let advance = ["CONTINUE", "GO", "WALK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Splitpath Dusk"),
            .body("War banners nowhere near — only cook-smoke and an elk horn call from the treeline east."),
            .body("You chose REFUSE at the ridge fork. No REPORT seal, no FOLLOW column — just the road and your pack.")
        ]
        if state.miraStatus == .brokeAway {
            lines.append(.body("Mira's absence rides with you. Truce week does not bring partners back."))
        }
        lines.append(.hint("CONTINUE toward the firelight · LISTEN for the horn."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LISTEN") || input.contains("HORN") {
            return AnthologyTurnResult([
                .body("Three notes — old Sylvian pattern. Not alarm. Invitation before the schism became law."),
                .hint("CONTINUE toward the firelight.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LISTEN for the horn.")])
        }
        return AnthologyTurnResult(
            [.body("Firelight bleeds between pines. Voices — laughter, not drill commands.")],
            .move(.elkHoldfast)
        )
    }
}

struct ElkHoldfastRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .elkHoldfast
    private let advance = ["CONTINUE", "TALK", "ASK", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Neutral Holdfast"),
            .body("Hunters gut an elk while children chase each other between tents — truce week, predating the schism, still observed where armies forget to look."),
            .body("No Restoration blue, no Agroman iron on the gate. Only a horn and a rule: leave swords, keep peace."),
            .speech("Elder Suformin: Traveler? Truce week still means a seat if you leave swords at the gate."),
            .body("No one asks which sermon you walked out on — only whether you come in peace."),
            .hint("TALK or CONTINUE to accept · LOOK at the camp.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CAMP") {
            return AnthologyTurnResult([
                .body("Families from three valleys — some Sylvian, some mainland, a few who will not say. The elk turns on a spit that could feed an army if armies were invited."),
                .hint("TALK or CONTINUE to accept.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("TALK or CONTINUE to accept.")])
        }
        return AnthologyTurnResult(
            [
                .body("You leave your knife with the gate guard — a woman who lost a brother at Aylova and does not ask whose side took him."),
                .body("Greasy smoke welcomes you before Suformin does.")
            ],
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
            .body("Greasy warmth. Old songs in a language that predates Restoration and Agroman both — syllables for harvest, not war."),
            .body("Someone passes you elk rib and bitter root tea. Your hands shake from ridge cold, not fear."),
            .speech("Elder Suformin: Two hands of one body — the schism fable. We tell it as warning, not recruitment."),
            .body("For one night the war is a story told around fire, not a boot on your neck."),
            .hint("CONTINUE into the night · TALK to Suformin · LISTEN to the songs.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LISTEN") || input.contains("SONG") {
            return AnthologyTurnResult([
                .body("A hunter sings of Suformin's line founding this holdfast before brothers split Aylova — when elk fed everyone and magic lived in gifts, not gates."),
                .hint("CONTINUE · TALK to Suformin.")
            ])
        }
        if input.contains("TALK") || input.contains("ASK") || input.contains("SCHISM") {
            return AnthologyTurnResult([
                .speech("Elder Suformin: Suformin's line founded this holdfast before Restoration split the roads."),
                .speech("Elder Suformin: The youngest prince turned protest into violence. We remember — we do not recruit for either side at truce fire."),
                .speech("Elder Suformin: Tomorrow the armies still exist. Tonight we eat."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK · LISTEN.")])
        }
        return AnthologyTurnResult(
            [
                .body("Dawn graying. You are full, and ashamed of how good that feels."),
                .body("Suformin presses a map into your hand at the fire's edge — prison caves, he says. Neutral ink waits there for scouts who refuse banners.")
            ],
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
            .body("Armies still exist beyond the treeline — valley fires, Many Hands pamphlets, Restoration couriers on the western road."),
            .body("You leave unchanged in allegiance — neutral, still — not unchanged in spirit."),
            .body("The map in your pack points toward KoN's mountain ridge. Truce week ends when you walk, not when the horn stops."),
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
