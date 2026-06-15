from Logic import config, util
import Logic.Item_Storage as Item_Storage
from random import randint
from Room.Room import Room


def Cataracta_Fishing_Logic():
    Cataracta_Fishing.print_name()
    print("You see the rippling water surrounding you.")
    print("You feel the cool breeze of you the wind over the water.")
    bait = randint(4, 7)
    oldshoe = False
    smallfish = False
    bigfish = False
    crab = False
    keepGoing = True

    while keepGoing:
        keepGoing = False
        ans = input("Throw your cast in the water?")
        print()
        ans.upper()
        y = ["YES", "Y"]
        n = ["NO", "N"]

        if util.containsAny(ans, y):
            item = randint(1, 10)
            print(config.trophy_color)

            # Old shoe
            if item == 1:
                print("You fish up an " + Item_Storage.oldshoe.name + "!")
                Item_Storage.oldshoe.print_stats()
                config.player.give_item(Item_Storage.oldshoe)
                print()
                oldshoe = True

            elif item == 1 and oldshoe:
                print("Whole lot of nothing...")
                print()

            # Small Fish
            elif item == 2:
                print("You fish up a " + Item_Storage.smallfish.name + "!")
                Item_Storage.smallfish.print_stats()
                config.player.give_item(Item_Storage.smallfish)
                print()
                smallfish = True

            elif item == 2 and smallfish:
                print("Whole lot of nothing...")

            # Money Purse
            elif item == 3 or item == 4 or item == 5:
                print("You fish up a Soggy-Money Purse!")
                amount = randint(1, 20)
                print("You add " + str(amount) + " gold to your backpack!")
                config.player.add_gold(amount)
                config.player.print_gold()
                print()

            # Big fish
            elif item == 6:
                print("You fish up a " + Item_Storage.bigfish.name + "!")
                Item_Storage.bigfish.print_stats()
                config.player.give_item(Item_Storage.bigfish)
                print()
                bigfish = True

            elif item == 6 and bigfish:
                print("Whole lot of nothing...\n")

            # Crab
            elif item == 7:
                print("You fish up a " + Item_Storage.crab.name + "!")
                Item_Storage.crab.print_stats()
                config.player.give_item(Item_Storage.crab)
                print()
                crab = True

            elif item == 7 and crab:
                print("Whole lot of nothing...")
                print()

            # Catch Nothing
            elif item == 8 or item == 9 or item == 10:
                print("You fish up a heavy amount of seaweed.")
                print("You throw it back over the pier.")
                print()

            bait -= 1
            print(config.base_color)
            # When you run out of bait
            if bait == 0:

                print("You ran out of bait!")
                print("You thank Doran and return the fishing pole.")
                print("You leave the pier.\n")
                if config.player.trophies["fished"]["value"] is False:
                    config.player.unlocked_trophy("fished")
                config.current_room_id = "Cataracta_Shopping"
                return "reload"
            else:
                print("It seems you have enough bait to last " + str(bait) + " casts.\n")
                keepGoing = True

        elif util.containsAny(ans, n):
            print("You thank Doran and return the fishing pole.")
            print("You leave the pier.\n")
            config.current_room_id = "Cataracta_Shopping"
            return "reload"


Cataracta_Fishing = Room(name="Fishing", des="", id="Cataracta_Fishing", directions="", on_enter=Cataracta_Fishing_Logic)
