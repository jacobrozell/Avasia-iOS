# Avasia: King of Nacastrum — iOS Design Docs

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
| [`STORY.md`](STORY.md) | Story bible — lore, factions, plot arc, locations, NPCs, key scenes, tone, and motifs. The narrative source of truth. |
| [`ENGINE_SPEC.md`](ENGINE_SPEC.md) | Engine spec — Part A documents how the original works (state flags, parser, combat, puzzles, death); Part B defines the target Swift/SwiftUI architecture and a fidelity checklist. |
| [`WORLD_MAP.md`](WORLD_MAP.md) | Room graph — every area, its exits, gates, items, and the critical-path walkthrough. |

## Status

Design phase. No game code yet — these docs define what to build. Suggested next
steps are in `ENGINE_SPEC.md` §B.9 (build the Engine + Content layers first and
validate against the original with unit tests, then add UI).

## Faithfulness policy

Everything player-facing should match the original, **including its deliberate
jokes** (e.g. "It's already lit fam", "42", "Items don't just appear…"). The
only sanctioned deviations are structural/usability improvements that don't
change player-facing content: a state machine instead of recursion, typed state
instead of globals, checkpoint persistence, tap-to-advance text pacing, and a
surfaced death counter. See `ENGINE_SPEC.md` §B.8.
