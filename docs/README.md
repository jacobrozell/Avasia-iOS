# Avasia — Design Docs

This folder documents **Avasia: King of Nacastrum** (Game 1, iOS remake). The
unfinished sequel **Avasia: Sword of Courage** has its own doc set in
[`sequel/`](sequel/README.md).

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
| [`SAGA.md`](SAGA.md) | Series bible — Age-era duology (text), game 3 (2D), engine evolution. |
| [`STORY.md`](STORY.md) | Story bible — lore, factions, plot arc, locations, NPCs, key scenes, tone, and motifs. The narrative source of truth. |
| [`ENGINE_SPEC.md`](ENGINE_SPEC.md) | Engine spec — Part A documents how the original works (state flags, parser, combat, puzzles, death); Part B defines the target Swift/SwiftUI architecture and a fidelity checklist. |
| [`WORLD_MAP.md`](WORLD_MAP.md) | Room graph — every area, its exits, gates, items, and the critical-path walkthrough. |
| [`WIREFRAMES.md`](WIREFRAMES.md) | Low-fidelity UI layouts for every screen, mapped to the SwiftUI views. |
| [`ASSETS.md`](ASSETS.md) | Art & audio manifest — exact asset names per region and how the hooks/fallbacks work. |
| [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) | Achievement system + the flavored death screen: architecture, full catalog, and how to add more. |
| [`BUILD.md`](BUILD.md) | How to build/test the engine package and generate + run the iOS app. |

## Status

The `AvasiaEngine` Swift package (engine + content + tests) and the `AvasiaKoN`
SwiftUI app (generated from `project.yml`) are in place, and **all regions are
implemented** — the full critical path from the beach to the ending is playable
and covered by a scripted end-to-end test, with verbatim original text and
optional off-path content folded in. **Per-region art and audio hooks** are
wired (backgrounds, header illustrations, ambient loops, and SFX cues) and
no-op gracefully until assets are added — see `ASSETS.md`. A cross-run
**achievement system** (22 achievements) and a flavored **death screen** are
implemented — see `ACHIEVEMENTS.md`. See `BUILD.md` for status.

## Faithfulness policy

Everything player-facing should match the original, **including its deliberate
jokes** (e.g. "It's already lit fam", "42", "Items don't just appear…"). The
only sanctioned deviations are structural/usability improvements that don't
change player-facing content: a state machine instead of recursion, typed state
instead of globals, checkpoint persistence, tap-to-advance text pacing, and a
surfaced death counter. See `ENGINE_SPEC.md` §B.8.
