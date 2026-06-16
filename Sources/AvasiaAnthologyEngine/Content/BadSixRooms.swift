import Foundation
import AvasiaEngine

// MARK: - Bad #6 — Western Throne

struct BadSixOccupiedHallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixOccupiedHall
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Occupied Hall"),
            .body("Cataracta's breached gates stand open. Agroman banners hang where druid sigils once grew."),
            .speech("Vashirr: \"Many Hands took the city. Now the west asks who keeps it.\""),
        ]
        if state.badFourMeasuredAssault {
            lines.append(.body("Paladins cite your measured breach — the hall was taken, not slaughtered. That matters to officers now."))
        }
        lines.append(.hint("CONTINUE into the occupied streets."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("HALL") || input.contains("BANNER") {
            return AnthologyTurnResult([
                .body("Druid moss scraped from stone. Agroman iron bolted where sigils grew. The fountain still throws copper — no one catches it."),
                .body("Kimious will one day die in this courtyard. You helped write the map that opened the gate."),
                .hint("CONTINUE into the occupied streets.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the hall.")])
        }
        return AnthologyTurnResult([], .move(.badSixOccupiedStreet))
    }
}

struct BadSixOccupiedStreetRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixOccupiedStreet
    private let advance = ["CONTINUE", "GO", "MARCH"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Occupied Streets"),
            .body("Shopkeepers watch Paladins pass. Some bow. Some stare at boots and remember druid market days."),
            .body("A junior officer whispers that western command wants a face — not Vashirr's sermon, a governor's desk."),
        ]
        if state.badFiveAcceptedCommand {
            lines.append(.body("They salute you by name. The field seal on your kit is no longer ceremonial."))
        } else {
            lines.append(.body("You walk without seal — eyes, not orders. Officers still part for the scout Vashirr trusts."))
        }
        lines.append(.hint("CONTINUE to the officers' circle · LOOK at the shopkeepers · TALK to an officer."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("SHOP") || input.contains("COURTYARD") {
            return AnthologyTurnResult([
                .body("Fox recruits practice silent movement under Paladin guard — wolf-names borrowed, bear-oaths not yet sworn."),
                .body("The city remembers druid market days. Occupation is fresh enough to taste like theft."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("TALK") || input.contains("OFFICER") {
            return AnthologyTurnResult([
                .speech("Officer: Vashirr wants a governor before Restoration counterattacks. Not a sermon — a face the city can fear."),
                .speech("You: And if the face refuses the crown?"),
                .speech("Officer: Then the west keeps a knife instead. Vashirr accepts both."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK · TALK.")])
        }
        return AnthologyTurnResult([], .move(.badSixOfficersCircle))
    }
}

struct BadSixOfficersCircleRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixOfficersCircle
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Officers' Circle"),
            .body("Paladins debate occupation law — requisition, curfew, who speaks for Cataracta when the druids are gone."),
            .speech("Vashirr: \"They want a throne warm before Restoration counterattacks. You know these streets. Rule them — or stay fist, never crown.\""),
        ]
        if state.badFiveAcceptedCommand {
            lines.append(.speech("Officer: \"You already held western command. The hall is the same duty — larger chair.\""))
        }
        lines.append(.hint("CONTINUE to the western seat."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badSixThroneRoom))
    }
}

struct BadSixThroneRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixThroneRoom
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badSixThroneResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Western Seat"),
            .body("A druid high seat stripped of moss — Agroman steel bolted to stone. The city watches who sits."),
            .body("Mira's ghost is not here. You chose FOLLOW — or walked another road. The throne does not ask."),
            .hint("RULE the occupied hall · YIELD the seat · LOOK at the seat.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badSixThroneResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badSixAftermath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LOOK") || input.contains("SEAT") || input.contains("THRONE") {
            return AnthologyTurnResult([
                .body("Carved for earth-anchor ritual — now a desk for curfew orders and grain tallies."),
                .body("RULE and Cataracta learns your name in fear. YIELD and Vashirr keeps the weight you refused."),
                .hint("RULE · YIELD.")
            ])
        }
        if input.contains("RULE") || input.contains("CROWN") || input.contains("KEEP") {
            state.badSixThroneResolved = true
            state.badSixAcceptedRule = true
            return AnthologyTurnResult([
                .body("You take the western seat. Paladins kneel — not to you alone, but to the order you represent."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("YIELD") || input.contains("REFUSE") || input.contains("SHADOW") {
            state.badSixThroneResolved = true
            state.badSixAcceptedRule = false
            return AnthologyTurnResult([
                .speech("Vashirr: \"Good. Crowns rust. Eyes do not.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("RULE · YIELD")])
    }
}

struct BadSixAftermathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixAftermath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badSixAcceptedRule {
            return [
                .title("Hall Aftermath"),
                .body("Orders flow from your desk — curfew bells, grain tallies, Paladin patrol routes."),
                .speech("Vashirr: \"Govern without my shadow when you can. Call me when the west burns again.\""),
                .hint("CONTINUE to occupied dawn.")
            ]
        }
        return [
            .title("Hall Aftermath"),
            .body("You stand beside the throne, not in it. Officers accept Vashirr's word — and your reports from the street."),
            .speech("Vashirr: \"The city needs a crown and a knife. You chose the knife. Wise — for now.\""),
            .hint("CONTINUE to occupied dawn.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.badSixEpilogue))
    }
}

struct BadSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badSixComplete {
            return [.body("Western Throne — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badSixAcceptedRule
            ? "Cataracta's hall answers to your voice. Agroman loyalty became governance — for better or for fire."
            : "You refuse the seat. Vashirr keeps the crown's weight — you keep the westward road."
        return [.title("Occupied Dawn"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badSixComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.badSix, state: &state)
        var lines: [StyledLine] = [
            .title("Western Throne — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badSix).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
