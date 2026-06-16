# Saga Meta Progression — Chronicler (Design Spec)

> **Status:** **1.0.0 MVP** scoped for ship · post-1.0 growth path documented below  
> **Goal:** a **cross-game, cross-run** profile that rewards repeat play without
> changing combat balance or breaking narrative fidelity on first runs.  
> **Related:** [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) · [`SAGA.md`](SAGA.md) ·
> [`FORESHADOWING.md`](FORESHADOWING.md) · [`GameEvent`](../../Sources/AvasiaEngine/Model/GameEvent.swift)

---

## 1. Problem statement

Players who finish KoN five times and SoC twice have no persistent signal of that
investment beyond per-game achievements (KoN only today) and save slots. Repeat
play is motivated mainly by secrets and muscle memory — not by a **saga-level**
identity.

**Chronicler** is the answer: one ledger, one rank, room to grow.

---

## 2. Design pillars

| Pillar | Rule |
|---|---|
| **Shell first** | 1.0.0 ships **tracking + UI**; rank gates and gameplay changes land later. |
| **Unlocks, not power** | Future rank rewards gate **content and modes** — not combat stats. |
| **Decisions > speedruns** | Rare choices and off-path content beat optimal replays (full tuning post-1.0). |
| **Saga-wide, mode-weighted** | One XP pool; each `AvasiaProduct` contributes with its own event vocabulary. |
| **Achievement Claim** | Each achievement unlocks once; player **claims** for one-time XP (§6.4). |
| **Transparent ledger** | Every gain (and modifier) is visible in the Chronicler's Ledger. |
| **Fidelity on first run** | 1.0.0 does **not** cap checkpoint deaths; lives are a future comfort layer. |

---

## 3. Player fantasy — Chronicler Rank

The saga-wide meta layer is the **Chronicler's Ledger**: you have walked these eras
many times and begun to see the pattern beneath amnesia, war, and scout patrols.

- Hub: **Chronicler · Rank 10**
- Detail sheet: **The Chronicler's Ledger**
- Light lore tie-in: broadsheets and oral history ([`SAGA.md`](SAGA.md) survivor's
  legend) — earned by the *player*, not an in-world character level.

**Sub-titles** (display band on integer rank):

| Rank | Sub-title |
|---:|---|
| 1–3 | Stranger |
| 4–6 | Traveler |
| 7–9 | Witness |
| 10–14 | Chronicler |
| 15+ | Keeper of the Pattern |

**Naming elsewhere:** SoC status strip stays **Quest Level** (`playerLevel`);
hub/meta is always **Chronicler Rank** — never plain “Level” alone.

---

## 4. Release scope

### 4.1 Ships in **1.0.0** (MVP)

| Area | In scope |
|---|---|
| **Persistence** | `SagaProfile` + `saga_profile.json` (app-wide, not per save slot) |
| **XP tracking** | `SagaXPTracker` hooked from `GameViewModel` after each turn |
| **KoN events** | `GameEvent` stream: regions, choices, secrets, win, death XP (§6.6) |
| **SoC (minimal)** | Campaign **win** → completion XP; `runsStarted` / `completions` counters |
| **Anthology (minimal)** | Story **complete** → completion XP (existing completion flags) |
| **Achievements** | **Claim +N XP** on KoN achievements; backfill for existing unlocks |
| **Hub UI** | Chronicler rank + XP bar on `SagaTitleView`; completion counts per chapter |
| **Ledger UI** | `ChroniclerLedgerView` — lifetime log, this-run filter, by-product totals |
| **In-game** | Game menu: **This run: +N XP** (tap → run ledger) |
| **Toasts** | Optional +XP toast (Settings, default on) |
| **Settings** | Show XP toasts · auto-claim achievements · show this-run XP · reset Chronicler |
| **Unlock registry** | `ChroniclerUnlocks` struct — **all gates return open** in 1.0.0 |
| **Tests** | Pure tracker + rank curve + ledger append + claim-once |

**1.0.0 player promise:** “The saga remembers how much I've walked it, and I can
see exactly how I earned my rank.” No content blocked by rank yet.

### 4.2 Explicitly **not** in 1.0.0

| Area | Deferred | Why |
|---|---|---|
| Lives / sigil UI | §11 | Preserves unlimited checkpoint fidelity for newcomers |
| Rank-gated anthology | §13 | FP economy stands alone until tuned |
| Paladin class | §12 | Large content pass |
| Veteran abbreviated prose | §10 | Room dialogue work |
| Timeline veteran footnotes | §10 | Copy pass on `SagaTimelineCatalog` |
| Route signature diminishing returns | §6.2 | Ship after baseline XP feels right |
| SoC full event adapter | §9 | Win + counters sufficient for launch |
| SoC achievement claims | — | No cross-run SoC achievement catalog yet |
| Rank-up celebration on hub | — | Optional polish; ledger rank change is enough for MVP |
| Chronicle export | §10 | Cosmetic |

