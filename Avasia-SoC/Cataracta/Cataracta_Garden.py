from Room.Room import Room
from random import randint
from Logic.util import containsAny, talk
from Logic import config


def Cataracta_Garden_Logic():
    Cataracta_Garden.print_name()
    print("Around the garden are young druid children playing while their parents socialize."
          "\nIn front of you is a fountain made of the blue crystal, Anula."
          "\nThe fountain is filled with gold pieces, scattered around the base, "
          "most of which are on tails."
          "\n")
    while True:
        ans = input("What would you like to do?")
        print()
        coin = ["COIN", "THROW"]
        lookAround = ["LOOK", "SEARCH"]
        tal = ["TALK", "APPROACH", "SPEAK", "PEOPLE"]
        leave = ["LEAVE", "BACK", "RETURN", "WEST"]
        if containsAny(ans, coin) and config.fountain is False:
            roll = randint(0, 1)
            config.player.subtract_gold(1)
            if roll == 0:
                print("\nYou toss a gold piece into the water and it lands on tails.")
                print("Nothing happens.\n")
                config.fountain = True
            if roll == 1:
                print("\nYou toss a gold piece into the water and it lands on heads!")
                print("Nothing happens.\n")
                print("I guess some things just aren't worth doing.\n")
                config.fountain = True
        elif containsAny(ans, coin):
            print("\nYou already tossed a coin in the water.\n")
        elif containsAny(ans, lookAround):
            print("You decide to take a look around.")
            print("People are sitting around the fountain doing different activities.")
            print("You see a young couple holding hands and another older gentleman, reading a book.")
            print("You also see a young child by the crystal fountain, guiding his hands through the cool water.\n")
        elif containsAny(ans, tal):
            print("\nYou approach the young boy by the crystal fountain.\n")
            talk("My parents say that if you toss some gold in the fountain, it brings good luck!")
            talk("I don't know if I believe in stuff like that though...")
            print("The young boy walks off.\n")
        elif containsAny(ans, leave):
            return "go back"


Cataracta_Garden = Room(name="Castle Garden", des="", id="Cataracta_Garden", directions="", on_enter=Cataracta_Garden_Logic)


