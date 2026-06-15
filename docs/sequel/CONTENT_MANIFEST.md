# Avasia: Sword of Courage — Content Manifest

> Maps Python prototype room IDs to Swift `SoCRoomID` values. **Per-room detail**
> (NPCs, options, items, flags): [`rooms/README.md`](rooms/README.md).
> Schema: [`ROOM_SPEC_STANDARD.md`](ROOM_SPEC_STANDARD.md).

---

## Region plan (Swift)

| Region (proposed) | `Region` enum (future) | Art hook |
|---|---|---|
| Cataracta (peace) | `.cataracta` | Green mountains, river bridge |
| Cataracta (ruins) | `.cataractaRuins` | Ash, collapsed keep |
| Nacastrum castle | `.nacastrum` | Reuse KoN castle assets |
| Aylova camp | `.aylova` | Reuse KoN aylova + military tents |
| War front | `.warFront` | Oceandale ridge, border scrub |

Add cases to `Region.swift` when SoC content lands in the Swift package.

---

## Room ID mapping

| Python `current_room_id` | Swift `SoCRoomID` | Act | Logic? | Room spec |
|---|---|---|---|---|
| `Cataracta_Housing` | `cataractaHousing` | I | Link | [spec](rooms/cataracta-housing.md) |
| `Cataracta_North` | `cataractaNorth` | I | Link | [spec](rooms/cataracta-north.md) |
| `Cataracta_Shopping` | `cataractaShopping` | I | Link | [spec](rooms/cataracta-shopping.md) |
| `Cataracta_Hunter_Path` | `cataractaHunterPath` | I | Script | [spec](rooms/cataracta-hunter-path.md) |
| `Cataracta_Barracks` | `cataractaBarracks` | I | Script | [spec](rooms/cataracta-barracks.md) |
| `Cataracta_Athalos` | `cataractaAthalos` | I | Script | [spec](rooms/cataracta-athalos.md) |
| `Cataracta_Blacksmith` | `cataractaBlacksmith` | I | Script | [spec](rooms/cataracta-blacksmith.md) |
| `Cataracta_Pier` | `cataractaPier` | I | Script | [spec](rooms/cataracta-pier.md) |
| `Cataracta_Fishing` | `cataractaFishing` | I | Script | [spec](rooms/cataracta-fishing.md) |
| `Cataracta_Garden` | `cataractaGarden` | I | Script | [spec](rooms/cataracta-garden.md) (iOS: North N) |
| `Cataracta_Courtyard` | `cataractaCourtyard` | II | Script | [spec](rooms/cataracta-courtyard.md) |
| `c_portal_room` | `portalRoom` | III | Script | [spec](rooms/portal-room.md) |
| `n_library` | `library` | III | Script | [spec](rooms/library.md) |
| `west_hallway` | `westHallway` | III | Link | [spec](rooms/west-hallway.md) |
| `throne_room` | `throneRoom` | III | Script | [spec](rooms/throne-room.md) |

### Future rooms (no Python source — no room spec yet)

`aylova_war_camp`, `aylova_quartermaster`, `northern_march`, `oceandale_front`,
`mage_outpost`, `cataracta_ruins`, `vashirr_stand`, `soc_epilogue` — see
[`ROADMAP.md`](ROADMAP.md).

---

## State flags mapping

| Python `config` | Proposed `GameState` key |
|---|---|
| `cataracta_destroyed` | `cataractaDestroyed` |
| `met_thekia` | `metThekia` |
| `throne_audience` | `throneAudience` |
| `war_camp_briefed` | `warCampBriefed` |
| `oceandale_front_cleared` | `oceandaleFrontCleared` |
| `mage_outpost_cleared` | `mageOutpostCleared` |
| `ruins_visited` | `ruinsVisited` |
| `scout_shortcut` | `scoutShortcut` |
| `game_complete` | `gameComplete` |

Existing SoC flags (`fountain`, `ulric`, `doran`, `portalRoom`, etc.) port as-is.

---

## Systems to add in Swift

| System | KoN today | SoC needs |
|---|---|---|
| Parser / rooms | ✅ | Reuse |
| Narrative pacing | ✅ | Reuse |
| Spells | ✅ | Not used |
| Combat UI | Minimal (Inflame etc.) | Full turn-based module |
| Classes | — | `hunter` / `guardian` / `scout` |
| XP / levels | — | Port from `Player.py` |
| Trophies | Achievements (22) | SoC catalog (7) |

---

## Integration order (suggested)

1. `soc_courtyard` → massacre E2E (highest drama, tests combat)
2. `soc_portalRoom` → `soc_throneRoom` (Kaefden IV scene)
3. `soc_warCamp` → `soc_oceandaleFront` → `soc_vashirrStand` → `soc_epilogue`
4. Optional Act I content + ruins
5. App shell: game picker (KoN vs SoC) or unified saga menu

---

## Source files (Python → Swift)

| Python | Swift (proposed) |
|---|---|
| `Avasia-SoC/Cataracta/*.py` | `Sources/AvasiaSoC/Content/Rooms/CataractaRooms.swift` |
| `Avasia-SoC/Nacastrum/*.py` | `Sources/AvasiaSoC/Content/Rooms/NacastrumCastleRooms.swift` |
| `Avasia-SoC/Aylova/*.py` | `Sources/AvasiaSoC/Content/Rooms/AylovaRooms.swift` |
| `Avasia-SoC/War/*.py` | `Sources/AvasiaSoC/Content/Rooms/WarRooms.swift` |
| `Combat/Combat.py` | `Sources/AvasiaSoC/Systems/CombatEngine.swift` |

Package does not exist yet — create when KoN remake ships and SoC port begins.
