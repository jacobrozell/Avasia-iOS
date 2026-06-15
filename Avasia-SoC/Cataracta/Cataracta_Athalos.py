from Room.Room import Room
from Logic.util import talk
from Logic import config


def Cataracta_Athalos_Logic():
    Cataracta_Athalos.print_name()
    print("You approach Althalos' shop.")
    print(
        "\nThe sight of the " + """ "Althalos' Wares" """ + "sign sparks memories of the eccentric shopkeeper.\n")
    print("\nYou enter and immediately notice the shop is completely absent of people, yet overstocked in goods.")
    print("\nDespite the lack of business, Althalos greets you kindly.\n")
    talk("Ah, " + config.player.get_name() + ", I hear you're joining the Cataractan Legion!")
    talk("It's mighty brave of you to volunteer!")
    talk("Most would wait to be drafted, but not you!", "\n")
    talk("Listen. I wish I had something to give you, but business hasn't been so good lately.")
    talk("If you're ever looking to buy anything, I'll be here as always!", "\n")
    talk("Take care and good luck!")
    print("\nYou thank Althalos and leave.\n")
    return "go back"


Cataracta_Athalos = Room(name="Althalos' House", des="", id="Cataracta_Athalos", directions="", on_enter=Cataracta_Athalos_Logic)
