# Avasia Anthology — Roadmap (iteration from found notes)

> Future layer **above** the Age-era duology (KoN + SoC). Not in scope for current
> iOS ship — design target for post-duology or game-3-era live content.
>
> Sources: found author notes · [`LORE_ARCHIVE.md`](LORE_ARCHIVE.md) ·
> [`fiction/STORY_ZERO_SCOUT_PATROL.md`](fiction/STORY_ZERO_SCOUT_PATROL.md)

---

## 1. Vision

After players finish **Blade of Courage**, the app offers **Story Adventures** —
short text scenarios that explore other faces of Avasia (neutral daily life, bad
path with Vashirr, Sylvian elk feast, etc.) without rewriting the canonical duology.

**Engine:** Reuse `AvasiaEngine` parser + room graph; separate content package
(`AvasiaAnthologyContent`).

---

## 2. Progression (from found notes)

| Currency | Earned by | Spent on |
|---|---|---|
| **Gold** | Side stories, arena (future) | Potions, gear, **Ring Passes** |
| **Faction points (FP)** | Completing stories, alignment deeds | Unlock next story tier |
| **Ring Passes** | Gold shop | Excuse one "unclosed ring" per day (TBD mechanic) |

### Story tiers (draft)

| ID | FP cost | Alignment | Premise |
|---|---|---|---|
| **#0 Scout Patrol** | 0 (free intro) | Sets alignment | [`fiction/STORY_ZERO_SCOUT_PATROL.md`](fiction/STORY_ZERO_SCOUT_PATROL.md) |
| **Good #1** | 500 | Loyalist | Warn Oceandale garrison; aftermath of REPORT |
| **Good #2** | 1,000 | Loyalist | TBD |
| **Bad #1** | 500 | Agroman | *Walking with Vashirr* — march west, Many Hands indoctrination |
| **Bad #2** | 1,000 | Agroman | TBD |
| **Neutral** | varies | Any | Everyday stories — **mirror** good/bad versions (same beat, opposite faction) |

FP thresholds from found notes: 500 · 1,000 · 2,500 · 5,000 · 10,000 · 17,500 …

---

## 3. Modes (from found notes)

### 3.1 Story adventures (text)
Primary anthology delivery. 30–90 minute scenarios.

**Seed inventory:**

| Working title | Source | Alignment |
|---|---|---|
| Scout Patrol | Found notes + Story 0 spec | Fork |
| Elk Feast | Found notes — Cataracta hunting | Neutral |
| Cellious at the Gate | Fiction appendix | Neutral / Kaefden |
| Paladin Zero | VASHIRR.md workshop | Bad |

### 3.2 Arena mode (future)
Swift port of Java arena concept — home screen **Modes → Arena**:
- Attack enemies, buy gear, no main-story spoilers required.
- Could tie to gold sink; optional FP for ranked clears.

### 3.3 Follower table (future)
WoW-style mission table — followers on timed missions, loot.
Fits game-3 era "world gets more systematic" ([`SAGA.md`](SAGA.md) §4).

---

## 4. Relationship to Age-era games

```
Story #0 (alignment) ──► Good/Bad/Neutral #1…
         │
         │  parallel timeline, not replacement
         ▼
KoN (canonical mage) ──► SoC (canonical druid) ──► Game 3 (2D)
```

Players who only play the duology miss nothing critical. Anthology rewards lore
depth and Vashirr's POV.

---

## 5. Phased implementation

| Phase | Deliverable |
|---|---|
| **A — Docs** | Story #0 room specs ✅ · Good/Bad/Elk story specs ✅ · fiction series ✅ |
| **B — Shell** | App menu: KoN / SoC / **Short Stories** ✅ |
| **C — Story #0** | `AvasiaAnthologyEngine` — scout patrol → Vashirr fork ✅ |
| **D — FP economy** | Persist FP, unlock gates, alignment follow-ups ✅ |
| **E — Arena** | Training arena — 3 waves, gold, first-clear FP ✅ |
| **F — Shop & tier 3** | Gold shop upgrades ✅ · Good/Bad/Neutral #3 ✅ |
| **G — Ring passes** | Daily grant + gold purchase · FP bypass ✅ |
| **H — Tier 4** | Good/Bad/Neutral #4 at 5,000 FP ✅ (stub) |
| **I — Tier 5** | Alignment capstone stubs at 10,000 FP ✅ |
| **J — Tier 6 & paths** | Finale at 17,500 FP · path progress UI ✅ |

---

## 6. Decision log

| Date | Decision |
|---|---|
| 2026-06-15 | Story 0 does **not** retcon KoN/SoC openings |
| 2026-06-15 | Alignment fork lives in **anthology**, not Age-era game 3 text |
| 2026-06-15 | Coripa/Cordia draft excluded — not Avasia |
