# Southwest Cataracta (Housing)

> Player home and Act I hub after intro.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaHousing` |
| **Python `current_room_id`** | `Cataracta_Housing` |
| **Display name** | Southwest Cataracta / `{name}'s House` (intro only) |
| **Room type** | link |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | yes (start) |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Housing.py` |

## Story & purpose

Peaceful opening hub. Establishes Cataracta's river, bridge, and districts before
the massacre. Intro text (separate from room `des`) frames enlistment day.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| *(player)* | Druid volunteer | Intro | Named in `util.intro` |

## Prerequisites

New game completed (100 gold, potion — see [`_global.md`](_global.md)).

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| — | — | — | — |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `NORTH` | `cataractaNorth` | always |
| `WEST` | `cataractaHunterPath` | always → auto-return to housing |
| `EAST` | `cataractaShopping` | always |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `NORTH` | normalized | — | Move to Northern Cataracta |
| `WEST` | normalized | — | Hunter Path scene → return here |
| `EAST` | normalized | — | Move to Shopping District |
| other | normalized | — | Hint: NORTH, WEST, or EAST |

## Items

None in room.

## Combat

None.

## Trophies & XP

`startedAdventure` awarded in intro, not in this room.

## Parser & commands

`normalized` (default). Global commands apply ([`_global.md`](_global.md)).

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaHousing` | `Content/Rooms/SoCCataractaRooms.swift` | Intro/name/potion not in engine |

## Source quirks

Room title in intro uses player name; linking room title is "Southwest Cataracta".

## Related rooms

North (courtyard path), Shopping (side content), Hunter Path (redirect).
