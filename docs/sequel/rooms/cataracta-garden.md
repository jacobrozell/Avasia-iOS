# Castle Garden

> Anula fountain easter egg; **orphan room in source graph**.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaGarden` |
| **Python `current_room_id`** | `Cataracta_Garden` |
| **Display name** | Castle Garden |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported (wired **North → NORTH**) |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Garden.py` |

## Story & purpose

Light meta humor; blue crystal **Anula** ties to KoN motif. Coin toss does nothing.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| Young boy | Child by fountain | `TALK` / `APPROACH` / `SPEAK` / `PEOPLE` | Parents' luck superstition |
| Young couple | Ambient | `LOOK` | Holding hands |
| Older gentleman | Ambient | `LOOK` | Reading |
| Druid families | Ambient | On enter | Children playing |

## Prerequisites

None (if reached).

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `fountain` | read | `True` after first `COIN`/`THROW` | never |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `LEAVE`, `BACK`, `RETURN`, `WEST` | prior room | `go back` → **North** in iOS |

**Graph:** iOS adds `Cataracta_North` **NORTH** → garden (not in original Python directions).

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `COIN`, `THROW` | — | `fountain == False` | −1 gold; heads/tails; nothing happens |
| `COIN`, `THROW` | — | `fountain == True` | "You already tossed a coin" |
| `LOOK`, `SEARCH` | — | — | Ambient description |
| `TALK`, `APPROACH`, `SPEAK`, `PEOPLE` | — | — | Boy dialogue about luck |
| `LEAVE`, `BACK`, `RETURN`, `WEST` | — | — | Exit |

### Coin flip (`randint(0, 1)`)

- Tails: "Nothing happens."
- Heads: "Nothing happens." + *"I guess some things just aren't worth doing."*

## Items

None (gold sink only).

## Combat

None.

## Trophies & XP

None.

## Parser & commands

Loop: "What would you like to do?"

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCLogicStub` | `SoCStubRoom.swift` | Scene + wiring from North? |

## Source quirks

**Orphan:** add exit in design when wiring (e.g. North `N` or keep debug-only).

## Design intent (not in source)

[`STORY.md`](../STORY.md) suggests garden near keep — no exit chosen in prototype.

## Related rooms

None wired. Thematic link: Anula / blue crystal in KoN.
