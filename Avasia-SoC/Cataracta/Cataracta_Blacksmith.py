from Room.Room import Room
from Logic import config
from Logic.util import talk


def Cataracta_Blacksmith_Logic():
    if config.ulric is False:
        Cataracta_Blacksmith.print_name()
        print("You go south to Ulric's Blacksmith, a small building, with stacks of metal and materials everywhere.")
        print("You approach Ulric, who is sitting on the steps of his house.")
        print("He begins talking to you.")
        print()
        talk("So, you've decided to join the Cataractan army? More business for me I suppose, heh.")
        talk("Tell you what, go see my brother Doran at the pier.")
        talk("As you know, he rents out fishing poles.")
        talk("I bet you can find some pretty interesting stuff out there.", "\n")
        talk("What I wouldn't give to be able to fish all day.")
        talk("But, there is always work to be done.")
        talk("Now go bother my brother.", "\n")
        if config.doran is False:
            config.ulric = True
        return "go back"
    else:
        Cataracta_Blacksmith.print_name()
        talk("Go bother my brother. I need to get back to work.")
        print()
        return "go back"


Cataracta_Blacksmith = Room(name="Ulric's House", des="", id="Cataracta_Blacksmith", directions="", on_enter=Cataracta_Blacksmith_Logic)


