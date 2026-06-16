import Foundation
import AvasiaEngine

/// From `Avasia-SoC/Nacastrum/Portal_Room.py`.
struct SoCPortalRoom: SoCRoomScript {
    let id: SoCRoomID = .portalRoom
    var parseMode: Parser.Mode { .raw }

    func autoReturnAfterEnter(_ state: SoCGameState) -> SoCRoomID? {
        state.portalRoom ? .westHallway : nil
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.portalRoom {
            return [
                .title("Cataractan Portal Room"),
                .body("The portal ring still hums — red storm-light, blue Sylvian gift."),
                .body("You have what you came for. The door east to the hallway stands open."),
                .hint("Return EAST to the castle halls.")
            ]
        }
        return [
            .title("Cataractan Portal Room"),
            .body("Ash clings to your boots. The portal ahead still burns red and blue."),
            .body("This is how Vashirr reached Kimious — and how you will reach Kaefden."),
            .blank,
            .body("The ring throws light across dust and forgotten mage books."),
            .body("No guards. No king. Only the wound in the wall and the message you carry."),
            .blank,
            .speech("Serve my people. Warn the coalition."),
            .blank,
            .body("East, a cast-iron door leads deeper into Nacastrum."),
            .hint("SEARCH the room, or try EAST.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.portalRoom {
            if input.contains("EAST") {
                return SoCTurnResult([], .move(.westHallway))
            }
            return SoCTurnResult([.hint("EAST to the hallway.")])
        }

        if input.contains("SEARCH") || input.contains("EXPLORE") || input.contains("LOOK") || input.contains("FIND") {
            state.ventFound = true
            return SoCTurnResult([
                .body("Mage books stack along the west wall, spines cracked from neglect."),
                .body("A ceiling vent on the north wall — too high for a fox, maybe not for a bear."),
                .body("The portal ring binds red sky-anchor and blue earth-gift — Malkos's geography, Sylvian dust."),
                .body("Vashirr would call it too many hands. Kaefden will call it chain what you can.")
            ])
        }

        if input.contains("EAST") {
            return SoCTurnResult([
                .body("You shoulder the iron door. It does not give."),
                .body("Cast iron, mage-sealed — the honest way is barred."),
                .blank,
                .body("There must be another route into the keep.")
            ])
        }

        if input.contains("VENT") {
            guard state.ventFound else {
                return SoCTurnResult([.hint("SEARCH the room first.")])
            }
            if state.playerClass == .scout || state.playerClass == .hunter {
                return SoCTurnResult([.body("The vent sits above your reach — stack something under it first.")])
            }
            return enterLibrary(viaBooks: false, state: &state)
        }

        if input.contains("BOOK") || input.contains("MOVE") || input.contains("MAGE") || input.contains("STACK") {
            return enterLibrary(viaBooks: true, state: &state)
        }

        if input.contains("TAKE") {
            if state.ventFound {
                return SoCTurnResult([.body("These books belong to Nacastrum's mages — leave them.")])
            }
            return SoCTurnResult([.hint("SEARCH the room first.")])
        }

        return SoCTurnResult([.hint("SEARCH the room, STACK books, or try EAST.")])
    }

    private func enterLibrary(viaBooks: Bool, state: inout SoCGameState) -> SoCTurnResult {
        let lines: [StyledLine]
        if viaBooks {
            lines = [
                .body("You stack tomes beneath the vent and climb."),
                .blank,
                .body("Ductwork rattles until daylight leaks ahead."),
                .body("Below: shelves overflowing with books in every color — a library."),
                .body("You lift the grate and drop into the stacks.")
            ]
        } else {
            lines = [
                .body("You haul yourself into the vent — bear strength, borrowed breath."),
                .body("Ductwork rattles until daylight leaks ahead."),
                .body("Below: shelves overflowing with books in every color — a library."),
                .body("You lift the grate and drop into the stacks.")
            ]
        }
        state.portalRoom = true
        return SoCTurnResult(lines, .move(.library))
    }
}
