import Foundation
import AvasiaEngine

// MARK: - Bad #4 — Cataracta Breach

struct BadFourApproachRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourApproach
    private let advance = ["CONTINUE", "MARCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Cataracta Approach"),
            .body("The druid city's gates gleam from your map — every weak hinge you marked or softened."),
            .speech("Vashirr: \"Many Hands kept you useful. Now the west wants you dangerous.\"")
        ]
        if state.badThreeSworeOath {
            lines.append(.body("Ash still ghosts your brow. The ring expects blood, not recon."))
        }
        lines.append(.hint("CONTINUE to the siege line."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badFourSiegeLine))
    }
}

struct BadFourSiegeLineRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badFourSiegeLine
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Siege Line"),
            .body("Paladins test gauntlets. Wolf recruits whisper Fox names — courage borrowed from stories."),
            .body("Cataracta's courtyard still hosts enlistment drills. They do not know the map is already in Agroman hands."),
            .hint("CONTINUE to the gate.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
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
            .speech("Vashirr: \"BURN — torches and terror, one night. STORM — measured breach, fewer martyrs for their songs.\""),
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
                .hint("CONTINUE.")
            ])
        }
        if input.contains("STORM") || input.contains("DISCIPLINE") || input.contains("BREACH") {
            state.badFourGateResolved = true
            state.badFourMeasuredAssault = true
            return AnthologyTurnResult([
                .body("Paladins hit the weak hinge in silence. Vashirr nods — terror is a tool, not a hunger."),
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
            return [.body("Cataracta Breach — complete.")]
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
            .body("+\(AnthologyCatalog.meta(for: .badFour).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
