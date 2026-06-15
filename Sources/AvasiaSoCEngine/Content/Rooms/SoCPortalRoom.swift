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
                .body("You unlock the door to the portal room."),
                .blank,
                .body("There is not really a reason to go back in there, but at least it's unlocked now.")
            ]
        }
        return [
            .title("Cataractan Portal Room"),
            .body("You stand in a room glimmering in red and blue light."),
            .body("You look behind you and see the source of the light."),
            .body("The Cataractan portal lies before you."),
            .body("You look away in sadness."),
            .speech("It's time to serve my people."),
            .body("You look around the room."),
            .body("It appears as this portal is rarely used, given by the condition of the room."),
            .body("You're surprised such a portal isn't guarded more carefully."),
            .blank,
            .body("To the EAST is a door that appears to lead into a hallway."),
            .hint("What do you want to do?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.portalRoom {
            return SoCTurnResult([], .move(.westHallway))
        }

        if input.contains("SEARCH") || input.contains("EXPLORE") || input.contains("LOOK") || input.contains("FIND") {
            state.ventFound = true
            return SoCTurnResult([
                .body("You search around the room and notice."),
                .body("Old mage books stack along the western wall."),
                .body("You see some sort of vent on the ceiling of the northern wall.")
            ])
        }

        if input.contains("EAST") {
            return SoCTurnResult([
                .body("You try to open the door, but it won't budge."),
                .body("The door is made of cast iron and cannot be broken."),
                .blank,
                .body("Maybe there is another way.")
            ])
        }

        if input.contains("VENT") {
            guard state.ventFound else {
                return SoCTurnResult([])
            }
            if state.playerClass == .scout || state.playerClass == .hunter {
                return SoCTurnResult([.body("It seems you are a little too short to reach the vent.")])
            }
            return enterLibrary(viaBooks: false, state: &state)
        }

        if input.contains("BOOK") || input.contains("MOVE") || input.contains("MAGE") || input.contains("STACK") {
            return enterLibrary(viaBooks: true, state: &state)
        }

        if input.contains("TAKE") {
            if state.ventFound {
                return SoCTurnResult([.body("You shouldn't take any of the books.")])
            }
            return SoCTurnResult([])
        }

        return SoCTurnResult([.hint("Invalid command")])
    }

    private func enterLibrary(viaBooks: Bool, state: inout SoCGameState) -> SoCTurnResult {
        let lines: [StyledLine]
        if viaBooks {
            lines = [
                .body("You move the books under the vent and haul yourself up."),
                .blank,
                .body("You follow the vents until you are see light up ahead."),
                .body("When you reach the light, you look below and see many shelves overflowing with books of all colors."),
                .body("It appears to be some sort of library."),
                .body("You easily lift the vent up and drop down into the library.")
            ]
        } else {
            lines = [
                .body("You barely reach the vent, but manage to haul yourself up."),
                .body("You follow the vents until you are see light up ahead."),
                .body("When you reach the light, you look below and see many shelves overflowing with books of all colors."),
                .body("It appears to be some sort of library."),
                .body("You easily lift the vent up and drop down into the library.")
            ]
        }
        state.portalRoom = true
        return SoCTurnResult(lines, .move(.library))
    }
}
