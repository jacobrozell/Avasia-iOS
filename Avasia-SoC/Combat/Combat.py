from Logic import util, config
from random import randint


class Combat:
    def __init__(self):
        self.actions = ["ATTACK", "HEAL", "HELP"]
        self.player_attacks_first = True
        self.needed_luck_to_hit = 5

    def start_combat(self):
        util.set_color_to(config.combat_color)

        combat_heal = ["HEAL", "EAT", "DRINK", "USE ITEM", "USE"]
        combat_help = ["HELP", "COMMANDS"]
        attack = ["ATTACK", "STRIKE", "FIGHT"]

        while True:
            self.print_combat_stats()
            command = input("What do will you do?")
            command.upper()

            if util.containsAny(command, combat_help):
                print(self.actions)
                print()
                
            # elif util.containsAny(command, combat_heal):
            #     print("What do you want to use?")
            #     config.config.config.player.print.config.player_inventory()
            #     itemToBeEaten = input()

            elif util.containsAny(command, attack):
                print()
                self.roll_for_initiative()
                self.attack_phase()
                if self.there_is_a_casualty():
                    util.set_color_to(config.base_color)
                    break

    def roll_for_initiative(self):
        self.needed_luck_to_hit = randint(0, 11)
        if config.player.is_faster_than_enemy():
            self.player_attacks_first = True
        else:
            self.player_attacks_first = False

    def attack_phase(self):
        if self.player_attacks_first:
            self.player_attacks()
            self.enemy_attacks()
        else:
            self.enemy_attacks()
            self.player_attacks()

    def player_attacks(self):
        if config.player.luck_is_greater_than(self.needed_luck_to_hit):
            config.player.attacks_enemy()
        else:
            print("You miss!")

    def enemy_attacks(self):
        if config.enemy.luck_is_greater_than(self.needed_luck_to_hit):
            config.enemy.attacks_player()
        else:
            print(config.enemy.get_name() + " misses!")

    def there_is_a_casualty(self):
        if config.player.is_dead():
            config.enemy.kill_player()
            return True
        elif config.enemy.is_dead():
            config.player.kill_enemy()
            return True
        else:
            return False

    def print_combat_stats(self):
        config.enemy.print_stats()
        config.player.print_stats()
