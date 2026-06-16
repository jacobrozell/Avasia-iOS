from Logic import config
import Logic.Item_Storage as item
import Logic.Save as save


def containsAny(string, options):
    for option in options:
        if option.upper() in string.upper():
            return True
    return False


def set_color_to(color):
    print(color, end='')


def talk(talkMessage, message=None):
    if message is None:
        print(config.talk_color, "\"" + str(talkMessage) + "\"")
    else:
        print(config.talk_color, "\"" + str(talkMessage) + "\"" + " " + str(message))

    set_color_to(config.base_color)


def intro():
    from colorama import init
    init()
    set_color_to(config.base_color)

    decision = False
    print("\nWelcome to Avasia: Blade of Courage!\n")
    load = ["LOAD"]
    while decision is False:
        ans = input("Would you like to load or start a new game?")
        if containsAny(ans, load):
            willLoadGame = save.viewSave()
            if willLoadGame:
                save.loadParameters()
                decision = True
            else:
                decision = False
        else:
            decision = True
            print("\n---------Avasia: Blade of Courage---------\n\n")
            print("It has been seven years since the fall of Oceandale and the crowning of King Kaefden IV."
                  "\nIn all that time, no Agromanian army has crossed the border — yet the Kaefdens have not rested."
                  "\nNacastrum rises again while legions train for the war everyone knows is coming."
                  "\nRecently, word reached Aylova from Silvarium: Vashirr, the traitor ex-king of Nacastrum, "
                  "stands at the Agromanian king's right hand — and teaches their warriors magic."
                  "\nThey call these new soldiers Paladins."
                  "\nKing Kaefden IV has begun recruiting in earnest before the northwest can muster."
                  "\n\nYou are a druid living in the peaceful city of Cataracta."
                  "\nCataracta has formed a pact with the people of Aylova to join the fight when the time comes."
                  "\nTh leader of Cataracta is drafting an army and you have decided to volunteer."
                  "\nThis is where your story begins..."
                  "\n\n\n")
            while True:
                name = input("What is your name?")
                if name == "":
                    print()
                else:
                    yes = ["YES", "yes", "y", "Y"]
                    print()
                    print("Your name is " + name.title() + "? (yes/no)")
                    ans = input("You can't change it once it's set.")
                    print()
                    if containsAny(ans, yes):
                        config.player.set_name(name.title())
                        break
            print(config.room_color)
            print("\n\n>>>" + config.player.get_name() + "'s House<<<")
            print(config.base_color)
            print()
            print("Today is the day you join Cataracta's Legion.")
            print("To join, you must head to the Legion's courtyard.")
            print("You collect your belongings and leave your home with a sense of pride.")
            print("\nType 'help' any time for a list of commands!\n")
            config.player.add_gold(100)
            config.player.give_item(item.potion)
            config.player.unlocked_trophy("startedAdventure")
            config.current_room_id = "Cataracta_Housing"