### 4.3 Post-1.0 roadmap

| Target | Focus |
|---|---|
| **1.1** | SoC event adapter (choices, codex, milestones) · route signature modifiers · death overlay +XP line |
| **1.2** | Rank-gated anthology tiers (rank **or** milestone) · timeline footnotes |
| **1.3** | Lives system (§11) · extra lives by rank · NG+ comfort |
| **1.4** | Veteran prose abbreviations · cosmetic titles |
| **2.0** | **Paladin** class (§12) · throne/combat/courtyard content pass |

Exact version numbers are flexible; **order** matters more than labels.

---

## 5. Runs & counters

| Event | `runsStarted` | Chronicler XP |
|---|---|---|
| New game (any product) | +1 | small flat grant once per `runID` (optional in 1.0.0) |
| Continue | — | — |
| Win | — | completion grant (§6.1) |
| Death | — | +3 per death, max 3 grants/run (§6.6) — **no gameplay change** |
| Abandon mid-save | — | none |

**Hub display:**

```text
Chronicler · Rank 4  ———●———  620 / 900 XP
KoN completed 2×  ·  SoC completed 0×  ·  Stories 0×
```

`runsStarted` vs `completions` stay separate.

---

## 6. XP economy

```text
rank = floor(sqrt(sagaXP / 100)) + 1
```

| sagaXP | Rank |
|---:|---:|
| 0 | 1 |
| 900 | 4 |
| 2,500 | 6 |
| 10,000 | 11 |

Constants live in `ChroniclerRank.swift` (tunable without prose changes).

### 6.1 MVP XP sources (1.0.0)

| Source | XP (draft) | Notes |
|---|---:|---|
| KoN win | 500 | +50 clean run (0 deaths) |
| SoC win | 450 | |
| Anthology story complete | 120–450 | by tier (§13.2 table) |
| KoN `GameEvent` beats | 15–120 | per §9 KoN table |
| KoN death (≤3/run) | 3 each | ledger only; checkpoint unchanged |
| Achievement claim | 50–200 | per achievement, once |

### 6.2 Post-1.0: route modifiers

At run end, hash major flags → `runSignature`. Repeat signatures get ×0.5 / ×0.25;
new paths get ×1.25 Pathfinder. Shown as `modifierNote` in ledger.

### 6.3 Ledger entry

```swift
struct SagaXPEntry: Codable, Identifiable {
    var id: UUID
    var date: Date
    var product: AvasiaProduct?
    var runID: UUID?
    var label: String
    var amount: Int
    var modifierNote: String?
    var category: SagaXPCategory
}

enum SagaXPCategory: String, Codable {
    case exploration, choice, secret, milestone, completion
    case death, achievementClaim, runBonus, migration
}
```

Cap ledger at **500** entries (drop oldest); totals in `sagaXP` are authoritative.

### 6.4 Achievement Claim (1.0.0)

1. Achievement unlocks → existing toast.
2. Achievements screen shows **Claim +N XP** (or Settings → auto-claim).
3. Claim once → `achievementXPClaimed` + ledger line.

Migration: on first launch, already-unlocked KoN achievements appear claimable.

### 6.5 UI copy

```text
This run: +186 XP                    [game menu, tappable]

Chronicler's Ledger
  Rank 4 · Traveler · 620 XP
  ─────────────────────────
  +80   Gate guard schism speech
  +3    Death — chasm (1/3)
  +500  King of Nacastrum — victory
```

### 6.6 Death XP (1.0.0)

| Rule | Value |
|---|---|
| Per death | +3 Chronicler XP |
| Grants per run | 3 max |
| Gameplay | **Unchanged** — checkpoint always available |

Post-1.0 lives (§11) add sigil UI; death XP cap stays at 3 grants regardless of
bonus lives.

---

## 7. Architecture

```
Room / Engine turn
       │
       ▼
  GameEvent stream  ──► AchievementTracker (KoN)
       │
       ▼
  SagaXPTracker.apply(events, context, &SagaProfile)
       │
       ▼
  SagaProfileStore  →  Application Support/Avasia/saga_profile.json
```

```swift
struct SagaProfile: Codable {
    var sagaXP: Int = 0
    var runsStarted: [AvasiaProduct: Int] = [:]
    var completions: [AvasiaProduct: Int] = [:]
    var lifetimeEvents: Set<String> = []
    var achievementXPClaimed: Set<String> = []
    var ledger: [SagaXPEntry] = []
    var currentRunID: UUID?
    var currentRunXP: Int = 0
    var deathXPGrantsThisRun: Int = 0      // cap 3
    // Post-1.0:
    // var runSignatures: [String] = []
}
```

