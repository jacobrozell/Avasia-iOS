import Foundation

/// The room registry. All regions are now implemented; `.stub` remains only as a
/// safety fallback for any id that somehow lacks a script. Build order followed
/// the critical path in WORLD_MAP.md: Oceandale → mountain/cave → forest/tree →
/// western road → endgame.
public enum World {
    public static func build() -> [RoomID: RoomScript] {
        var rooms: [RoomID: RoomScript] = [:]
        func add(_ r: RoomScript) { rooms[r.id] = r }

        // --- Oceandale region + central hub + first gate ---
        add(OceandaleRoom())
        add(BeachRoom())
        add(TradingPostRoom())
        add(MagehouseRoom())
        add(GraveyardRoom())
        add(ChurchRoom())
        add(SplitpathRoom())
        add(BridgeRoom())

        // --- Mountain & cave (east) ---
        add(MountainRoom())
        add(DruidTalkRoom())
        add(WestMountainRoom())
        add(DruidPathRoom())
        add(CaveEntranceRoom())
        add(MainCaveRoom())
        add(NorthCaveRoom())
        add(FireballRoom())
        add(NortheastCaveRoom())
        add(NorthwestCaveRoom())
        // Two clue rooms share the generic SymbolClueRoom (reveal by slot).
        add(SymbolClueRoom(
            id: .eastCave, slot: 3, ordinal: "final",
            flavor: [.body("A cramped dead-end chamber, the air thick with old dust.")]
        ))
        add(SymbolClueRoom(
            id: .westCave, slot: 0, ordinal: "first",
            flavor: [
                .body("Blood drips from the dark above. The passage forks; corpses with deep gashes line the left dead-end."),
                .body("It is the symbol that repeats at the start of the sequence.")
            ]
        ))

        // --- Forest & great tree (north) ---
        add(ForestEntranceRoom())
        add(ForestTrapRoom())
        add(SilvariumRoom())
        add(TreeFloor1Room())
        add(TreeFloor2Room())
        add(TreeButcherRoom())
        add(TreeArmoryRoom())
        add(TreeFloor3Room())
        add(TreeChurchRoom())
        add(TreeLibraryRoom())
        add(TreeFloor4Room())

        // --- Western road + gauntlet (west) ---
        add(WesternRoadRoom())
        add(ShoresideRoom())
        add(BeachHutRoom())
        add(RoadToNacastrumRoom())
        add(TeleporterRoom())

        // --- Endgame ---
        add(NacastrumRoom())
        add(AylovaRoom())
        add(EndingRoom())

        // Safety fallback.
        add(StubRoom(.stub, title: "Uncharted", note: "There is nothing here yet.", returnsTo: .oceandale))

        return rooms
    }
}
