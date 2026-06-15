import Foundation
import AvasiaEngine

/// Placeholder for Python `on_enter` logic rooms not yet ported to Swift.
struct SoCLogicStub: SoCRoomScript {
    let id: SoCRoomID
    let title: String
    let note: String
    let returnsTo: SoCRoomID

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("[ \(title) ]"),
            .body(note),
            .hint("(Scene from the original Python prototype — Swift port in progress. Type BACK.)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if input.contains(Verb.back) || input.contains(Verb.south) || input.contains(Verb.west) {
            return SoCTurnResult([.body("You step back.")], .move(returnsTo))
        }
        return SoCTurnResult([.hint("This scene is not yet playable in the iOS build.")])
    }
}
