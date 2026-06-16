# Anthology Content Manifest

## Stories

| Story ID | Starting room | Complete flag | FP cost | FP reward | Alignment |
|---|---|---|---:|---:|---|
| `storyZero` | `patrolCamp` (via hub) | `storyZeroComplete` | 0 | 500 | sets fork |
| `goodOne` | `goodOneSilvarium` | `goodOneComplete` | 500 | 500 | loyalist |
| `badOne` | `badOneColumn` | `badOneComplete` | 500 | 500 | agroman |
| `elkFeast` | `elkSplitpath` | `elkFeastComplete` | 250 | 250 | neutral |
| `caveRecord` | `caveRecordTrail` | `caveRecordComplete` | 500 | 500 | neutral (after Elk) |
| `goodTwo` | `goodTwoSilvarium` | `goodTwoComplete` | 1,000 | 1,000 | loyalist |
| `badTwo` | `badTwoPeriphery` | `badTwoComplete` | 1,000 | 1,000 | agroman |
| `goodThree` | `goodThreeLanding` | `goodThreeComplete` | 2,500 | 2,500 | loyalist |
| `badThree` | `badThreeMarch` | `badThreeComplete` | 2,500 | 2,500 | agroman |
| `neutralThree` | `neutralThreeMarket` | `neutralThreeComplete` | 2,500 | 2,500 | neutral |
| `goodFour` | `goodFourMobilizationCamp` | `goodFourComplete` | 5,000 | 5,000 | loyalist |
| `badFour` | `badFourApproach` | `badFourComplete` | 5,000 | 5,000 | agroman |
| `neutralFour` | `neutralFourKaefdenRoad` | `neutralFourComplete` | 5,000 | 5,000 | neutral |
| `goodFive` | `goodFiveSilvarium` | `goodFiveComplete` | 10,000 | 10,000 | loyalist capstone |
| `badFive` | `badFiveCamp` | `badFiveComplete` | 10,000 | 10,000 | agroman capstone |
| `neutralFive` | `neutralFiveSplitpath` | `neutralFiveComplete` | 10,000 | 10,000 | neutral capstone |
| `goodSix` | `goodSixAccordHall` | `goodSixComplete` | 17,500 | 17,500 | loyalist finale |
| `badSix` | `badSixOccupiedHall` | `badSixComplete` | 17,500 | 17,500 | agroman finale |
| `neutralSix` | `neutralSixArchive` | `neutralSixComplete` | 17,500 | 17,500 | neutral finale |

**Hub:** `storyHub` — story launchers + `PLAY ARENA` · `SHOP` · `LIST` · daily ring pass

**Arena:** `arenaPit` — 3 waves · 75 gold clear · 25 FP first clear · partial gold on death

**Shop:** `trainingShop` — Boots (40g) · Whetstone (60g) · Mail (80g) · Ring Pass (100g)

## Playtime estimates

Rough targets for **current stub-tier prose** (as of tier 6). Revisit when rooms are expanded to full fiction length.

### Scope

| Scope | Stories | Rooms (story) | Turns | Prose | Play time |
|---|---|---:|---:|---|---|
| **One alignment path** | Scout + 6 | ~35–40 | ~45–55 | ~3.5k–5k words | **1.5–2.5 h** |
| **All three paths** | 19 unique | ~95 total¹ | ~130–150 | ~10k–15k words | **5–8 h** |

¹ Includes hub, arena, and shop rooms in the engine (~100 `AnthologyRoomID` values).

### Per-tier story size (typical)

| Tier | Rooms | Turns | Minutes |
|---|---:|---:|---:|
| Scout (#0) | 9 | ~12 | 15–20 |
| Tier 1 | 4–5 | 6–7 | 8–12 |
| Tier 2 | 4 | 5–6 | 6–10 |
| Tier 3 | 5–8 | 8–9 | 12–18 |
| Tier 4 | 4 | 5 | 6–10 |
| Tier 5 | 3 | 4 | 5–8 |
| Tier 6 | 6 | 7 | 10–15 |

Tier 6 is the longest individual story today (six-room arc with branch aftermath).

### FP pacing adds hub/arena time

Story rewards equal unlock costs, but **each tier costs more than the prior reward leaves on hand** (e.g. after Good #1 you hold 500 FP; Good #2 costs 1,000). Players bridge gaps with **ring passes** (daily hub grant, 100g shop purchase) rather than arena FP — arena grants 75 gold per clear and only **25 FP once** on first clear.

Expect **~5 ring passes** and **~8–15 arena runs** over a full path if grinding gold for passes. That pushes real play time toward the **high end** of the ranges above.

### Context vs Age-era games

Story Adventures is a **side anthology** (novella per path, short-novel if all paths). KoN and SoC remain the full Age-era text adventures and are substantially longer.

## Meta state

| Field | Purpose |
|---|---|
| `factionPoints` | Unlock currency |
| `alignment` | Set by Story #0 fork |
| `completedStories` | Set of finished story IDs |
| `storiesRewarded` | FP granted once per story (replay safe) |
| `anthologyGold` | Arena training currency |
| `arenaUpgrades` | Purchased shop gear (persists) |
| `arenaFirstClearDone` | One-time arena FP bonus |
| `ringPasses` | FP bypass tokens (daily + shop) |
| `ringPassLastGrantDay` | Calendar day of last free pass |
| `currentStory` | In-progress story, nil at hub |

## Room IDs — Story #0

| Swift ID | Region | Notes |
|---|---|---|
| `patrolCamp` | `forest` | Opening |
| `scoutRidge` | `mountain` | WITHDRAW or DOWN |
| `scoutWithdraw` | `mountain` | Optional retreat |
| `scoutSignal` | `mountain` | Optional green smoke |
| `scoutPicket` | `mountain` | Captured path |
| `vashirrParley` | `mountain` | Sermon phases |
| `scoutFork` | `mountain` | Alignment choice |
| `scoutCampExit` | `mountain` | Post-fork release |
| `scoutEpilogue` | `splitpath` | → hub |

## Phase flags

| Flag | Story | Room / use |
|---|---|---|
| `parleyPhase` | #0 | `vashirrParley` |
| `forkResolved` | #0 | `scoutFork` |
| `ridgeOutcome` | #0 | `captured` / `withdrew` — Good #1 debrief |
| `miraStatus` | #0 | `partner` / `brokeAway` — Good #1 / Bad #1 |
| `parleyHeardFullSermon` | #0 | Good #1 partial-truth debrief |
| `scoutSignalSent` | #0 | Good #1 urgent dispatch |
| `goodOnePierResolved` | Good #1 | `goodOnePier` |
| `badOneReconResolved` | Bad #1 | `badOneRecon` |
| `caveRecordArchiveResolved` | Cave Record | `caveRecordArchive` |
| `caveRecordCopiedArchive` | Cave Record | COPY vs LEAVE |

## Room IDs — Cave Record

| Swift ID | Region |
|---|---|
| `caveRecordTrail` | `mountain` |
| `caveRecordEntrance` | `mountain` |
| `caveRecordCavern` | `mountain` |
| `caveRecordArchive` | `mountain` |
| `caveRecordEpilogue` | `splitpath` |

## Alignment (`AnthologyAlignment`)

| Value | Set by | Unlocks |
|---|---|---|
| `none` | — | — |
| `loyalist` | Story #0 REPORT | Good #1 (500 FP) |
| `agroman` | Story #0 FOLLOW | Bad #1 (500 FP) |
| `neutral` | Story #0 REFUSE | Elk Feast (250 FP) |
