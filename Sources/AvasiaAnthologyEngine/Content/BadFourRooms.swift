import Foundation
import AvasiaEngine

// MARK: - Bad #4 — Cataracta Breach

struct BadFourApproachRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourApproach
    private let advance = ["CONTINUE", "MARCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Cataracta Approach"),
            .body("The druid city's gates gleam from your map — every weak hinge you marked or softened at the periphery briefing."),
            .body("Varatho mist clings to the lower gardens. From here Cataracta still looks like peace — the lie that keeps recruits enlistment."),
            .speech("Vashirr: \"Many Hands kept you useful. Now the west wants you dangerous.\"")
        ]
        if state.badThreeSworeOath {
            lines.append(.body("Ash still ghosts your brow. The ring expects blood, not recon."))
        } else if state.badTwoSanitizedReport {
            lines.append(.body("You warned them once from the hills. Tonight the warning becomes boots on stone."))
        }
        lines.append(.hint("CONTINUE to the siege line · LOOK at the city."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CITY") || input.contains("GATE") {
            return AnthologyTurnResult([
                .body("Anula blue on the garden trellis — earth-anchor crystal Sylvians gift, not sell. SoC's courtyard is down there, unaware."),
                .body("Fox scouts practice on the wall walk. The fountain still throws copper for luck."),
                .hint("CONTINUE to the siege line.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the city.")])
        }
        return AnthologyTurnResult([], .move(.badFourSiegeLine))
    }
}

struct BadFourSiegeLineRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourSiegeLine
    private let advance = ["CONTINUE", "GO"]
    private let talk = ["TALK", "PALADIN", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Siege Line"),
            .body("Paladins test gauntlets — flesh sparks without a mage in sight. Wolf recruits whisper Fox names — courage borrowed from stories."),
            .body("Cataracta's courtyard still hosts enlistment drills. Kimious will one day die in the massacre you are about to begin."),
            .body("A sergeant folds your map without looking at you. Every weak hinge is already memorized."),
            .hint("CONTINUE to the gate · LOOK at the courtyard · TALK to a Paladin.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("COURTYARD") || input.contains("FOUNTAIN") {
            return AnthologyTurnResult([
                .body("Bear guardians stack shields by the well. A recruit tosses copper — nothing happens. The joke SoC tells before the burn."),
                .body("If you BURN, martyrs multiply. If you STORM, fewer songs — more survivors who remember your face."),
                .hint("CONTINUE to the gate.")
            ])
        }
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Paladin: Hesitation kills more than cruelty. Dentros taught us that in the yard."),
                .speech("You: Tonight you will not hesitate."),
                .hint("CONTINUE to the gate.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK · TALK.")])
        }
        return AnthologyTurnResult([], .move(.badFourGate))
    }
}

struct BadFourGateRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourGate
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badFourGateResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Garden Gate"),
            .body("Vashirr stands where you sketched the weak hinge — lamp-light on the scar at his eye."),
            .speech("Vashirr: \"BURN — torches and terror, one night. STORM — measured breach, fewer martyrs for their songs.\""),
            .body("The city sleeps behind crystal and oath. Your hand will choose how it wakes."),
            .hint("BURN the gate · STORM with discipline.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badFourGateResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badFourEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("BURN") || input.contains("TORCH") || input.contains("FIRE") {
            state.badFourGateResolved = true
            state.badFourMeasuredAssault = false
            return AnthologyTurnResult([
                .body("Flame catches garden trellis. Cataracta wakes to orange — your map made flesh."),
                .body("Screams mix with the fountain's splash. Many Hands will call it justice. The grove will not."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("STORM") || input.contains("DISCIPLINE") || input.contains("BREACH") {
            state.badFourGateResolved = true
            state.badFourMeasuredAssault = true
            return AnthologyTurnResult([
                .body("Paladins hit the weak hinge in silence. Vashirr nods — terror is a tool, not a hunger."),
                .body("The gate falls with soldiers, not bonfires. Cataracta's songs will call it invasion — not accident."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("BURN · STORM")])
    }
}

struct BadFourEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badFourComplete {
            return [.body("Cataracta Breach — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badFourMeasuredAssault
            ? "The gate falls with soldiers, not bonfires. Cataracta's songs will call it invasion — not accident."
            : "Fire climbs the groves. You chose spectacle. Many Hands will call it justice."
        return [.title("Hills at Dawn"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badFourComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badFour, state: &state)
        return AnthologyTurnResult([
            .title("Cataracta Breach — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badFour).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
