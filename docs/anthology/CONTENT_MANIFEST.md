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

**Hub:** `storyHub` — story launchers + `PLAY ARENA` · `SHOP` · `LIST` · daily ring pass

**Arena:** `arenaPit` — 3 waves · 75 gold clear · 25 FP first clear · partial gold on death

**Shop:** `trainingShop` — Boots (40g) · Whetstone (60g) · Mail (80g) · Ring Pass (100g)

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
