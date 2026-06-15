import Foundation

/// The room registry. Implemented rooms are wired here; everything else gets a
/// descriptive `StubRoom` so the game is fully traversable while the remaining
/// areas are ported. Build order suggestion: cave → forest/tree → western road
/// → endgame (the critical path in WORLD_MAP.md).
public enum World {
    public static func build() -> [RoomID: RoomScript] {
        var rooms: [RoomID: RoomScript] = [:]

        func add(_ r: RoomScript) { rooms[r.id] = r }

        // --- Implemented vertical slice (Oceandale region + hub + first gate) ---
        add(OceandaleRoom())
        add(BeachRoom())
        add(TradingPostRoom())
        add(MagehouseRoom())
        add(GraveyardRoom())
        add(ChurchRoom())
        add(SplitpathRoom())
        add(BridgeRoom())

        // --- Stubs for not-yet-ported areas (carry intended descriptions) ---
        let stubs: [(RoomID, String, String, RoomID)] = [
            (.mountain, "Mountain", "A windswept ridge. North: a cave. East: a druid scout. West: the path to Cataracta.", .bridge),
            (.druidTalk, "Dentros the Druid Scout", "A red fox becomes a man with cherry-red hair. He offers you a lantern.", .mountain),
            (.westMountain, "West Mountain", "The trail bends toward a blue-crystal gate.", .mountain),
            (.druidPath, "Cataracta Gate", "Druid hunters bar the way. Prove you are a mage.", .westMountain),
            (.caveEntrance, "Cave Entrance", "Pitch dark. You will need a light to go on.", .mountain),
            (.mainCave, "Main Cave", "Enormous pink crystals illuminate the cavern. Passages run in every direction.", .caveEntrance),
            (.northCave, "North Cave", "An ancient archway set with three rune buttons.", .mainCave),
            (.fireballRoom, "Fireball Room", "A cracked pedestal; a mage burnt to ash in the corner. Enter the rune order.", .northCave),
            (.eastCave, "East Cave", "A rune is scratched here — the final symbol.", .mainCave),
            (.westCave, "West Cave", "Blood drips from above. A fork lies ahead.", .mainCave),
            (.northwestCave, "Northwest Cave", "A murdered miner among translucent shards. The second symbol.", .mainCave),
            (.northeastCave, "Northeast Cave", "Hanging cages and a skeleton. Levitate up for the third symbol.", .mainCave),
            (.forestEntrance, "Forest Entrance", "Overgrown grass blocks the way. You'll need to cut it.", .splitpath),
            (.forestTrap, "Forest Trap", "A net snaps tight — then a Sylvian marksman cuts you free.", .silvarium),
            (.silvarium, "Silvarium", "An enormous tree, far larger than the rest, hung with houses and bridges.", .forestEntrance),
            (.treeFloor1, "Great Tree — Floor 1", "Game-drop tables. A boy named Marlux watches you.", .silvarium),
            (.treeFloor2, "Great Tree — Floor 2", "Left: the butcher. Right: the armory.", .treeFloor1),
            (.treeButcher, "The Butcher", "A bearded man in bear-skin gives you a chest: Suformin's Dagger.", .treeFloor2),
            (.treeArmory, "The Armory", "A guard bars the way — Sylvian hunters only.", .treeFloor2),
            (.treeFloor3, "Great Tree — Floor 3", "Left: the Church of Suformin. Right: the library.", .treeFloor2),
            (.treeChurch, "Church of Suformin", "An elk-headed priestess tends the shrine of the God of the Hunt.", .treeFloor3),
            (.treeLibrary, "The Library", "A vain librarian in a fox coat guards his hoard of knowledge.", .treeFloor3),
            (.treeFloor4, "Great Tree — Floor 4", "The blood seal: crossed daggers in a target. Cut yourself to open it.", .treeFloor3),
            (.westernRoad, "Western Road", "North: the road to Nacastrum. West: the shoreside.", .splitpath),
            (.shoreside, "Shoreside", "A quiet beach. An abandoned hut stands nearby.", .westernRoad),
            (.beachHut, "Beach Hut", "A fishing rod leans by the door.", .shoreside),
            (.roadToNacastrum, "Road to Nacastrum", "Ambush, then stone spires, then a bridge that should not be here.", .westernRoad),
            (.teleporter, "Ring of Malkos", "A teleporter platform beneath the floating city. You cannot work it alone.", .roadToNacastrum),
            (.nacastrum, "Nacastrum", "The floating city of the Mage, silver and ruined.", .teleporter),
            (.aylova, "Aylova", "The capital of Kaefden, where the banished mages gathered.", .nacastrum),
            (.ending, "The End", "The mages stream home through the portal. \"Let us go, my king.\"", .nacastrum)
        ]
        for (id, title, note, back) in stubs {
            add(StubRoom(id, title: title, note: note, returnsTo: back))
        }

        // Fallback for any unmapped id.
        add(StubRoom(.stub, title: "Uncharted", note: "There is nothing here yet.", returnsTo: .oceandale))

        return rooms
    }
}
