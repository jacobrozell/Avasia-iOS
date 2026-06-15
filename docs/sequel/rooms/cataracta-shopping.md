# Shopping District

> Act I commerce hub; routes to optional NPC scenes.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaShopping` |
| **Display name** | Shopping District |
| **Room type** | link |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional (hub only) |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Shopping.py` |

## Story & purpose

Orients player to Athalos, Ulric, and Doran before war. All three are optional.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| Athalos | General store | South exit | Eccentric shopkeeper |
| Ulric | Blacksmith | East exit | Doran's brother |
| Doran | Fisherman | North exit | Pier owner |

## Prerequisites

None.

## State flags

None in link room (downstream rooms set `ulric`, `doran`).

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `NORTH` | `cataractaPier` | always |
| `SOUTH` | `cataractaAthalos` | always |
| `EAST` | `cataractaBlacksmith` | always |
| `WEST` | `cataractaHousing` | always |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `NORTH` / `SOUTH` / `EAST` / `WEST` | normalized | — | Move |
| other | normalized | — | Hint: NORTH, SOUTH, EAST, or WEST |

## Items

None in link room.

## Combat

None.

## Trophies & XP

None.

## Parser & commands

`normalized`.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaShopping` | `SoCCataractaRooms.swift` | — |

## Related rooms

[Ulric](cataracta-blacksmith.md) → [Doran](cataracta-pier.md) → [Fishing](cataracta-fishing.md); [Athalos](cataracta-athalos.md) flavor.
