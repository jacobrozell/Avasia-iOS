from Room.Room import Room

Cataracta_Shopping = Room(name="Shopping District",
                          des="The shopping district has a few small locations."
                          "\nTo the NORTH is a pier accompanied by a small shop owned by Doran, the resident fisherman."
                          "\nTo the SOUTH is a general store owned by Athalos, a stout and peculiar shopkeeper."
                          "\nTo the EAST is a blacksmith run by Ulric."
                          "\nTo the WEST is the Housing district.",
                          id="Cataracta_Shopping",
                          directions={"N": "Cataracta_Pier", "S": "Cataracta_Athalos", "E": "Cataracta_Blacksmith", "W": "Cataracta_Housing"})