# Cataractan Legion Courtyard

> Act II set piece: class select, massacre, Vashirr, ashes → portal.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaCourtyard` |
| **Python `current_room_id`** | `Cataracta_Courtyard` |
| **Display name** | Courtyard |
| **Room type** | logic |
| **Act** | II |
| **Region** | `cataracta` |
| **Critical path** | **yes** |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Courtyard.py` |

## Story & purpose

Emotional pivot: peaceful enlistment → genocide. Player receives Vashirr's message
for Kaefden IV. Ends with Cataracta in ashes; `current_room_id` → `c_portal_room`.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| **Dentros** | Legion recruiter | Intro | Dies blocking Vashirr's bolt |
| **Kimious** | King of Cataracta | Speech | Killed by dark energy |
| **Vashirr** | Antagonist | Invasion | Hooded; scar; gray staff; unmasked after fights |
| **Destros** | *(typo?)* | Between fights | "lying on the floor" — likely **Dentros** |
| Agromanian Grunt | Enemy 1 | Combat 1 | — |
| Agromanian Warrior | Enemy 2 | Combat 2 | — |

## Prerequisites

Reach from [North](cataracta-north.md) (`EAST`).

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `courtyardComplete` | read | `True` after ashes | — |
| `courtyardPhase` | Swift | phase machine | — |
| `playerClass` | write | Wolf/Bear/Fox | — |
| combat fields | Swift | `inCombat`, `enemy`, etc. | death / kill |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| *(script end)* | `portalRoom` | massacre complete |
| any | `cataractaNorth` | `courtyardComplete` (iOS) |

## Player options

### Phase 1 — Class select

| Input (triggers) | Outcome |
|---|---|
| `WOLF` | Hunter stats → massacre |
| `FOX` | Scout stats → massacre |
| `BEAR` | Guardian stats → massacre |
| other | "Wolf, Bear, or Fox?" |

### Phase 2 — Combat ×2

| Input (triggers) | Outcome |
|---|---|
| `ATTACK`, `STRIKE`, `FIGHT` | Combat round |
| `HELP`, `COMMANDS` | List ATTACK, HEAL, HELP |

Between fights: **full HP restore** (author note in source: needs story excuse).

### Phase 3 — Scripted aftermath

Vashirr speech → mass execution → knockout → ashes awakening.

## Items

None.

## Combat

| Enemy | ATK | SPD | HP | Death text |
|---|---:|---:|---:|---|
| Agromanian Grunt | 5 | 5 | 15 | mace to side of head |
| Agromanian Warrior | 6 | 3 | 18 | sword pierces chest |

Enemy luck **0** (unset in `set_stats`).

## Trophies & XP

None in this room.

## Parser & commands

`normalized` for class; combat uses same.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCourtyardRoom` | `SoCCourtyardRoom.swift` | — |

## Source quirks

- Sets `config.current_room_id = "c_portal_room"` and `return "reload"` — no return to Cataracta graph.
- **Destros** vs **Dentros** typo in between-combat line.

## Related rooms

[North](cataracta-north.md), [Portal](portal-room.md). Set piece: [`../SET_PIECES.md`](../SET_PIECES.md).

## Design intent (not in source)

[`main.py`](../../Avasia-SoC/Logic/main.py) TODO: destroy paths to Cataracta after attack.
