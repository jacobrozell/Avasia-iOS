# Avasia: iOS

An iOS remake of **Avasia: King of Nacastrum** — a text-based fantasy adventure
in which an amnesiac mage must gather three lost spells, unlock the floating city
of Nacastrum, and reunite a people scattered by a usurper king.

This is a faithful port of the original game
([Avasia-KoN](https://github.com/jacobrozell/avasia-kon)). It contains design
docs, a pure-Swift game engine package, and a SwiftUI app scaffold with a
playable vertical slice.

## Documentation

See [`docs/`](docs/README.md):

- **[Story bible](docs/STORY.md)** — lore, plot, world, characters, tone.
- **[Engine spec](docs/ENGINE_SPEC.md)** — how the original works + the target
  iOS architecture.
- **[World map](docs/WORLD_MAP.md)** — areas, exits, gates, and the walkthrough.
- **[Wireframes](docs/WIREFRAMES.md)** — UI layouts for every screen.
- **[Build](docs/BUILD.md)** — how to build, test, and run.

## Code layout

- `Sources/AvasiaEngine/` — pure-Swift engine + content (`Package.swift`).
- `Tests/AvasiaEngineTests/` — engine unit tests (`swift test`).
- `App/` — SwiftUI app; the Xcode project is generated from `project.yml` via
  XcodeGen.

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
