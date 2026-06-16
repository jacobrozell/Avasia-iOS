import Foundation
import AvasiaEngine

/// From `Avasia-SoC/Nacastrum/Library.py`.
struct SoCLibraryRoom: SoCRoomScript {
    let id: SoCRoomID = .library
    var parseMode: Parser.Mode { .raw }

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        state.metThekia = true
        return nil
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        openingLines() + [.hint("What do you want to do?")]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if input.contains("SOUTH") {
            return SoCTurnResult([
                .body("You run out the southern door to follow the woman.")
            ], .move(.westHallway))
        }

        if input.contains("LOOK") || input.contains("AROUND") || input.contains("SEARCH") {
            var lines: [StyledLine] = [
                .body("You look around the library, briefly."),
                .body("Growing up in Cataracta, you seldom had time for books until you were retired."),
                .body("Youths didn't have an academy, like one you would see in Nacastrum."),
                .body("You were taught to fish, hunt, and survive."),
                .body("And eventually, you found your way into the role of Hunter, Guardian, or Scout."),
                .body("Perhaps, in another life, you would have enjoyed reading."),
                .blank,
                .body("One shelf holds a cracked pamphlet — Vashirr's address when he disbanded the High Mage's Council."),
                .speech("...Magic hoarded in towers did not save Oceandale. The Many Hands doctrine: power for every soldier who bleeds for Avasia."),
                .body("Someone else's hand has underlined the last line twice."),
                .body("A margin scribble in Thekia's script: *Binding without consent leaves echo — Vashirr knew.*")
            ]
            if !state.libraryLooked {
                state.libraryLooked = true
                lines.append(contentsOf: SoCQuestProgress.grantQuestExp(15, state: &state))
            }
            return SoCTurnResult(lines)
        }

        return SoCTurnResult([.hint("That is not a valid command.")])
    }

    private func openingLines() -> [StyledLine] {
        [
            .title("Nascastrum Library"),
            .body("The library is covered from wall to wall with seemingly endless shelves of books."),
            .body("Some of the texts are as ancient, as they are endless."),
            .body("Suddenly, a woman in ornate purple robes approaches you."),
            .speech("What are you doing here, druid? How did you get here?"),
            .blank,
            .body("You don't want any confrontation with the woman, so you tell her everything."),
            .body("How you are a recruit for the once, and now, all dead Cataractan army."),
            .body("You tell her about Vashirr and how he teleported, in mass, all the Agromanians."),
            .blank,
            .body("The woman is speechless."),
            .body("She puts her hands on her head and looks down."),
            .body("Abruptly, she says:"),
            .speech("We must go and alert the king!"),
            .speech("Follow me."),
            .blank,
            .body("The woman goes out a grand door to the SOUTH of you.")
        ]
    }
}
