from Logic import util, config
from Logic.Save import loadParameters


class Enemy:
    def __init__(self, atk, speed, hp, name, luck):

        # Name
        self.name = name

        # Attack
        self.atk = atk
        self.maxAtk = atk

        # Speed
        self.speed = speed
        self.maxSpeed = speed

        # Hp
        self.hp = hp
        self.maxHp = hp

        # Luck
        self.luck = luck
        self.maxLuck = luck

        # Kill player text
        self.text = ""

    def take_hit(self):
        self.hp -= config.player.get_atk()

    def did_appear(self):
        print("A" + str(self.name) + " appeared!\n")

    def print_stats(self):
        print("\n" + config.enemy.get_name() + ":\n\t HEALTH: " + str(config.enemy.get_hp()) +
              "\n\t ATTACK: " + str(config.enemy.get_atk()) +
              "\n\t SPEED: " + str(config.enemy.get_speed()) + "\n")

    def set_stats(self, name, atk, hp, speed, text=""):

        # Name
        self.name = name

        # Attack
        self.atk = atk
        self.maxAtk = atk

        # Speed
        self.speed = speed
        self.maxSpeed = speed

        # Hp
        self.hp = hp
        self.maxHp = hp

        # Kill player text
        self.text = text

    def kill_player(self):
        util.set_color_to(config.die_color)
        print(self.text + "\nYou have died.\n\n")
        util.set_color_to(config.base_color)
        while True:
            yes = ["YES", "y"]
            no = ["NO", "n"]
            ans = input("Would you like to load your last save?")
            ans.upper()

            if util.containsAny(ans, yes):
                loadParameters()
                break
            elif util.containsAny(ans, no):
                print("Thank you for playing!")
                quit()
            else:
                print()

    def is_dead(self):
        if config.enemy.get_hp() <= 0:
            return True
        else:
            return False

    def attacks_player(self):
        print(config.enemy.get_name() + " attacks you!")
        print("You take " + str(config.enemy.get_atk()) + " damage!\n")
        config.player.take_hit()

    def luck_is_greater_than(self, neededLuck):
        if config.enemy.get_luck() >= neededLuck:
            return True
        else:
            return False

    def is_faster_than_player(self):
        if config.enemy.get_speed() >= config.player.get_speed():
            return True
        else:
            return False

    # Getters and Setters
    # Name
    def set_name(self, name):
        self.name = name

    def get_name(self):
        return self.name

    # Attack
    def set_atk(self, atk):
        self.atk = atk

    def get_atk(self):
        return self.atk

    def get_max_atk(self):
        return self.maxAtk

    def set_max_atk(self, atk):
        self.maxAtk = atk

    # Hp
    def set_hp(self, hpin):
        self.hp = hpin
        self.maxHp = hpin

    def get_hp(self):
        return self.hp

    def set_max_hp(self, hp):
        self.maxHp = hp

    def get_max_hp(self):
        return self.maxHp

    # Speed
    def set_speed(self, speed):
        self.speed = speed

    def get_speed(self):
        return self.speed

    def set_max_speed(self, speed):
        self.maxSpeed = speed

    def get_max_speed(self):
        return self.maxSpeed

    # Luck
    def get_luck(self):
        return self.luck

    def set_luck(self, luck):
        self.luck = luck

    def get_max_luck(self):
        return self.maxLuck

    def set_max_luck(self, luck):
        self.maxLuck = luck

    # Text
    def set_text(self, text):
        self.text = text

