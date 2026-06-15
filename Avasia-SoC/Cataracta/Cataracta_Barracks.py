from Room.Room import Room


def Cataracta_Barracks():
    print("The guard barracks made of mostly stone brick.")
    print("Outside, the entrance is being guarded by two Cataractan Legionnaire")
    print("It's safe to assume you won't be able to enter.")
    print("You head back to where you were.")
    print()
    return "go back"


Cataracta_Barracks = Room(name="", des="", id="Cataracta_Barracks", directions="", on_enter=Cataracta_Barracks)
