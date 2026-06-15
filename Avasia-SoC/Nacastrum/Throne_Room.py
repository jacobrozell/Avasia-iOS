from Room.Room import Room
from Logic.util import talk, containsAny
from Logic import config


def tr_logic():
    throne_room.print_name()
    print()


    # Input
    ans = input("What do you want to do?")
    ans.upper()
    south = ["SOUTH"]


throne_room = Room(des="",
                   directions="",
                   name="Nascastrum Trone Room",
                   id="throne_room",
                   on_enter=tr_logic)
