import Foundation

/// Placeholder for areas not yet ported. Lets the skeleton run end-to-end while
/// the remaining rooms (cave, forest/tree, western road, endgame) are built out
/// against WORLD_MAP.md and STORY.md. Each unimplemented `RoomID` is backed by a
/// `StubRoom` carrying its intended description (see `World.build()`).
struct StubRoom: RoomScript {
    let id: RoomID
    let title: String
    let note: String
    let returnsTo: RoomID

    init(_ id: RoomID, title: String, note: String, returnsTo: RoomID) {
        self.id = id
        self.title = title
        self.note = note
        self.returnsTo = returnsTo
    }

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .title("[ \(title) ]"),
            .body(note),
            .hint("(Not yet implemented — see docs/WORLD_MAP.md. Go BACK to continue.)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(returnsTo))
    }
}
