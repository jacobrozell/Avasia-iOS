import Foundation
import AvasiaEngine

// MARK: - Neutral #2 — The Cave Record

struct CaveRecordTrailRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .caveRecordTrail
    private let advance = ["CONTINUE", "GO", "CLIMB"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Mountain Trail"),
            .body("Wind off the KoN ridge strips bark from dead pines. The elk feast is two valleys behind you — smoke, song, no banners."),
            .body("Elder Suformin pressed a map into your hand at dawn: prison caves repurposed before Inflame was hidden in the pink crystal below."),
            .speech("Suformin: \"A scholar copied trial records there. Neutral ink. The court burned the originals.\""),
            .hint("CONTINUE toward the entrance · LOOK at the map.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("MAP") || input.contains("READ") {
            return AnthologyTurnResult([
                .body("Ash lines mark a switchback — manacle rings sketched beside a fork in the tunnel."),
                .body("Margin note in Suformin's hand: \"Schism fable on the wall. Do not trust Restoration summaries.\""),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("The trail drops into cold shadow. Pink light pulses from below like a heartbeat.")],
            .move(.caveRecordEntrance)
        )
    }
}

struct CaveRecordEntranceRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .caveRecordEntrance
    private let advance = ["CONTINUE", "ENTER", "DOWN"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Cave Entrance"),
            .body("Iron rings rust in the wall — old manacles, wrist-height, spaced for kneeling prisoners."),
            .body("Pink crystal light bleeds from deeper tunnels. This was a jail before it was a tomb."),
            .hint("CONTINUE into the cavern · LOOK at the graffiti.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("GRAFFITI") || input.contains("SCRATCH") {
            return AnthologyTurnResult([
                .body("Names and dates — Sylvian script, Agroman numerals, a third hand that never learned either alphabet."),
                .body("The schism fable in shorthand: two hands on one wrist; the court asked which hand held the knife."),
                .body("Someone carved beneath it: \"Both. Always both.\""),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.caveRecordCavern))
    }
}

struct CaveRecordCavernRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .caveRecordCavern
    private let advance = ["CONTINUE", "GO", "NORTH"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Pink Crystal Cavern"),
            .body("Translucent shards throw rose light on collapsed cages. Mages stored Inflame here once — the air still tastes of old fire."),
            .body("A side passage smells of ink and lamp-oil, not blood. Boot prints in the dust, weeks old."),
            .hint("CONTINUE to the archive nook · LOOK at the cages.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CAGE") || input.contains("CRYSTAL") {
            return AnthologyTurnResult([
                .body("Crystal veins run through the stone like frozen lightning. Prisoners must have watched mages seal spell-jars in the walls."),
                .body("A broken cage door lies on its side — someone left in a hurry, not in chains."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("The ink-smell sharpens. A dry nook ahead — someone lived here recently enough to stack bark sheets.")],
            .move(.caveRecordArchive)
        )
    }
}

struct CaveRecordArchiveRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .caveRecordArchive
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.caveRecordArchiveResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Scholar's Nook"),
            .body("Bark sheets stacked dry on a stone shelf — a neutral archivist copied trial records before the prison closed."),
            .body("Trials of schism-era partisans: who fed whom, who burned whose grove, who signed which surrender."),
            .speech("Margin note: \"Two hands of one body — but who cut the wrist? Restoration wants a single villain. The record refuses.\""),
            .hint("COPY the archive for Silvarium · LEAVE it hidden.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.caveRecordArchiveResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.caveRecordEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LOOK") || input.contains("READ") {
            return AnthologyTurnResult([
                .body("One sheet names a Sylvian elder who traded grain to Agroman camps — and a Paladin who looked away."),
                .body("Neither side is clean. Neither side wants this published."),
                .hint("COPY the archive · LEAVE it hidden.")
            ])
        }
        if input.contains("COPY") || input.contains("TAKE") || input.contains("SILVARIUM") {
            state.caveRecordArchiveResolved = true
            state.caveRecordCopiedArchive = true
            return AnthologyTurnResult([
                .body("You pack the bark sheets into oilcloth. Truth travels — and so does blame."),
                .speech("You: \"Elder Venna can read what the court erased.\""),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("LEAVE") || input.contains("HIDDEN") || input.contains("SECRET") {
            state.caveRecordArchiveResolved = true
            state.caveRecordCopiedArchive = false
            return AnthologyTurnResult([
                .body("You memorise the schism fable and the worst names on the list. The ink stays where war cannot burn it yet."),
                .body("Memory is a kind of archive — just one that dies with you."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("COPY the archive · LEAVE it hidden.")])
    }
}

struct CaveRecordEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .caveRecordEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.caveRecordComplete {
            return [.body("The Cave Record — complete.")]
        }
        if state.caveRecordCopiedArchive {
            return [
                .title("Surface Light"),
                .body("Day blinds you after the pink dark. The pack weighs more than bark — it weighs like a verdict waiting to be read."),
                .body("Elder Venna may finally see what Restoration summaries left out. You carry weight, not a banner."),
                .hint("CONTINUE.")
            ]
        }
        return [
            .title("Surface Light"),
            .body("Day blinds you. The cave keeps its counsel; the schism fable lives only behind your eyes now."),
            .body("Suformin will nod when you describe the wall — and never ask if you brought the sheets."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.caveRecordComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.caveRecord, state: &state)
        return AnthologyTurnResult([
            .title("The Cave Record — complete"),
            .body("+\(AnthologyCatalog.meta(for: .caveRecord).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
