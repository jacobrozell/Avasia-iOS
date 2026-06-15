# Avasia: iOS

Monorepo for the **Avasia** saga on Apple platforms. The app opens to a **saga
picker** — each chapter is a separate game with its own save file.

## Avasia: King of Nacastrum (Game 1)

An iOS remake of **Avasia: King of Nacastrum** — a text-based fantasy adventure
in which an amnesiac mage must gather three lost spells, unlock the floating city
of Nacastrum, and reunite a people scattered by a usurper king.

This is a faithful port of the original game
([Avasia-KoN](https://github.com/jacobrozell/avasia-kon)). It contains design
docs, a pure-Swift game engine package, and a SwiftUI app scaffold. All regions
are implemented — the full critical path from the beach to the ending is playable
and covered by an end-to-end test.

## Avasia: Sword of Courage (Game 2)

The original Python prototype is in [`Avasia-SoC/`](Avasia-SoC/) (source-faithful,
stops at the throne-room stub). Select it from the **saga home screen** in the app.
Swift engine: `Sources/AvasiaSoCEngine/`. Docs: [`docs/sequel/`](docs/sequel/README.md).

## Documentation

### King of Nacastrum — see [`docs/`](docs/README.md)

- **[Story bible](docs/STORY.md)** — lore, plot, world, characters, tone.
- **[Engine spec](docs/ENGINE_SPEC.md)** — how the original works + the target
  iOS architecture.
- **[World map](docs/WORLD_MAP.md)** — areas, exits, gates, and the walkthrough.
- **[Wireframes](docs/WIREFRAMES.md)** — UI layouts for every screen.
- **[Build](docs/BUILD.md)** — how to build, test, and run.

### Sword of Courage (sequel) — see [`docs/sequel/`](docs/sequel/README.md)

- **[Saga bible](docs/SAGA.md)** — Age-era text duology; game 3 is first 2D title.
- **[Story bible](docs/sequel/STORY.md)** — timeline, Druid protagonist, war arc.
- **[Engine spec](docs/sequel/ENGINE_SPEC.md)** — Python prototype + iOS target.
- **[World map](docs/sequel/WORLD_MAP.md)** — Cataracta and Nacastrum castle graph.
- **[Roadmap](docs/sequel/ROADMAP.md)** — phased plan to finish and port.

## Code layout

- `Sources/AvasiaEngine/` — pure-Swift engine + KoN content (`Package.swift`).
- `Tests/AvasiaEngineTests/` — engine unit tests (`swift test`).
- `App/` — SwiftUI app; the Xcode project is generated from `project.yml` via
  XcodeGen.
- `Sources/AvasiaSoCEngine/` — Sword of Courage engine shell (port in progress).
- `Avasia-SoC/` — Python reference (original prototype, `python3 game.py`).

Quick start:

```bash
swift test            # run engine tests
xcodegen generate     # create AvasiaKoN.xcodeproj
open AvasiaKoN.xcodeproj
```

## Goal

Faithful first: reproduce the original's content, pacing, and progression
exactly, on a clean, testable Swift/SwiftUI engine. See the fidelity checklist in
`docs/ENGINE_SPEC.md` §B.8.

## Credits

Based on the original *Avasia: King of Nacastrum* by Jacob Rozell and
contributors (Chase Pernatozzi, Devan Deloach, Joshua Rogers).
