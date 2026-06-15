# --------- Things to do ---------
# Add more story -JR
# Make next city - JR
# Destroy all paths to cataracta - JR
#
# Change Combat to be outside of Cataracta and leave cataracta NOT destroyed?
#
# --------------------------------

# Rooms - imports all rooms
import Logic.Room_Storage as room

# Util
import Logic.util as util
import Logic.config as config

# Save
import Logic.Save as save
# ----------------------------------------------------------------


# READ COMMENTS FOR EXPLANATION OF WHAT IS GOING ON


# Dictionary that holds every room object
# Its in Key, Value pairs.
# The unique id of the room points to the room itself
# So instead of making importing the specific room every time we want to change, we can just point to its id
all_rooms_id = {}


# This is where the id get's set to the room itself.
def register_area(room):
    all_rooms_id[room.id] = room


# Where the magic truly happens:
def mainloop():
    inventory = ["INVENTORY"]
    all_commands = ["INVENTORY", "EAT", "DRINK", "SAVE", "QUIT", "TROPHY"]
    eat = ["EAT", "DRINK"]
    help = ["HELP", "COMMANDS"]
    quitCommand = ["QUIT", "EXIT"]
    saveCommand = ["SAVE"]
    loadCommand = ["LOAD"]
    trophyCommand = ["TROPHY", "TROPHIES", "ACHIEVEMENTS", "ACHIEVEMENT"]
    current_room = None

    while True:

        # Keep track of the old room if and only if there was an old room
        old_room_id = None if current_room is None else current_room.id

        # Current room = look for the id of the current room and return the room itself
        current_room = all_rooms_id[config.current_room_id]

        # does the room return anything?
        # Such as "reload" or "go back"
        event_result = current_room.event()

        # Reload skips over the "Which way would you like to investigate?" and reloads the room.
        # If you don't reload between room changes (in certain cases)
        # then the room A to room B will have the "which way would you..." in between switches

        # ^^^^ You'll know this bug when you see it.
        if event_result == "reload":
            continue

        # return "go back" in a room to return to the old_room_id.
        # This is useful for rooms that have no directions in them. (Don't go anywhere)
        elif event_result == "go back":
            config.current_room_id = old_room_id
            continue

        print()
        command = input("Which way would you like to investigate?")
        command = command.upper()

        # Show list of all commands
        if util.containsAny(command, help):
            print(str(all_commands).replace("'", ""))
            print("Enter these anywhere!")
            print()

        # Print the players inventory
        elif util.containsAny(command, inventory):
            print()
            config.player.print_player_inventory()
            print()
            continue

        # Eat food / drink potion:
        elif util.containsAny(command, eat):

            if config.player.get_hp() < config.player.get_max_hp():

                print("What item do you want to use?")
                print()

                # Get input for which item_id the user wants to eat/drink
                config.player.print_player_inventory()
                itemToBeEaten = input()

                # Search for item_id and RETURN THE ITEM ITSELF and set it to item_object
                item_object = config.player.return_item(itemToBeEaten)

                # If the Item wasn't actually found:
                if item_object is False:
                    print("Item not found!")
                    print()
                    continue

                # We found the object but let's check and make sure the user isn't trying to eat gold or some shit
                if item_object.typeID == "food":
                    config.player.eat_food(item_object.getAmt())
                    print("Health restored by " + str(item_object.getAmt()) + "!")
                    config.player.display_stats()
                    print()

            # Health is full
            else:
                print()
                print("Health is full!")
                print()

        elif util.containsAny(command, quitCommand):
            # Save file
            save.saveParameters()

            print("\nYour game has been saved!\n"
                  "Thank you for playing!\n\n"
                  "-------------------------------------------------------------------------")
            quit()

        elif util.containsAny(command, saveCommand):
            save.saveParameters()
            print("\nYour game has been saved!\n")

        elif util.containsAny(command, loadCommand):
            save.loadParameters()

        elif util.containsAny(command, trophyCommand):
            config.player.print_obtained_trophies()

        else:

            # If the command isn't any of those... Then it must be a direction
            # The direction function is found in Room Class
            current_room.direction(command)
            print()


# To make a new room:
# 1. you need to register it here,
# 2. add the import to Room_Storage
# 3. make the room,
# 4. and make sure you set the path in the directions in the room that leads to it.


# Cataracta
register_area(room.Cataracta_Athalos)
register_area(room.Cataracta_Blacksmith)
register_area(room.Cataracta_Courtyard)
register_area(room.Cataracta_Fishing)
register_area(room.Cataracta_Garden)
register_area(room.Cataracta_Housing)
register_area(room.Cataracta_Hunter_Path)
register_area(room.Cataracta_North)
register_area(room.Cataracta_Pier)
register_area(room.Cataracta_Shopping)
register_area(room.Cataracta_Barracks)


# Nacastrum Castle
register_area(room.c_portal_room)
register_area(room.west_hallway)
register_area(room.n_library)
register_area(room.throne_room)
# -------------------------------------------------------------------------------


# Call the intro()
# Start the mainloop()
util.intro()
while True:
    mainloop()
