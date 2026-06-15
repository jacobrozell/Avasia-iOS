# Ulric's Blacksmith

> Starts the Ulric → Doran → fishing side chain.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaBlacksmith` |
| **Python `current_room_id`** | `Cataracta_Blacksmith` |
| **Display name** | Ulric's House |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Blacksmith.py` |

## Story & purpose

Brotherly banter; sends player to Doran for fishing. Second visit is dismissive.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| **Ulric** | Blacksmith | On enter | Sitting on steps; metal stacks everywhere |

### First visit (`config.ulric == False`)

- Acknowledges army enlistment = more business.
- Directs player to brother **Doran** at pier (fishing poles).
- "Now go bother my brother."

### Repeat visit (`config.ulric == True`)

- "Go bother my brother. I need to get back to work."

## Prerequisites

None.

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `ulric` | read | set `True` if `doran == False` | Pier sets `ulric = False` on free-fish path |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| *(auto)* | `cataractaShopping` | `go back` |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| *(enter)* | — | first / repeat | Dialogue branch; auto leave |

## Items

None given.

## Combat

None.

## Trophies & XP

Enables **Brotherly Love** trophy at pier (not here).

## Parser & commands

`on_enter` only.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaBlacksmith` | `SoCActIRooms.swift` | — |

## Source quirks

If `doran` is already `True` before first Ulric visit, `ulric` flag is **not** set
(line 20–21 guard).

## Related rooms

[Doran pier](cataracta-pier.md), [Shopping](cataracta-shopping.md).
