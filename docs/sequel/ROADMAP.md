# Avasia: Sword of Courage — Roadmap

> Phased plan to finish the sequel and align it with the KoN iOS remake. Timelines
> are intentionally open — reorder phases based on what motivates you.

---

## Vision (north star)

**Avasia: Sword of Courage** is the second and **final text game** of the Age era:
a Druid soldier's story that shows Vashirr's war from the ground, destroys the
player's home, and fights the **full continental war** under **King Kaefden IV**
(the KoN protagonist). Game 3 is the first **2D** title in a new era. See
[`../SAGA.md`](../SAGA.md).

Success looks like:

1. A **complete Age-era finale**: enlistment → fall of Cataracta → audience with
   Kaefden IV → war campaign → **resolved ending** (Vashirr arc closed in text).
2. **Optional content** that rewards exploration (fishing, shops, hidden XP).
3. **Combat that earns its place** — varied encounters, not a grind (see
   `ENGINE_SPEC.md` §B.3).
4. Eventually, an **iOS release** sharing infrastructure with the KoN remake.

---

## Phase 0 — Preserve & stabilize (now)

**Goal:** Imported prototype is documented, runnable, and easy to iterate.

| Task | Status |
|---|---|
| Import `Avasia-SoC/` into monorepo | ✅ |
| Write sequel design docs (`docs/sequel/`) | ✅ |
| Add `game.py` entry point | ✅ |
| Fix `Enemy.get_luck()` bug | ✅ |
| Fix `Player.return_item` early-return bug | ✅ |
| Normalize command casing (`.upper()`) | ✅ |
| Wire `Cataracta_Garden` into map | ✅ |
| Throne room + war campaign + epilogue | ✅ |
| Block Cataracta after massacre | ✅ |

**Exit criteria:** `python3 game.py` playable start → throne room without crashes.

---

## Phase 1 — Story foundations ✅

**Goal:** Answer open continuity questions before writing new prose. **Complete**
(2026-06-15). See [`../SAGA.md`](../SAGA.md) and `STORY.md` §Act IV.

### 1.1 Royal structure — decided

- **Kaefden IV** = KoN protagonist (mage-king, six months into his reign).
- SoC PC is a Druid soldier; Kaefden IV is NPC / commander.

### 1.2 Act structure

| Act | Setting | Premise |
|---|---|---|
| I | Cataracta (peace) | Enlist, bond, optional quests |
| II | Cataracta (war) | Massacre, survivor's guilt |
| III | Nacastrum castle | Deliver warning to Kaefden IV |
| IV | War campaign | Full continental war — Aylova, fronts, Agroman territory |
| V? | Late war / coda | Optional Cataracta ruins revisit; Age-era epilogue |

### 1.3 Ending — decided

SoC **closes the Age-era text saga** — the war and Vashirr arc resolve here. Game 3
(2D) picks up in a later era with the world in a new status quo, not a text
cliffhanger.

---

## Phase 2 — Finish Python content

**Goal:** Complete the game in the original Python form (fast iteration).

### 2.1 Throne room & Act III

- Audience with king / council.
- Branching based on class? (scout delivers intel, guardian stands guard, etc.)
- Consequence of Cataracta's fall on faction morale.

### 2.2 Post-Cataracta world state

- Block pre-attack Cataracta rooms after Act II (*"destroy all paths"*).
- **Later:** optional **ruined Cataracta** revisit (emotional beat, not full city).

### 2.3 War campaign (Act IV)

- Aylova and coalition staging.
- Multiple fronts — not a single dungeon crawl.
- Encounters per `ENGINE_SPEC.md` §B.3 (variety over volume).
- Vashirr / Agromanian mage threat escalates.
- Planned geography in [`WORLD_MAP.md`](WORLD_MAP.md) §Planned.

### 2.4 Systems depth

- More trophies (align with achievements catalog style from KoN).
- Weapons and **class-flavored** combat options.
- Combat heal / item use — only where encounters warrant it.
- **No random encounter grind** — every fight is authored.

### 2.5 Polish pass

- Unify character name spellings.
- Replace `"Nascastrum"` → `Nacastrum`.
- Author better heal justification between courtyard combats.

**Exit criteria:** Playable beginning-to-end Python game with ending credits.

---

## Phase 3 — Parity with KoN docs

**Goal:** Sequel docs match KoN doc depth before any Swift port.

| Document | Action |
|---|---|
| `WIREFRAMES.md` | Combat UI, class select, trophy screen, war scenes |
| `ASSETS.md` | Cataracta pre/post art, Nacastrum castle, Vashirr portrait |
| `ACHIEVEMENTS.md` | Full trophy catalog with unlock conditions |
| `BUILD.md` | Python + future Xcode targets |

---

## Phase 4 — Swift engine integration

**Goal:** Port to iOS using KoN infrastructure.

### 4.1 Engine fork/extend

- Add `AvasiaSoCContent` + combat/XP modules to Swift package.
- Reuse parser, room graph, narrative pacing from `AvasiaEngine`.
- Scripted port of courtyard massacre as first milestone.

### 4.2 App shell

- Second Xcode scheme or unified app with game select?
- Reuse `Theme`, `LayoutMetrics`, `RegionArt` patterns.

### 4.3 Tests

- E2E test: housing → courtyard → portal → library → throne.
- Combat unit tests (initiative, hit rolls, death).

**Exit criteria:** SoC critical path runs in iOS Simulator with tests green.

---

## Phase 5 — Ship criteria (long-term)

- Full story implemented.
- Art/audio per `ASSETS.md` (or graceful fallbacks).
- Save/checkpoint system.
- App Store readiness (if desired): icons, privacy, TestFlight.

---

## Decision log

Record major forks here as you decide:

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-15 | Import Python prototype into `Avasia-SoC/` | Preserve learning-project reference in monorepo |
| 2026-06-15 | Cataracta falls in Act II; revisit ruins later | Matches courtyard script; optional late-game return |
| 2026-06-15 | Kaefden IV = KoN protagonist | Throne room + war leadership |
| 2026-06-15 | SoC = full war campaign | Act IV+, not messenger-only |
| 2026-06-15 | Age era = **2 text games**; game 3 = **first 2D** | See `docs/SAGA.md` |
| 2026-06-15 | Combat = varied authored encounters, not grind | See `ENGINE_SPEC.md` §B.3 |
| 2026-06-15 | Title: *Sword of Courage* (working) | Alternatives in `SAGA.md` §6 |
