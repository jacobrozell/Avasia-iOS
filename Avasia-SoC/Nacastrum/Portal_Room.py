from Room.Room import Room
from Logic.util import talk
from Logic.util import containsAny
from Logic import config
import Logic.Save as save


def portal_logic():
    save.saveParameters()
    ventFound = False
    c_portal_room.print_name()

    if config.portalRoom:
        print("You unlock the door to the portal room.\n")
        print()
        print("There is not really a reason to go back in there, but at least it's unlocked now.")
        return "go back"

    if config.portalRoom is False:
        print("You stand in a room glimmering in red and blue light.")
        print("You look behind you and see the source of the light.")
        print("The Cataractan portal lies before you.")
        print("You look away in sadness.")
        talk("It's time to serve my people.")
        print("\nYou look around the room.")
        print("It appears as this portal is rarely used, given by the condition of the room.")
        print("You're surprised such a portal isn't guarded more carefully.")
        print()
        print("To the EAST is a door that appears to lead into a hallway.")

    while True:
        ans = input("What do you want to do?")
        print()
        ans.upper()
        searchvar = ["SEARCH", "EXPLORE", "LOOK", "FIND"]
        east = ["EAST"]
        vent = ["VENT"]
        book = ["BOOK", "MOVE", "MAGE", "STACK"]
        take = ["TAKE"]

        if containsAny(ans, searchvar):
            print("You search around the room and notice.")
            print("Old mage books stack along the western wall.")
            print("You see some sort of vent on the ceiling of the northern wall.")
            print()
            ventFound = True
            continue

        elif containsAny(ans, east):
            print("You try to open the door, but it won't budge.")
            print("The door is made of cast iron and cannot be broken.")
            print()
            print("Maybe there is another way.")
            print()
            continue

        elif containsAny(ans, vent):
            if ventFound is True:
                if config.player.get_class() == "scout" or config.player.get_class() == "hunter":
                    print("It seems you are a little too short to reach the vent.")
                    print()
                else:
                    print("You barely reach the vent, but manage to haul yourself up.")
                    print("You follow the vents until you are see light up ahead.")
                    print("When you reach the light, you look below and see many shelves "
                          "overflowing with books of all colors.")
                    print("It appears to be some sort of library.")
                    print("You easily lift the vent up and drop down into the library.")
                    print()
                    config.portalRoom = True
                    config.current_room_id = "n_library"
                    return "reload"

        elif containsAny(ans, book):
            print("You move the books under the vent and haul yourself up.")
            print()
            print("You follow the vents until you are see light up ahead.")
            print("When you reach the light, you look below and see many shelves overflowing with books of all colors.")
            print("It appears to be some sort of library.")
            print("You easily lift the vent up and drop down into the library.")
            print()
            config.portalRoom = True
            config.current_room_id = "n_library"
            return "reload"

        elif containsAny(ans, take):
            if ventFound is False:
                pass
            else:
                print("You shouldn't take any of the books.")
                print()
                continue

        else:
            print("Invalid command")
            print()
            continue


c_portal_room = Room(des="",
                     directions="",
                     name="Cataractan Portal Room",
                     id="c_portal_room",
                     on_enter=portal_logic)
