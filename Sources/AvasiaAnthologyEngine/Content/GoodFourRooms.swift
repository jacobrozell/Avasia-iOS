import Foundation
import AvasiaEngine

// MARK: - Good #4 — Restoration Mobilization

struct GoodFourMobilizationCampRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourMobilizationCamp
    private let advance = ["CONTINUE", "GO", "MARCH"]
    private let talk = ["TALK", "THEKIA", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Oceandale Front"),
            .body("Sylvian militia dig in where fishers once mended nets. Restoration banners mix with elder witness flags — cousins who share blood, not always trust."),
            .body("The pier still smells of brine and old smoke. Empty boats rock where you once drove families toward open water."),
            .speech("Thekia: \"The court heard you — or enough. Now the shore must decide whether to hold or push.\"")
        ]
        if state.goodThreePublicTestimony {
            lines.append(.body("Your public testimony still burns in ministerial dispatches — names the Restoration wished to file under tragedy."))
        } else if state.goodOneEvacuatedPier {
            lines.append(.body("Most of the pier lived because you ran toward the boats. The militia remembers who came back."))
        }
        lines.append(.hint("CONTINUE to command · TALK to Thekia · LOOK at the shore."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Thekia: \"HOLD saves nets and children. PUSH saves time — and costs both.\""),
                .speech("Thekia: \"I will not choose for you. Kaefden already chose mobilization.\""),
                .hint("CONTINUE to command.")
            ])
        }
        if input.contains("LOOK") || input.contains("SHORE") || input.contains("PIER") {
            return AnthologyTurnResult([
                .body("Barricades where nets dried. A fisher's pendant — blue crystal, Sylvian make — hangs on a peg driven into the pier."),
                .body("Agroman sails still sit patient on the horizon, as if the first landing was rehearsal."),
                .hint("CONTINUE to command.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK · LOOK.")])
        }
        return AnthologyTurnResult([], .move(.goodFourCommandTent))
    }
}

struct GoodFourCommandTentRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourCommandTent
    private let advance = ["CONTINUE", "ENTER"]
    private let talk = ["TALK", "OFFICER", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Command Tent"),
            .body("Maps show Agroman columns west and Restoration reserves east. Neither side has won — both sides are counting bodies."),
            .body("Red pins mark Paladin drill yards you reported +ed from the ridge. Green pins mark barges Thekia rerouted overnight."),
            .speech("Officer: \"We can HOLD the pier line and evacuate more coast. Or PUSH now — hit their camp before Paladins consolidate.\""),
            .hint("CONTINUE to the briefing · LOOK at the maps · TALK to the officer.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("MAP") {
            return AnthologyTurnResult([
                .body("The western camp sits in a river bend — Many Hands tents, gauntlet racks, a sermon platform you could hit before dawn."),
                .body("Hold the pier and more fishers reach open water. Push west and you buy Sylva a week at the cost of every soul in that bend."),
                .hint("CONTINUE to the briefing.")
            ])
        }
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Officer: \"Restoration wants headlines. Thekia wants survivors. You are the scout who saw both sides — pick which truth we march on.\""),
                .hint("CONTINUE to the briefing.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK · TALK.")])
        }
        return AnthologyTurnResult([], .move(.goodFourBriefing))
    }
}

struct GoodFourBriefingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourBriefing
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFourBriefingResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Mobilization Briefing"),
            .speech("Thekia: \"HOLD — save civilians, bleed them slowly. PUSH — strike before Many Hands swells the valley.\""),
            .body("Officers wait on your word. Oceandale's church bell is silent. The pier is not."),
            .hint("HOLD the pier line · PUSH the western camp.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodFourBriefingResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodFourEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("HOLD") || input.contains("DEFEND") || input.contains("EVACUATE") {
            state.goodFourBriefingResolved = true
            state.goodFourHoldLine = true
            return AnthologyTurnResult([
                .body("You argue for time — nets before glory. The officer grumbles but reroutes barges."),
                .body("Horns sound the fisher's alarm — three long. Families sprint from the pier again, as if the first landing never ended."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("PUSH") || input.contains("STRIKE") || input.contains("ATTACK") {
            state.goodFourBriefingResolved = true
            state.goodFourHoldLine = false
            return AnthologyTurnResult([
                .body("You mark the Agroman camp for dawn assault. Thekia's face hardens — she wanted survivors first."),
                .body("Paladin pairs will wake to steel, not sermon. You chose the fist Restoration wanted."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("HOLD · PUSH")])
    }
}

struct GoodFourEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodFourEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodFourComplete {
            return [.body("Restoration Mobilization — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.goodFourHoldLine
            ? "Smoke rises from evacuation barges, not victory pyres. Loyalty measured in lives landed — not headlines."
            : "Horns at dawn. You chose the fist Restoration wanted. The shore will learn if it was mercy or appetite."
        return [.title("Shore Wind"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodFourComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodFour, state: &state)
        return AnthologyTurnResult([
            .title("Restoration Mobilization — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodFour).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
