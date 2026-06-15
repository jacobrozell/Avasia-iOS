from Room.Room import Room
from Logic import config
from Logic.util import talk, containsAny
import Logic.Save as save


def Cataracta_Courtyard_Logic():
    save.saveParameters()
    Cataracta_Courtyard.print_name()
    print("You enter the courtyard and see dozens of druids training.")
    print("Suddenly, another Druid appears next to you and speaks.\n")

    talk("Nice of you to join us! My name is Dentros.", "\n")

    print("You introduce yourself and tell Dentros that you're here to join the legion.\n")

    talk("Well, let's not waste anytime then!.")
    talk("We have three spirit animals that are best known for their skill in combat.")
    talk("The Wolf, the Bear, and the Fox.")
    talk("Which are you?")
    while True:
        user_class = input()
        user_class.upper()

        if containsAny(user_class, "WOLF"):
            # Attack
            config.player.set_atk(10)
            config.player.set_max_atk(10)

            # Speed
            config.player.set_speed(10)
            config.player.set_max_speed(10)

            # Luck
            config.player.set_luck(5)
            config.player.set_max_luck(5)

            # Hp
            config.player.set_hp(20)
            config.player.set_max_hp(20)

            config.player.set_class("hunter")
            break

        elif containsAny(user_class, "FOX"):
            # Attack
            config.player.set_atk(15)
            config.player.set_max_atk(15)

            # Speed
            config.player.set_speed(15)
            config.player.set_max_speed(15)

            # Luck
            config.player.set_luck(5)
            config.player.set_max_luck(5)

            # Hp
            config.player.set_hp(15)
            config.player.set_max_hp(15)

            config.player.set_class("scout")
            break

        elif containsAny(user_class, "BEAR"):
            # Attack
            config.player.set_atk(10)
            config.player.set_max_atk(10)

            # Speed
            config.player.set_speed(1)
            config.player.set_max_speed(1)

            # Luck
            config.player.set_luck(5)
            config.player.set_max_luck(5)

            # Hp
            config.player.set_hp(25)
            config.player.set_max_hp(25)

            config.player.set_class("guardian")
            break

        else:
            talk("Wolf, Bear, or Fox?", "\n")

    while True:
        if config.player.get_class() == config.player.hunterId:
            print()
            talk("Ah, I could tell your spirit animal was the wolf when I saw you.")
            talk("The wolves are very formidable in battle.")
            talk("They hit hard and can take hits well too.")
            print()
            break

        if config.player.get_class() == config.player.guardianId:
            print()
            talk("Yes, the Bear. Bears are our front-line defense.")
            talk("They can take quite a beating before they're defeated.")
            print()
            break
        if config.player.get_class() == config.player.scoutId:
            print()
            talk("Hm, yes a fox. My spirit animal is the fox as well.")
            talk("We are well known for our ability to move quickly and silently.")
            talk("Foxes make up most of our scouting force.")
            print()
            break

    cataracta_battle()
    config.current_room_id = "c_portal_room"
    return "reload"


def cataracta_battle():
    print("You head further into the courtyard to see the king of Cataracta, Kimious, walk out of the Cataractan keep.")
    print("He speaks out to the druids in the courtyard as you make your way to the front to get a good view.\n")

    talk("My friends! The time to fight is drawing near!")
    talk("Our people are under constant threat of an Agromanian invasion.")
    talk("The attack on Oceandale was far too close to Cataracta.")
    talk("We can no longer rely on our hidden passages and the mountainess terrain to defend us.")
    talk("We must take the fight to them!", "\n")

    print("The crowd roars in agreement.\n")

    talk("Your undying loyalty to our home speaks volumes an-", "\n")

    print("Kimious is interrupted by a blinding flash of light, followed by a cascade of darkness.")
    print("The sky turns blood red as a dark portal forms at the entrance of the keep.")
    print("A man donned in a dark hooded robe, holding a gray wooden staff walks out of the portal.")
    print("From behind the man floods dozens of what brutish warriors.\n")

    print("Dentros shouts out to you.\n")

    talk("Agromanians! They've found us! But how?!", "\n")

    print("Guards rush to protect Kimious, but they're quickly outmatched by the Agromanians sheer numbers")
    print("The hooded man points his staff to Kimious and blasts him with a bolt of dark energy.")
    print("Kimious falls to the floor, lifeless.\n")

    print("The Druids in the courtyard shout in horror and charge in to fight the oncoming Agromanians")
    print("The hooded man points his staff toward you and unleashes another bolt of energy.")
    print("Before you can react, Dentros shoves you out of the line of fire and takes the hit.")
    print("As you stumble over, an Agromanian confronts you.")

    # Always set stats for enemy before combat!!!
    config.enemy.set_stats(name="Agromanian Grunt",
                           atk=5,
                           hp=15,
                           speed=5)
    config.enemy.set_text("The " + config.enemy.get_name() + " lays his mace into the side of your head.")
    config.combat.start_combat()

    print("\nYou quickly dispatch the Agromanian and reassess the area around you.")
    print("Destros is lying on the floor and an Agromanian is charging toward him.")
    print("You swiftly position yourself in-between Destros and the Agromanian.\n")

    # NEED SOME STORY EXCUSE TO HEAL HERE OR THIS IS ALMOST IMPOSSIBLE
    config.player.restore_health_to_max()

    config.enemy.set_stats(name="Agromanian Warrior",
                           atk=6,
                           hp=18,
                           speed=3)
    config.enemy.set_text("The " + config.enemy.get_name() + "'s sword pierces your chest.")
    config.combat.start_combat()

    print("Another Agromanian falls to their death.")
    print("You turn to help Destros, but it seems your efforts were in vain.")
    print("By the time you managed to get to his side, he had already passed.\n")

    print("Filled with rage, you turn to find another target,")
    print("but you quickly realize that all of the fighting has come to a stand still.\n")

    print("Countless Cataractan lie dead on the ground in pools of their own blood.")
    print("Any survivors are being held hostage by Agromanians around you.\n")

    print("It is in everyone's best interest if you stand still.\n")

    print("From out of the crowd of Agromanians surrounding you, the hooded man comes.")
    print("He walks forward and is only a few feet in-front of you.")
    print("He removes his hood.")
    print("The man has a scar running across his left eye that continues to his chin.")
    print("He speaks to you in a deep, raspy voice.\n")

    talk("Listen to me, and listen carefully.")
    print("He places the tip of his staff to your head.")
    print("You can hear and feel the energy resonating from it.\n")

    talk("I have a message for you to deliver.")
    talk("Tell King Kaefden IV of the horrors his ignorance has brought.")
    talk("Tell him that Cataracta and its king have fallen.")
    talk("Tell him that so long as he holds his unearned claim on this land...", "\n")

    talk("I will not stop.", "\n")

    print("Vashirr turns and with a snap, the Agromanians execute every Druid in their captivity.")
    print("You can only watch in horror as countless people are mercilessly massacred.")
    print("Vashirr returns through the dark portal and before you can do anything to stop the onslaught,")
    print("An Agromanian bashes your head in with his axe, knocking you out cold.")

    print("------------------------------------------------------------------------------------------------\n\n\n")

    print("Time passes and you awaken alone in the same place you were before.")
    print("You stumble up off the ground and immediately smell burning fires. ")
    print("You look to the Cataractan castle. Now in flames and rubble.")
    print("The entire city is in ashes.\n")


Cataracta_Courtyard = Room(name="Courtyard", des="", id="Cataracta_Courtyard", directions="", on_enter=Cataracta_Courtyard_Logic)
