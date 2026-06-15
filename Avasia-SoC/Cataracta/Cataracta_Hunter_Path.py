from Room.Room import Room


def Cataracta_Hunter_Path_Logic():
    print("That's the trail hunters use to go hunt.")
    print("You should make your way to the courtyard.")
    print()
    return "go back"


Cataracta_Hunter_Path = Room(name="", des="", id="Cataracta_Hunter_Path", directions="", on_enter=Cataracta_Hunter_Path_Logic)
