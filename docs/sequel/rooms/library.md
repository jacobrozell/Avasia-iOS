# Nascastrum Library

> Witness account; escort beat toward throne (stub).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `library` |
| **Python `current_room_id`** | `n_library` |
| **Display name** | Nascastrum Library *(source spelling)* |
| **Room type** | logic |
| **Act** | III |
| **Region** | `nacastrum` |
| **Critical path** | **yes** |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Nacastrum/Library.py` |

## Story & purpose

Player delivers oral report of Cataracta's fall. Mage official sends player to alert
the king. Bridges Druid outsider POV to Kaefden court.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| Purple-robed woman | Mage official | On enter | **Unnamed in source**; design name **Thekia** in [`STORY.md`](../STORY.md) |

### Dialogue beats

1. "What are you doing here, druid? How did you get here?"
2. Player explains massacre, Vashirr, mass teleport of Agromanians.
3. "We must go and alert the king!" / "Follow me."
4. Exits south; player must follow.

## Prerequisites

Enter via [portal puzzle](portal-room.md).

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `libraryLooked` | Swift optional | LOOK | — |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `SOUTH` | `westHallway` | follow woman |

## Player options

| Input (triggers) | Parser | Condition | Outcome |
|---|---|---|---|
| `SOUTH` | raw | — | Run after woman → hallway |
| `LOOK`, `AROUND`, `SEARCH` | raw | — | Cataracta vs Nacastrum education lore + **15 XP** |
| other | raw | — | `"{input} is not a valid command."` |

### LOOK lore (summary)

Cataracta youths: fish, hunt, survive — no academy. Class roles reflected in text.

## Items

None.

## Combat

None.

## Trophies & XP

| Reward | Trigger |
|---|---|
| +15 quest XP (`smallQuestExp`) | First `LOOK` / `SEARCH` |

## Parser & commands

**`raw`**.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCLibraryRoom` | `SoCLibraryRoom.swift` | XP system not ported |

## Source quirks

Title typo **Nascastrum** vs Nacastrum elsewhere.

## Related rooms

[Portal](portal-room.md), [West hallway](west-hallway.md) → [Throne](throne-room.md).

## Design intent (not in source)

Throne audience with **Kaefden IV** (KoN protagonist) — not written in prototype.
