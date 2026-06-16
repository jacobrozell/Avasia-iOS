# Scout Fork — REPORT / FOLLOW / REFUSE

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutFork` |
| **Story ID** | `storyZero` |
| **Display name** | The Fork |
| **Room type** | logic |
| **Critical path** | **yes** |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |

## Story & purpose

**Alignment choice** for the anthology meta-game. Does not retcon KoN or SoC —
this scout is not Kaefden or the Cataracta Druid.

| Choice | Command | `AnthologyAlignment` | Future unlock |
|---|---|---|---|
| Report to Silvarium | `REPORT` | `loyalist` | Good #1 — Oceandale warning |
| Follow Vashirr | `FOLLOW` | `agroman` | Bad #1 — *Walking with Vashirr* |
| Refuse both | `REFUSE` / `FLEE` | `neutral` | Elk Feast & neutral vignettes |

**Captured path:** all three choices. **Withdrew path:** REPORT and REFUSE only.

## State flags

| Flag | When |
|---|---|
| `alignment` | Set on choice |
| `forkResolved` | After valid command |
| `miraStatus` | `brokeAway` on FOLLOW |

## Player options

| Input | Outcome |
|---|---|
| `REPORT` | Mira relieved; loyalist exit seed |
| `FOLLOW` | Mira breaks away (captured path only) |
| `REFUSE` / `FLEE` | Both paths rejected |
| (after choice) `CONTINUE` | → `scoutCampExit` |

## Related

[Anthology roadmap](../../ANTHOLOGY_ROADMAP.md) · [Scout camp exit](scout-camp-exit.md)
