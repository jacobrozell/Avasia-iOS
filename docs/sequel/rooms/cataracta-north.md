# Northern Cataracta

> Bridge to housing; gateway to courtyard and barracks.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaNorth` |
| **Python `current_room_id`** | `Cataracta_North` |
| **Display name** | Northern Cataracta |
| **Room type** | link |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | yes |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_North.py` |

## Story & purpose

Directs the player to the Legion courtyard for enlistment. West barracks is a
soft gate (guards).

## Characters

None in room text.

## Prerequisites

None.

## State flags

None.

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `SOUTH` | `cataractaHousing` | always |
| `EAST` | `cataractaCourtyard` | before massacre |
| `EAST` | `cataractaCourtyard` | after massacre → ashes scene / redirect |
| `WEST` | `cataractaBarracks` | always → auto-return |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `SOUTH` | normalized | — | Housing |
| `EAST` | normalized | — | Courtyard |
| `WEST` | normalized | — | Barracks → return north |
| other | normalized | — | Hint: EAST, SOUTH, or WEST |

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
| `SoCCataractaNorth` | `SoCCataractaRooms.swift` | — |

## Source quirks

Author TODO: block all paths to Cataracta post-massacre (`main.py`); not implemented.

## Related rooms

Courtyard (Act II), Barracks (optional).
