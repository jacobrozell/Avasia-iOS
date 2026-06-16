# Nascastrum Throne Room — Audience with Kaefden IV

> Act III climax (authored for iOS, 2026-06-15). Extends the Python stub.
> Design notes: [`future/throne-audience.md`](future/throne-audience.md)

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `throneRoom` |
| **Python `current_room_id`** | `throne_room` |
| **Display name** | Nascastrum Throne Room |
| **Room type** | logic |
| **Act** | III |
| **Region** | `nacastrum` |
| **Critical path** | **yes** |
| **iOS port** | ✅ authored |
| **Source file** | `Avasia-SoC/Nacastrum/Throne_Room.py` (stub) · `SoCThroneRoom.swift` |

## Story & purpose

Druid survivor delivers Vashirr's threat to **King Kaefden IV** (KoN protagonist).
Mobilization ordered; **Blade of Courage** quest seeded (Varatro Falls → Ofelos); PC pledged by class.

## Characters

| Name | Role | Notes |
|---|---|---|
| **Kaefden IV** | King | Mage-blood; **seven years** on the throne; orders Blade quest + northern march |
| **Thekia** | High Mage's Council | Library woman; vouches at gates |
| Guards | Court | Challenge intruder |

## Prerequisites

- Library visited (`metThekia`)
- `playerClass` set (courtyard)

## State flags

| Flag | When |
|---|---|
| `metThekia` | Library `onEnter`; throne entry |
| `thronePhase` | Scene machine |
| `throneAudience` | After mobilization beat |
| `warCampBriefed` | Same — unlocks Act IV when written |

## Player options

| Input | Phase | Outcome |
|---|---|---|
| `CONTINUE`, `TALK`, `YES`, `PROCEED` | `atThrone` | Recount massacre |
| same | `deliverVashirr` | Vashirr's message + Kaefden response (Paladins, Ofelos, Blade) |
| same | `classService` | Class pledge + mobilization; **Act III complete** |
| same | done | Epilogue hint (Act IV TBD) |

### Class pledge lines

| Class | Pledge |
|---|---|
| Hunter | Front-line assault |
| Guardian | Shield wall |
| Scout | Vent escape / recon intel |
| none | Generic service |

## Navigation

Stays in throne room until audience complete, then **MARCH** → `aylovaWarCamp`.

## iOS implementation

`SoCThroneRoom.swift` — phased scene, win sting on completion.

## Related

[Library](library.md) · [West hallway](west-hallway.md) · [Aylova war camp](aylova-war-camp.md)
