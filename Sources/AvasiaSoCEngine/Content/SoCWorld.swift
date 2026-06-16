import Foundation
import AvasiaEngine

public enum SoCWorld {
    public static func build() -> [SoCRoomID: SoCRoomScript] {
        var rooms: [SoCRoomID: SoCRoomScript] = [:]
        func add(_ r: SoCRoomScript) { rooms[r.id] = r }

        add(SoCCataractaHousing())
        add(SoCCataractaNorth())
        add(SoCCataractaShopping())
        add(SoCCataractaWestHallway())
        add(SoCCataractaHunterPath())
        add(SoCCataractaBarracks())

        add(SoCCourtyardRoom())
        add(SoCPortalRoom())
        add(SoCLibraryRoom())
        add(SoCThroneRoom())

        add(SoCAylovaWarCampRoom())
        add(SoCSilvariumEldersRoom())
        add(SoCVaratroFallsRoom())
        add(SoCOfelosRoom())
        add(SoCNorthernMarchRoom())
        add(SoCOceandaleFrontRoom())
        add(SoCMageOutpostRoom())
        add(SoCVashirrStandRoom())
        add(SoCAgeEpilogueRoom())
        add(SoCCataractaRuinsRoom())

        add(SoCCataractaAthalos())
        add(SoCCataractaBlacksmith())
        add(SoCCataractaPier())
        add(SoCCataractaFishing())
        add(SoCCataractaGarden())

        return rooms
    }
}
