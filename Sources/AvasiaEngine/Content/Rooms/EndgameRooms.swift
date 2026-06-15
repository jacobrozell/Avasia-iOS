import Foundation

// The endgame: Nacastrum, Aylova, and the canonical ending. Text reproduced
// verbatim from GameDriver.py (typos preserved: "Tekia", "your fathers neck",
// "realise"). The player advances with CONTINUE.

/// Nacastrum — the ruined floating city; Thekia's reveal.
struct NacastrumRoom: RoomScript {
    let id: RoomID = .nacastrum

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .title("Nacastrum"),
            .body("You feel a rush of determination and resentment towards Vashirr, your 'king'."),
            .body("You and the Old Mage venture deeper into Nacastrum towards the King's Castle."),
            .body("The huge mage towers of stone cast shadows over the streets of silver that you walk."),
            .body("Many of the civilian houses are intact, but some seem to have been ransacked by the Agroman."),
            .blank,
            .speech("This isn't the Nacastrum I remember."),
            .speech("Nacastrum was a proud city where those who wished to learn about magic had a safe place to do so."),
            .body("The Old Mage stops in her tracks and looks to you."),
            .speech("I'm afraid I haven't been completely honest with you."),
            .speech("Let me start with introducing my self, once and for all."),
            .speech("I am Thekia. I once was part of the High Mage's Council."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([
            .speech("When Vashirr became King, our power and influence waned."),
            .speech("Over the years, Vashirr ignored our advice and did what he wanted for his personal benefit."),
            .speech("He eventually exposed the High Mage's Council to the public and painted us as a corrupt group of petty politicians."),
            .speech("When the public spoke up against us, Vashirr eliminated the council and banished its members."),
            .speech("Without the High Mage's Council to stop Vashirr, the people of Nacastrum were left to his mercy."),
            .speech("Vashirr is a powerful mage and a formidable foe, but I know we can stop him."),
            .speech("But first, we must return Nacastrum to its former glory. Come on, we don't have any time to waste.")
        ], .move(.aylova))
    }
}

/// Aylova — the father's pendant, then the rally of the banished mages.
struct AylovaRoom: RoomScript {
    let id: RoomID = .aylova

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You and Thekia finally arrive at the King's Castle of Nacastrum, and find it in ruins."),
            .body("Kaefden and Nacastrum banners that previously hung from the walls are ripped apart and lie on the floor."),
            .speech("This place is an absolute mess. We have a lot of work cut out for us. Luckily, I know where we can get some friends."),
            .body("Thekia heads into the courtyard and places the staff into its designated slot."),
            .body("Before she can activate the ring, you spot a body lying on the floor. Your heart sinks as you realise it is your father."),
            .body("Memories of him trying to stop the Agromanians from taking your mother return. You vow to avenge them both."),
            .body("Light shines on a pendant around your fathers neck — one made of silver with a blue gemstone in the middle."),
            .item("You take your father's pendant and place it around your neck."),
            .blank,
            .body("Thekia activates the Ring of Malkos and walks with you into the portal."),
            .body("Moments later, you are transported to a huge city. One even bigger than Nacastrum."),
            .speech("We are in the capital of Kaefden, Aylova. Many of the mages that were banished came here for safety."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([
            .body("Thekia walks past you and looks to the crowd."),
            .speech("People of Kaefden! We have come with terrible news."),
            .speech("Vashirr, the old king of Nacastrum, has joined the Agroman and wishes to destroy both of our people for his own gain."),
            .speech("Mages of Aylova! Come with me and rebuild the home that was unrightfully stolen from you!"),
            .speech("We will not rest until Vashirr and the Agroman are defeated and the people of Avasia live in peace!"),
            .speech("We cannot force you to join us, but if you wish to help, come with us through the portal."),
            .body("Thekia turns and nods to you, and walks back into the portal. You follow her back to Nacastrum.")
        ], .move(.ending))
    }
}

/// The canonical ending.
struct EndingRoom: RoomScript {
    let id: RoomID = .ending

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You wait outside the Ring of Malkos in Nacastrum. All that is left is the humming of the portal and the abandoned city."),
            .body("Moments later, a lone mage comes through the portal and runs out into the city with tears in his eyes. His memory has returned."),
            .body("Almost immediately, more mage come through the Ring of Malkos to return to their home. A sense of pride and joy fills your spirit."),
            .body("Even people who aren't mage enter the portal to join you in your efforts to stop Vashirr and the Agromanian."),
            .blank,
            .speech("Thank you, for all you have done."),
            .speech("None of this would have been possible without you."),
            .speech("But there is work to be done. We have just started."),
            .speech("Let us go, my king."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .win)
    }
}
