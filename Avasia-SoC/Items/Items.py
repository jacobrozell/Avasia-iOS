class Item:
    def __init__(self, name, des, value):
        self.name = name
        self.des = des
        self.value = value
        self.typeID = ""

    def print_stats(self):
        print(str(self.name) + ": " + str(self.value) + " gold, " + "\n" + str(self.des) + ".")

    def print_value(self):
        print("It's worth " + str(self.value) + " gold!")

    def getID(self):
        return self.typeID


# ---------- Food Class ----------
class Food(Item):
    def __init__(self, name, des, value, restored_amount):
        Item.__init__(self, name, des, value)
        self.restored_amount = restored_amount
        self.typeID = "food"

    def healsFor(self):
        return self.restored_amount


# ---------- Junk Class ----------
class Junk(Item):
    def __init__(self, name, des, value):
        Item.__init__(self, name, des, value)
        self.typeID = "junk"


# ---------- Weapon Class ----------
class Weapon(Item):
    def __init__(self, name, des, value, atk, spd):
        Item.__init__(self, name, des, value)
        self.atk = atk
        self.spd = spd
        self.typeID = "weapon"

    def print_stats(self):
        print(self.name + ": attack = " + str(self.atk) + ", speed = "
            + str(self.spd) + ", value = " + str(self.value) + ".")
        print(self.name + ": " + self.des)


