# Cataractan Portal Room

> Vent/books puzzle; entry to Nacastrum library.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `portalRoom` |
| **Python `current_room_id`** | `c_portal_room` |
| **Display name** | Cataractan Portal Room |
| **Room type** | logic |
| **Act** | III |
| **Region** | `nacastrum` |
| **Critical path** | **yes** |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Nacastrum/Portal_Room.py` |

## Story & purpose

Player arrives post-massacre via script jump. Must infiltrate castle via ducts;
east door is locked. Establishes Cataractan portal inside Nacastrum.

## Characters

None present.

## Prerequisites

Courtyard complete (script teleport in source).

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `portalRoom` | read | `True` after library entry | — |
| `ventFound` | local / Swift persisted | search sets true | — |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| library entry | `library` | vent (bear) or books |
| *(auto)* | `westHallway` | `portalRoom == True` re-entry |
| `EAST` | — | locked door (flavor) |

## Player options

### First visit (`portalRoom == False`)

| Input (triggers) | Parser | Condition | Outcome |
|---|---|---|---|
| `SEARCH`, `EXPLORE`, `LOOK`, `FIND` | raw | — | Find books + vent; `ventFound` |
| `EAST` | raw | — | Door won't budge (cast iron) |
| `VENT` | raw | `ventFound` + scout/hunter | Too short to reach |
| `VENT` | raw | `ventFound` + guardian | Climb → library |
| `BOOK`, `MOVE`, `MAGE`, `STACK` | raw | — | Stack books → library |
| `TAKE` | raw | `ventFound` | "You shouldn't take any of the books." |
| `TAKE` | raw | not searched | *(silent)* |
| `VENT` | raw | not searched | *(silent)* |
| other | raw | — | "Invalid command" |

### Return visit (`portalRoom == True`)

| Input | Outcome |
|---|---|
| *(enter)* | Unlock flavor text; `go back` to hallway |

## Items

None.

## Combat

None.

## Trophies & XP

None.

## Parser & commands

**`raw`** — preserves spaces (`GO NORTH` style).

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCPortalRoom` | `SoCPortalRoom.swift` | `ventFound` persisted in save |

## Source quirks

`ventFound` is local in Python (resets each visit); Swift persists for fairness.

Class gate: **guardian** (bear) uses vent; **hunter/scout** need books stack.

## Related rooms

[Library](library.md), [West hallway](west-hallway.md).