| System | 1.0.0 behavior |
|---|---|
| Achievements | Claim grants XP; same events can feed tracker |
| SoC quest level | Independent per-save; no merge |
| Anthology FP | Independent; no rank gate |
| `GameState` | Never stores Chronicler XP |
| `ChroniclerUnlocks` | All `true` until 1.2+ |

### 7.1 Suggested module layout (1.0.0)

```
Sources/AvasiaEngine/
  Model/
    SagaProfile.swift
    ChroniclerRank.swift          // rank(from:), subtitle, xpToNext
  Systems/
    SagaXPTracker.swift
    ChroniclerUnlocks.swift       // gates stubbed open
  Persistence/
    SagaProfileStore.swift

App/
  Views/
    ChroniclerLedgerView.swift
    SagaTitleView.swift           // rank strip
    AchievementsView.swift        // Claim button
  ViewModels/
    GameViewModel.swift           // hook + run lifecycle
  Settings/
    AppSettings.swift             // chronicler toggles

Tests/AvasiaEngineTests/
  ChroniclerTests.swift
```

---

## 8. UI surfaces (1.0.0)

### Saga hub

- Chronicler rank + progress bar (tappable → Ledger).
- Per-chapter completion count on `ChapterCard`.

### In-game menu

- **This run: +N XP** → filtered ledger.

### Chronicler's Ledger

| Section | MVP |
|---|---|
| Summary | Rank, sub-title, XP, progress to next |
| This run | Current `runID` entries |
| By product | KoN / SoC / Stories subtotals |
| Claims pending | Unclaimed achievement XP |
| All entries | Chronological list |

### Settings

| Key | Default |
|---|---|
| `chronicler.showXPToasts` | on |
| `chronicler.autoClaimAchievements` | off |
| `chronicler.showThisRunXP` | on |
| Reset Chronicler progress | confirm dialog |

### Distinct from SoC level-up

SoC `pendingLevelUp` overlay stays **in-run quest level**. Chronicler rank changes
surface on **hub return** or ledger (optional subtle toast in 1.1).

---

## 9. Event mapping

### 9.1 KoN — 1.0.0 (via `GameEvent`)

| Signal | Category | XP | Lifetime cap |
|---|---|---:|---|
| `enteredRegion` (new in run) | exploration | 25 | per region/run |
| `heardGateGuardLore` | choice | 60 | per run |
| `didBeachYoga`, `heard42`, etc. | secret | 80 | per lifetime key |
| `gained` spell (first each run) | milestone | 40 | per spell/run |
| `won` | completion | 500 | per win |
| win + `deathCount == 0` | completion | +50 | per win |
| `died` | death | 3 | ≤3 grants/run |
| Achievement claim | achievementClaim | 50–200 | once per id |

### 9.2 SoC — 1.0.0 (minimal)

| Signal | XP |
|---|---:|
| Campaign win (`campaignComplete` or win room) | 450 |

### 9.3 Anthology — 1.0.0 (minimal)

| Signal | XP |
|---|---:|
| `storiesRewarded` / completion flag set | tier table §13.2 |

### 9.4 SoC — post-1.0 (full adapter)

`throneRecountStyle`, class pick, act phases, `SoCCodexEntry`, trophies, etc.

---

## 10. Future: rank-gated rewards (post-1.0)

> `ChroniclerUnlocks` implements these; **1.0.0 returns `true` for all.**

### 10.0 Three lanes

| Lane | Examples |
|---|---|
| **Comfort** | Extra lives, veteran prose |
| **Side content** | Anthology tiers, arena |
| **Identity** | Paladin, titles, keeper cosmetics |

### 10.1 Provisional unlock schedule *(tune in constants)*

| Rank | Unlock |
|---:|---|
| 1 | KoN, SoC (always) |
| 3 | Scout #0 *or* first KoN win |
| 5 | Anthology tier 1 · 4th life |
| 7 | Veteran abbreviated dialogue |
| 8 | Anthology tier 2 |
| 10 | Paladin (needs 1 SoC win) · 5th life |
| 11–18 | Higher anthology tiers · mirror stories · finales |
| 15 | Keeper cosmetics · 6th life (cap) |

Use **rank OR milestone** for early gates; **rank AND milestone** for Paladin and
tier-6 finales. See §13 for anthology dual-gate policy.

### 10.2 Other backlog

Timeline veteran footnotes · codex commentary · NG+ titles · chronicle export ·
achievement hint categories (no spoilers).

