# West Castle Hallway

> Nacastrum hub between library, throne, and portal.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `westHallway` |
| **Python `current_room_id`** | `west_hallway` |
| **Display name** | West Castle Hallway |
| **Room type** | link |
| **Act** | III |
| **Region** | `nacastrum` |
| **Critical path** | **yes** |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Nacastrum/West_Hallway.py` |

## Story & purpose

Connects infiltration route to throne wing. East door described as jewel-encrusted.

## Characters

None.

## Prerequisites

Reach via [library](library.md) (`SOUTH`).

## State flags

None.

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `NORTH` | `library` | always (replays library scene) |
| `EAST` | `throneRoom` | always |
| `WEST` | `portalRoom` | always |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `NORTH` | normalized | — | Library |
| `EAST` | normalized | — | Throne |
| `WEST` | normalized | — | Portal |
| other | normalized | — | Hint: NORTH, EAST, or WEST |

## Items

None.

## Combat

None.

## Trophies & XP

None.

## Parser & commands

`normalized`.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaWestHallway` | `SoCCataractaRooms.swift` | — |

## Related rooms

[Library](library.md), [Throne](throne-room.md), [Portal](portal-room.md).
