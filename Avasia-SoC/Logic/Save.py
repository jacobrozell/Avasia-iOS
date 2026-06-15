import pickle
import os
from Logic import util, config


def is_non_zero_file(fpath):
    return os.path.isfile(fpath) and os.path.getsize(fpath) > 0

all_stats = {}
saveGameFound = False


def saveParameters():
    global all_stats
    global saveGameFound
    all_stats = config.player.get_all_stats()
    print(str(all_stats))

    pickle_out = open("savefile.pickle", "wb")
    pickle.dump(all_stats, pickle_out)
    pickle_out.close()
    saveGameFound = True


def loadParameters():
    global saveGameFound
    global all_stats

    pickle_in = open("savefile.pickle", "rb")
    all_stats = pickle.load(pickle_in)

    # Set all of these parameters in config.
    config.player.set_name(all_stats["name"])

    config.player.add_gold(all_stats["gold"])

    config.player.set_atk(all_stats["atk"])
    config.player.set_max_atk(all_stats["maxAtk"])

    config.player.set_speed(all_stats["speed"])
    config.player.set_max_speed(all_stats["maxSpeed"])

    config.player.set_luck(all_stats["luck"])
    config.player.set_max_luck(all_stats["maxLuck"])

    config.player.set_hp(all_stats["hp"])
    config.player.set_max_hp(all_stats["maxHp"])

    config.player.set_exp(all_stats["exp"])

    config.player.set_level(all_stats["level"])

    config.player.set_class(all_stats["class"])

    config.player.printInventory = all_stats["printInventory"]
    # config.player.inventory = all_stats["inventory"]

    config.player.trophies = all_stats["trophies"]
    config.player.trophyCount = all_stats["trophyCount"]

    # ---------------Config Variables---------------

    config.current_room_id = all_stats["currentRoom"]
    config.fountain = all_stats["fountain"]
    config.ulric = all_stats["ulric"]
    config.doran = all_stats["doran"]
    config.varrustysword = all_stats["rustySword"]
    config.varbrokenaxe = all_stats["brokenAxe"]
    config.courtyard = all_stats["courtyard"]
    config.returnfish = all_stats["returnFish"]
    config.portalRoom = all_stats["portalRoom"]
    return True


def viewSave():
    global saveGameFound
    global all_stats

    pickle_in = open("savefile.pickle", "rb")
    all_stats = pickle.load(pickle_in)

    print("\nFound a save file...")
    print("Name: " + str(all_stats["name"]))
    print("Level: " + str(all_stats["level"]))
    print("Trophies: " + str(all_stats["trophyCount"]))

    ans = input("\nDo you want to load this save?")

    while True:
        if util.containsAny(ans.upper(), ["YES", "Y"]):
            return True
        else:
            return False
