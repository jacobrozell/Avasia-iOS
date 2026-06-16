# Avasia — Design Docs

This folder documents **Avasia: King of Nacastrum** (Game 1, iOS remake). The
sequel **Avasia: Blade of Courage** has its own doc set in
[`sequel/`](sequel/README.md).

**New to the codebase?** Start with the **[Developer Guide](DEVELOPERS.md)** —
setup, architecture, and common workflows. Build instructions are in
[`BUILD.md`](BUILD.md).

---

## King of Nacastrum

Design documentation for a faithful iOS remake of **Avasia: King of Nacastrum**,
the original text-based adventure (`Avasia-KoN/GameDriver.py`, by Jacob Rozell &
contributors, v. 4/3/17).

**Goal of this phase:** be as faithful to the original game as possible —
reproduce its story, content, pacing, parsing, and progression exactly, while
replacing the original's single-file recursive-function structure with a clean,
data-driven, testable engine suitable for iOS.

## Documents

| Doc | Purpose |
|---|---|
| [`DEVELOPERS.md`](DEVELOPERS.md) | **Onboarding** — setup, repo layout, workflows, doc map. |
| [`SAGA.md`](SAGA.md) | Series bible — **§0 sacred pillars** (holy canon), Age-era duology, Commodity Era, game 3 (2D). |
| [`FORESHADOWING.md`](FORESHADOWING.md) | **Saga payoff map** — KoN/SoC seeds for anchor law, Anula, flesh cults. |
| [`NARRATIVE_LOGIC.md`](NARRATIVE_LOGIC.md) | **Continuity tracker** — open plot holes, proposed canon, where to plant fixes. |
| [`LORE_ARCHIVE.md`](LORE_ARCHIVE.md) | **Found lore** — schism fable, Silvarium/Oceandale history, archived future systems. |
| [`ANTHOLOGY_ROADMAP.md`](ANTHOLOGY_ROADMAP.md) | **Future stories** — Story #0, faction points, arena, post-duology content. |
| [`anthology/`](anthology/README.md) | **Anthology room specs** — Story #0 rooms, follow-up story outlines, content manifest. |
| [`VASHIRR.md`](VASHIRR.md) | **Villain motivation** — Many Hands doctrine, beliefs, counter-reads, quote bank. |
| [`fiction/`](fiction/README.md) | **Author fiction specs** — character bible + short story anthology outline for the full saga. |
| [`STORY.md`](STORY.md) | Story bible — lore, factions, plot arc, locations, NPCs, key scenes, tone, and motifs. The narrative source of truth. |
| [`ENGINE_SPEC.md`](ENGINE_SPEC.md) | Engine spec — Part A documents how the original works (state flags, parser, combat, puzzles, death); Part B defines the target Swift/SwiftUI architecture and a fidelity checklist. |
| [`WORLD_MAP.md`](WORLD_MAP.md) | Room graph — every area, its exits, gates, items, and the critical-path walkthrough. |
| [`WALKTHROUGH.md`](WALKTHROUGH.md) | Player walkthrough — completion guide from the beach to the ending (original guide). |
| [`WIREFRAMES.md`](WIREFRAMES.md) | Low-fidelity UI layouts for every screen, mapped to the SwiftUI views. |
| [`UI_POLISH.md`](UI_POLISH.md) | Motion, haptics, and region-art rollout spec — detail for non-combat polish. |
| [`COMBAT_UI.md`](COMBAT_UI.md) | Combat & status-strip animation — HP bars, hit feedback, gold/XP cues. |
| [`POLISH_ROADMAP.md`](POLISH_ROADMAP.md) | **Living polish checklist** — what's shipped, what's next, priority order. |
| [`ASSETS.md`](ASSETS.md) | Art & audio manifest — exact asset names per region and how the hooks/fallbacks work. |
| [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) | Achievement system + the flavored death screen: architecture, full catalog, and how to add more. |
| [`META_PROGRESSION.md`](META_PROGRESSION.md) | **Chronicler** saga meta rank — 1.0.0 MVP scope, ledger, achievement claims, post-1.0 unlock roadmap (Paladin, lives, anthology gates). |
| [`BUILD.md`](BUILD.md) | How to build/test the engine package and generate + run the iOS app. |

## Status

The `AvasiaEngine` Swift package (engine + content + tests) and the `AvasiaKoN`
SwiftUI app (generated from `project.yml`) are in place, and **all regions are
implemented** — the full critical path from the beach to the ending is playable
and covered by a scripted end-to-end test, with verbatim original text and
optional off-path content folded in. **Per-region art and audio hooks** are
wired (backgrounds, header illustrations, ambient loops, and SFX cues) and
no-op gracefully until assets are added — see `ASSETS.md`. A cross-run
**achievement system** (35 achievements) and a flavored **death screen** are
implemented — see `ACHIEVEMENTS.md`. See `BUILD.md` for status.

## Faithfulness policy

Everything player-facing should match the original, **including its deliberate
jokes** (e.g. "It's already lit fam", "42", "Items don't just appear…"). The
only sanctioned deviations are structural/usability improvements that don't
change player-facing content: a state machine instead of recursion, typed state
instead of globals, checkpoint persistence, tap-to-advance text pacing, and a
surfaced death counter. See `ENGINE_SPEC.md` §B.8.
