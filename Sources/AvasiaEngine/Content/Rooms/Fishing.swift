import Foundation

/// The fishing minigame, consolidated from the original's two duplicate
/// implementations (`fishing`/`fishingbeach`). Outcome text is verbatim. One
/// `randint(2,12)` roll per cast.
enum Fishing {
    static func cast(_ state: inout GameState) -> TurnResult {
        var gen = SystemRandomNumberGenerator()
        return cast(&state, using: &gen)
    }

    static func cast<G: RandomNumberGenerator>(_ state: inout GameState, using gen: inout G) -> TurnResult {
        let roll = Int.random(in: 2...12, using: &gen)
        let open: [StyledLine] = [.body("You cast a line into the ocean.")]
        switch roll {
        case 2:
            return TurnResult(open + [
                .body("Moments after casting a line, you feel a pull on the fishing rod!"),
                .item("You pull back the line and discover a huge fish made of pure gold hanging on the hook!"),
                .body("It must be worth a fortune!")
            ], events: [.caughtGoldFish])
        case 3:
            var lines = open + [
                .body("Minutes pass and you finally feel a tug on the line!"),
                .body("You fight with the line until eventually you manage to reel it in."),
                .body("Out of the water appears a large crab like monster!")
            ]
            if state.has(.sword) {
                lines += [
                    .body("Fortunately, you draw your sword and slay the beast before it can attack."),
                    .body("Looks like you'll be eating crab for dinner!")
                ]
                return TurnResult(lines, events: [.survivedFishingCrab])
            }
            if state.has(.fireball) {
                lines += [
                    .body("Just before the beast attacks, you blast it with Inflame."),
                    .body("The smell of cooked crab fills the air."),
                    .body("Delicious.")
                ]
                return TurnResult(lines, events: [.survivedFishingCrab])
            }
            lines += [
                .body("The beast lunges forward and snaps at you!"),
                .body("Its mighty claws clutch tightly around your waist!"),
                .body("You're snapped completely in half and the crab-monster drags your body into the ocean.")
            ]
            return TurnResult(lines, .death(.crab))
        case 4...6:
            return TurnResult(open + [.body("After minutes of silence you reel in your line.")])
        case 7...9:
            return TurnResult(open + [
                .body("Minutes after casting your line into the ocean you feel the weight of the fishing rod become slightly heavier."),
                .body("You assume that you've got a bite so you reel in the line only to discover an old shoe."),
                .body("How disappointing.")
            ], events: [.caughtOldShoe])
        case 10...11:
            return TurnResult(open + [
                .body("A few minutes pass and you feel a bite on the line!"),
                .body("You fight with the fishing rod and eventually reel in a large fish!"),
                .body("Looks like you've caught dinner!")
            ])
        default: // 12
            if state.orangeFishThrown >= 4 {
                return TurnResult(open + [
                    .body("You wait just a few moments before your fishing line is taken right out of your hands!"),
                    .body("The water begins to ripple and you watch as an enormous blue sea-serpent plunges out of the water!"),
                    .body("You have no time at to react before it dives down and gobbles you up.")
                ], .death(.seaSerpent))
            }
            state.orangeFishThrown += 1
            return TurnResult(open + [
                .body("After a few minutes of waiting, you feel a tug on the line!"),
                .body("You reel in the fishing rod and find a floppy orange colored fish."),
                .body("It looks absolutely useless, just splashing about."),
                .body("You toss it back into the ocean.")
            ], events: [.tossedOrangeFish])
        }
    }
}
