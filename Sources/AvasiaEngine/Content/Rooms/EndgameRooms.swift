import Foundation

// The endgame: Nacastrum, Aylova, and the canonical ending. These are largely
// narrative; the player advances with CONTINUE. See STORY §4–7.

/// Nacastrum — the ruined floating city; the father's corpse and pendant.
struct NacastrumRoom: RoomScript {
    let id: RoomID = .nacastrum

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .title("Nacastrum"),
            .body("Floating city of the Mage. Silver streets run between towers of stone, every house ransacked and still."),
            .body("In the courtyard of the King's Castle you find a body you know at once: your father."),
            .body("Around his neck hangs a silver pendant set with a blue gemstone. You take it, and you swear an oath."),
            .speech("Vashirr is a powerful mage and a formidable foe, but I know we can stop him. — the Old Mage"),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([
            .body("The Old Mage lays a hand on your shoulder."),
            .speech("I am Thekia. I once was part of the High Mage's Council, before Vashirr disbanded us and scattered our people."),
            .speech("There is one place left they would have gone. Come.")
        ], .move(.aylova))
    }
}

/// Aylova — the rally of the banished mages.
struct AylovaRoom: RoomScript {
    let id: RoomID = .aylova

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .title("Aylova"),
            .body("The capital of Kaefden — larger even than Nacastrum, and crowded with the mages Vashirr banished."),
            .body("Thekia climbs the great Ring of Malkos at the city's heart and raises her voice."),
            .speech("Vashirr did not save you. He has sided with the Agroman. And our home still stands, empty, waiting!"),
            .body("A murmur becomes a roar. Mages — and others who are not mages at all — gather at her back."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(.ending))
    }
}

/// The canonical ending.
struct EndingRoom: RoomScript {
    let id: RoomID = .ending

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The portal opens, and the people of Nacastrum stream home through it, the city filling with light and noise once more."),
            .speech("Thank you, for all you have done. None of this would have been possible without you."),
            .speech("But there is work to be done. We have just started."),
            .speech("Let us go, my king."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .win)
    }
}
