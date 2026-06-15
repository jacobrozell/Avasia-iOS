from Room.Room import Room


Cataracta_Housing = Room(name="Southwest Cataracta",
                   des="You feel the wind on your face and smell the familiar scent of the Cataractan air."
                       "\nTo the NORTH, a large, ornate wooden bridge leads across the beautiful Varatho river to the upper part of the town."
                       "\nTo the WEST, is the Hunter's Path."
                       "\nTo the EAST, is the shopping district of Cataracta.",
                   id="Cataracta_Housing",
                   directions={"W": "Cataracta_Hunter_Path", "N": "Cataracta_North", "E": "Cataracta_Shopping"})
