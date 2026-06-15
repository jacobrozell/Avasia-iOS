# Guard Barracks

> Guards block entry; soft rejection.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaBarracks` |
| **Python `current_room_id`** | `Cataracta_Barracks` |
| **Display name** | *(empty in source)* |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Barracks.py` |

## Story & purpose

Shows Cataracta has a formal guard force separate from the Legion courtyard.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| Two Cataractan Legionnaires | Guards | Implied at entrance | No dialogue |

## Prerequisites

None.

## State flags

None.

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| *(auto)* | `cataractaNorth` | after text |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| *(enter)* | — | — | 4 lines; `go back` to north |

## Items

None.

## Combat

None.

## Trophies & XP

None.

## Parser & commands

No input loop in source.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaBarracks` | `SoCCataractaRooms.swift` | `autoReturnAfterEnter` → north |

## Related rooms

[North](cataracta-north.md).