---

## 11. Future: lives system (post-1.3)

**Not in 1.0.0.** When shipped:

| Rank | Lives/run |
|---:|---:|
| 1–4 | 3 |
| 5–9 | 4 |
| 10–14 | 5 |
| 15+ | 6 (cap) |

- **First win per product:** unlimited checkpoints (learning mode), *or* lives only
  on NG+ — decide at implementation.
- 0 lives → no checkpoint, run over; partial Chronicler XP kept.
- Death XP cap stays **3 grants/run** regardless of life count.

---

## 12. Future: Paladin class (post-2.0)

SoC fourth class at courtyard pick — **new games only**, gate: **Rank ≥ 10** and
**≥ 1 SoC completion**.

| Aspect | Notes |
|---|---|
| Fantasy | Kaefden fused-army doctrine; chant-plate; ward gaps |
| Code | `DruidClass.paladin` + `SoCClassIngenuity` verbs |
| Balance | Tradeoffs vs Hunter/Guardian/Scout — not strictly better |
| Content | Throne recount branches, courtyard intro, Oceandale paladin beats, epilogue line |

**Estimate:** large content pass (20+ branch touchpoints). Do not block Chronicler
shell on this.

---

## 13. Future: anthology & rank (post-1.2)

### 13.1 Dual gate (when enabled)

Story playable when:

```text
chroniclerRank >= tierMinRank  OR  sagaMilestone met
AND  factionPoints >= fpCost     // existing anthology economy
```

Rank opens the saga door; FP paces inside.

### 13.2 Anthology completion XP (for tracker when stories complete)

| Tier | XP |
|---|---:|
| Scout (#0) | 120 |
| 1 | 150 |
| 2 | 200 |
| 3 | 275 |
| 4–5 | 350 |
| 6 finale | 450 |

---

## 14. 1.0.0 implementation checklist

### Engine

- [x] `SagaProfile`, `SagaXPEntry`, `ChroniclerRank`
- [x] `SagaProfileStore` (load/save/reset)
- [x] `SagaXPTracker.apply` + `recordWin` + `recordDeath` + `claimAchievement`
- [x] `ChroniclerUnlocks` (all open)
- [x] `ChroniclerTests` — rank curve, claim once, death cap, ledger cap

### App

- [x] `GameViewModel`: `beginRun` / `endRun` / per-turn hook (KoN)
- [x] SoC win detection → completion XP
- [x] Anthology completion → tier XP
- [x] Migration: backfill claimable achievements
- [x] `ChroniclerLedgerView`
- [x] `SagaTitleView` rank strip + completion counts
- [x] `AchievementsView` claim row
- [x] Game menu “This run” row
- [x] Optional XP toast (smaller than achievement toast)
- [x] `AppSettings` chronicler keys
- [x] Settings reset Chronicler + toggles

### Docs / polish

- [x] Cross-link from [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) (Claim XP)
- [ ] `WIREFRAMES.md` ledger row (optional)

---

## 15. Decisions log

| # | Topic | Decision |
|---|---|---|
| 1 | Naming | **Chronicler Rank** + Chronicler's Ledger |
| 2 | 1.0.0 scope | **Shell only** — track, display, claim; no gates, no lives |
| 3 | XP feedback | This run + ledger; Settings toggles |
| 4 | Death (1.0.0) | +3 XP, 3 grants/run; **checkpoint unchanged** |
| 5 | Achievements | Claim one-time XP; backfill on migrate |
| 6 | Unlocks | `ChroniclerUnlocks` stub; real gates post-1.2 |
| 7 | Lives | Post-1.3; extra lives by rank |
| 8 | Paladin | Post-2.0 content pass |
| 9 | Anthology rank | Post-1.2; FP stays; no double-lock at launch |

---

## 16. Success metrics

**1.0.0**

- First-time KoN player: rank visible, gameplay identical to today.
- Returning player: higher rank after multiple wins; ledger explains gains.
- Achievement claim feels like a bonus, not a chore.

**Long-term**

- Secret hunters outpace speedrun-only players at same completion count.
- Rank gates feel like earned depth, not arbitrary locks.
- Paladin / anthology unlocks drive repeat duology play.

---

## 17. Example — 1.0.0 player

> New player installs → Chronicler Rank 1. Plays KoN, dies twice (checkpoint as
> today) → ledger +6 death XP. Wins with gate TALK and yoga → +500 win, +exploration
> lines. Rank ~3. Claims five achievements → +420 XP. Rank 4.  
> Hub: **Traveler · Rank 4** — KoN 1×. SoC and Stories unchanged access.  
> No lives UI. No locked story cards. Room to grow into Paladin and anthology gates
> in later releases.
