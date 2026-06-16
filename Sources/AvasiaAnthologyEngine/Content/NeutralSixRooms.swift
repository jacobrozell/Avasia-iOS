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
            lines.append(.body("You stayed when others left. They trust you to finish what brokers begin."))
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
            .speech("Suformin: \"PUBLISH the ledger for all to read. Or SEAL it — memory for neutrals only.\""),
            .hint("PUBLISH the open ledger · SEAL it hidden.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralSixLedgerResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralSixEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
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

struct NeutralSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralSixComplete {
            return [.body("The Open Ledger — complete.")]
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
            .body("+\(AnthologyCatalog.meta(for: .neutralSix).fpReward) faction points.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
