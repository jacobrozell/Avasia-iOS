import Foundation

/// The fishing minigame, consolidated from the original's two duplicate
/// implementations (ENGINE_SPEC §A.5). One `randint(2,12)` roll per cast.
enum Fishing {
    static func cast(_ state: inout GameState) -> TurnResult {
        var gen = SystemRandomNumberGenerator()
        return cast(&state, using: &gen)
    }

    static func cast<G: RandomNumberGenerator>(_ state: inout GameState, using gen: inout G) -> TurnResult {
        let roll = Int.random(in: 2...12, using: &gen)
        switch roll {
        case 2:
            return TurnResult([.item("A golden fish! It glimmers as you pull it ashore. Lucky you.")])
        case 3:
            if state.has(.fireball) {
                return TurnResult([.body("A snapping crab lunges — you scorch it with Inflame. Calamari.")])
            }
            if state.has(.sword) {
                return TurnResult([.body("A snapping crab lunges — you cleave it with your sword. Calamari.")])
            }
            return TurnResult([.body("A monstrous crab erupts from the surf, seizes you, and drags you under.")],
                              .death(reason: "Pinched to pieces by a crab. Should have brought a blade."))
        case 4...6:
            return TurnResult([.body("Nothing bites. The line drifts.")])
        case 7...9:
            return TurnResult([.body("You reel in an old, waterlogged shoe. Charming.")])
        case 10...11:
            return TurnResult([.body("A decent fish. It will make a fine meal.")])
        default: // 12
            if state.orangeFishThrown >= 4 {
                return TurnResult([.body("The water churns black — a sea serpent rises and swallows you whole.")],
                                  .death(reason: "Taken by the sea serpent. The ocean keeps what it is owed."))
            }
            state.orangeFishThrown += 1
            return TurnResult([.body("A useless orange fish. You toss it back with a sigh.")])
        }
    }
}
