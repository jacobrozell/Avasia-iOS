# Hunter's Path

> Brief redirect; reinforces courtyard as enlistment goal.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaHunterPath` |
| **Python `current_room_id`** | `Cataracta_Hunter_Path` |
| **Display name** | *(empty in source)* |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Hunter_Path.py` |

## Story & purpose

Flavor that hunters use this trail; nudges player toward courtyard without blocking.

## Characters

None.

## Prerequisites

None.

## State flags

None.

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| *(auto)* | prior room (`cataractaHousing`) | immediately after text |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| *(enter)* | — | — | Print 2 lines; `go back` |
| any (if stuck) | normalized | iOS fallback | Move to housing |

## Items

None.

## Combat

None.

## Trophies & XP

None.

## Parser & commands

`normalized`. No prompt in source — Python returns before main loop input.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaHunterPath` | `SoCCataractaRooms.swift` | `autoReturnAfterEnter` → housing |

## Source quirks

Room `name` is empty string; only body text prints.

## Related rooms

[Housing](cataracta-housing.md) (entry).
