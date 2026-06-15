# Athalos' House (Althalos' Wares)

> Flavor shop visit; no items to buy in source.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaAthalos` |
| **Python `current_room_id`** | `Cataracta_Athalos` |
| **Display name** | Althalos' House / sign: "Althalos' Wares" |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Athalos.py` |

## Story & purpose

Humanize Cataracta before destruction. Athalos knows the player is joining the
Legion; wishes he could help but has no stock to give.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| **Athalos** / **Althalos** | Shopkeeper | On enter | Kind, eccentric; shop empty of customers, full of goods |

### Dialogue beats

1. "Ah, {name}, I hear you're joining the Cataractan Legion!"
2. Praises volunteering vs waiting to be drafted.
3. Wishes he had something to give; invites future purchases.
4. "Take care and good luck!"

## Prerequisites

Player name set (`config.player.get_name()`).

## State flags

None.

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| *(auto)* | `cataractaShopping` | after scene (`go back`) |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| *(enter)* | — | — | Full scene; auto leave |

No player choice branch in source.

## Items

| Item | Action | Cost | Effect |
|---|---|---|---|
| — | — | — | **No shop UI in source** — dialogue only |

## Combat

None.

## Trophies & XP

None.

## Parser & commands

Single `on_enter`; no loop.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaAthalos` | `SoCActIRooms.swift` | — |

## Source quirks

Spelling **Althalos** (sign) vs **Athalos** (room name). No inventory transactions.

## Related rooms

[Shopping](cataracta-shopping.md) (south entry from district).
