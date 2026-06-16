import Foundation
import AvasiaEngine

// MARK: - Neutral #6 — The Open Ledger

struct NeutralSixArchiveRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixArchive
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Splitpath Archive"),
            .body("Suformin and Cellious share a table — cave copies, gate ledgers, market truce maps."),
            .speech("Cellious: \"One open ledger. Every faction will hate it equally. That is how we know it is honest.\""),
        ]
        if state.neutralFiveStayedOnRoad {
            lines.append(.body("You stayed when others left Splitpath. They trust you to finish what brokers begin."))
        }
        lines.append(.hint("CONTINUE to the record hall · LOOK at the stacks."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("STACK") {
            return AnthologyTurnResult([
                .body("Cave rubbings beside gate counts beside market chalk — six years of neutrality, none of it official until now."),
                .body("The schism fable appears on every third page — two hands, one wrist. Restoration and Agroman both hate the phrasing."),
                .hint("CONTINUE · TALK to Suformin.")
            ])
        }
        if input.contains("TALK") || input.contains("SUFORMIN") || input.contains("CELLIOUS") {
            return AnthologyTurnResult([
                .speech("Suformin: Publish and every faction calls us traitors. Seal and we become another secret the war exploits."),
                .speech("Cellious: Neutrality without record is delay dressed as virtue. Decide before couriers arrive."),
                .hint("CONTINUE to the record hall.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK · TALK.")])
        }
        return AnthologyTurnResult([], .move(.neutralSixRecordHall))
    }
}

struct NeutralSixRecordHallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixRecordHall
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Record Hall"),
            .body("Scribes copy your cave archive notes. Cellious cross-checks gate deserter counts against market truce maps."),
            .body("Every page names someone who refused both banners — or traded with both and survived."),
        ]
        if state.neutralFourStayedWitness {
            lines.append(.speech("Cellious: \"Your signature at Kaefden gate earns you a line in the master index — whether you want it or not.\""))
        }
        lines.append(.hint("CONTINUE to the witness table."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralSixWitnessTable))
    }
}

struct NeutralSixWitnessTableRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixWitnessTable
    private let advance = ["CONTINUE", "YES", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Witness Table"),
            .speech("Suformin: \"Publish and every faction calls us traitors. Seal and we become another secret the war can exploit.\""),
            .speech("Cellious: \"Neutrality without record is just delay. Decide before the couriers arrive.\""),
        ]
        if state.neutralThreeBrokersPeace {
            lines.append(.body("Your Two Hands truce map sits on top — proof brokers can bind violence without crowns."))
        }
        lines.append(.hint("CONTINUE to the binding room."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralSixBindingRoom))
    }
}

struct NeutralSixBindingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixBindingRoom
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralSixLedgerResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Binding Room"),
            .body("Wax, cord, and neutral ink — the tools of a record that belongs to no banner."),
            .body("Suformin holds the cave copies. Cellious holds the gate ledger. You hold the market truce map — if you brokered it."),
            .hint("PUBLISH the open ledger · SEAL it hidden · LOOK at the copies.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralSixLedgerResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralSixAftermath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LOOK") || input.contains("COPY") || input.contains("READ") {
            return AnthologyTurnResult([
                .body("Every page names someone who refused both banners — or traded with both and survived."),
                .body("Publish and truth travels without a guard. Seal and custody becomes its own mercy."),
                .hint("PUBLISH · SEAL.")
            ])
        }
        if input.contains("PUBLISH") || input.contains("OPEN") || input.contains("READ") {
            state.neutralSixLedgerResolved = true
            state.neutralSixPublishedLedger = true
            return AnthologyTurnResult([
                .body("Copies go east, west, and to the floating court. War will call it treason. History may call it mercy."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("SEAL") || input.contains("HIDDEN") || input.contains("SECRET") {
            state.neutralSixLedgerResolved = true
            state.neutralSixPublishedLedger = false
            return AnthologyTurnResult([
                .speech("Suformin: \"Then guard it as we guarded the caves. Neutrality is also custody.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("PUBLISH · SEAL")])
    }
}

struct NeutralSixAftermathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixAftermath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralSixPublishedLedger {
            return [
                .title("Archive Aftermath"),
                .body("Couriers scatter with bound copies. Splitpath traders read names they thought would die in cave dust."),
                .speech("Suformin: \"We are exposed now. That is the price of honest memory.\""),
                .hint("CONTINUE to archive quiet.")
            ]
        }
        return [
            .title("Archive Aftermath"),
            .body("The ledger closes behind wax and neutral seals. Only brokers and witnesses know where it sleeps."),
            .speech("Cellious: \"When the world can bear it, we unseal. Until then — custody is also mercy.\""),
            .hint("CONTINUE to archive quiet.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralSixEpilogue))
    }
}

struct NeutralSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralSixComplete {
            return [.body("The Open Ledger — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.neutralSixPublishedLedger
            ? "The ledger travels. Neutrality, for you, meant letting truth survive without a banner to protect it."
            : "The archive closes. Neutrality, for you, meant keeping counsel until the world can bear it."
        return [.title("Archive Quiet"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.neutralSixComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.neutralSix, state: &state)
        var lines: [StyledLine] = [
            .title("The Open Ledger — complete"),
            .body("+\(AnthologyCatalog.meta(for: .neutralSix).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
