# Developer Guide

Welcome to **Avasia** on iOS. This guide gets you from clone to a running app and
points you at the right docs and code paths for common work.

---

## What this repo is

A **monorepo** for the Avasia saga on Apple platforms:

| Game | Engine package | App product | Reference |
|---|---|---|---|
| **King of Nacastrum** (Game 1) | `Sources/AvasiaEngine/` | Saga picker → KoN | [Avasia-KoN](https://github.com/jacobrozell/avasia-kon) |
| **Blade of Courage** (Game 2) | `Sources/AvasiaSoCEngine/` | Saga picker → SoC | `Avasia-SoC/` (Python prototype) |

Both games share the same **SwiftUI shell** (`App/`) but have **separate engines,
saves, and content**. The app opens to a saga home screen; each chapter is its own
game with its own save file.

**Design principle:** faithfulness first. Player-facing text, pacing, parser quirks,
and progression should match the originals unless a doc explicitly allows a
structural improvement (checkpoints, typed state, tap-to-advance text). See
[`ENGINE_SPEC.md`](ENGINE_SPEC.md) §B.8 and [`README.md`](README.md).

---

## Prerequisites

- **macOS** with **Xcode 15+** (iOS 16 deployment target)
- **XcodeGen** — `brew install xcodegen`
- **Swift 5.9+** (ships with Xcode)

Optional: run the Python SoC prototype with `python3 game.py` from `Avasia-SoC/`.

---

## First-time setup

```bash
git clone <repo-url> Avasia-iOS && cd Avasia-iOS

swift test                    # engine + content tests (no Xcode project needed)
xcodegen generate             # creates Avasia-iOS.xcodeproj from project.yml
open Avasia-iOS.xcodeproj     # Run (⌘R) on a simulator
```

**Important:** `Avasia-iOS.xcodeproj` is generated and git-ignored. Edit
`project.yml` or `Package.swift`, then regenerate — never hand-edit the `.pbxproj`.

### Device builds

Copy `Config/Signing.xcconfig.example` → `Config/Signing.xcconfig`, set your
`DEVELOPMENT_TEAM`, regenerate with `xcodegen generate`, and sign in Xcode.
Details: [`BUILD.md`](BUILD.md).

---

## Architecture at a glance

```
App/                          SwiftUI — views, view models, assets, audio
  AvasiaApp.swift             @main, RootView screen router
  ViewModels/GameViewModel    Bridges KoN + SoC engines to UI
  Views/                      Title, Game, Settings, Achievements, …

Sources/AvasiaEngine/         KoN — pure Swift, UI-free, testable
  Engine/GameEngine.swift     Turn loop: parse → room handler → transition
  Content/Rooms/              One file (or group) per region
  Persistence/SaveStore.swift JSON save + checkpoint

Sources/AvasiaSoCEngine/      SoC — same pattern, depends on AvasiaEngine
  Engine/SoCGameEngine.swift
  Content/Rooms/              SoC*Room.swift per location
  Systems/                    Combat, journal, chapters, death catalog

Tests/                        XCTest — script inputs through engines
Package.swift                 SwiftPM manifest (both engine libraries)
project.yml                   XcodeGen spec for the iOS app target
```

**Data flow:** `GameViewModel` owns a `GameEngine` and `SoCGameEngine`. The UI
reads `transcript`, `input`, and screen state; player actions call `submit(_:)`
on the active engine. Engines never import SwiftUI.

---

## Where to work

| Task | Start here | Also read |
|---|---|---|
| KoN room / puzzle / flag | `Sources/AvasiaEngine/Content/Rooms/` | [`WORLD_MAP.md`](WORLD_MAP.md), [`ENGINE_SPEC.md`](ENGINE_SPEC.md) |
| SoC room / combat / quest | `Sources/AvasiaSoCEngine/Content/Rooms/` | [`sequel/WORLD_MAP.md`](sequel/WORLD_MAP.md), [`sequel/rooms/`](sequel/rooms/) |
| New SoC room (process) | [`sequel/ROOM_SPEC_STANDARD.md`](sequel/ROOM_SPEC_STANDARD.md) | Python source in `Avasia-SoC/`, [`sequel/CONTENT_MANIFEST.md`](sequel/CONTENT_MANIFEST.md) |
| UI / navigation / theme | `App/Views/`, `App/ViewModels/` | [`WIREFRAMES.md`](WIREFRAMES.md), [`UI_POLISH.md`](UI_POLISH.md) |
| Art / audio hooks | `App/Views/RegionArt.swift`, `App/Audio/` | [`ASSETS.md`](ASSETS.md) |
| Achievements (KoN) | `Sources/AvasiaEngine/Engine/AchievementTracker.swift` | [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) |
| Chronicler (saga meta) | `Sources/AvasiaEngine/Systems/SagaXPTracker.swift` | [`META_PROGRESSION.md`](META_PROGRESSION.md) |
| SoC trophies / journal | `Sources/AvasiaSoCEngine/Systems/` | [`sequel/STATUS.md`](sequel/STATUS.md) |
| Compare against original KoN | External repo | [Avasia-KoN](https://github.com/jacobrozell/avasia-kon) |
| Compare against SoC prototype | `Avasia-SoC/` | `python3 game.py` |

---

## Common workflows

### Run tests

```bash
swift test                              # all 52 engine tests
swift test --filter SoCCriticalPathTests
swift test --filter ContentTests
```

Build out engine behavior and cover it with tests **before** wiring UI changes.

### Add or change a KoN room

1. Read the room in [`WORLD_MAP.md`](WORLD_MAP.md) and the original `GameDriver.py`
   behavior in [`ENGINE_SPEC.md`](ENGINE_SPEC.md) Part A.
2. Add or edit a handler in `Sources/AvasiaEngine/Content/Rooms/`.
3. Register the room in `Sources/AvasiaEngine/Content/World.swift` if new.
4. Add a test in `Tests/AvasiaEngineTests/` that scripts inputs through
   `GameEngine.submit(_:)`.
5. Run `swift test`.

Rooms implement `RoomScript`: `describe`, `handle`, optional `parseMode` for
faithful per-room input normalization.

### Add or change a SoC room

1. Read the Python room in `Avasia-SoC/` and the room spec under
   [`docs/sequel/rooms/`](sequel/rooms/) (create one from
   [`ROOM_SPEC_STANDARD.md`](sequel/ROOM_SPEC_STANDARD.md) if missing).
2. Implement `SoCRoomScript` in `Sources/AvasiaSoCEngine/Content/Rooms/`.
3. Add the case to `SoCRoomID` and register in `SoCWorld.build()`.
4. Update [`sequel/CONTENT_MANIFEST.md`](sequel/CONTENT_MANIFEST.md) and the room
   spec's **iOS port** field.
5. Add or extend tests in `Tests/AvasiaSoCEngineTests/`.
6. Run `swift test --filter SoC`.

### Change the iOS app target

Edit `project.yml` (new source folders, resources, build settings), then:

```bash
xcodegen generate
```

### Regenerate after pulling

If `project.yml` or `Package.swift` changed:

```bash
xcodegen generate
swift test
```

---

## Conventions

- **Engines stay UI-free.** No `import SwiftUI` under `Sources/`.
- **Verbatim text** lives in room handlers or small string catalogs; preserve
  original jokes and parser quirks unless spec'd otherwise.
- **State is typed.** KoN uses `GameState` + `Flag`; SoC uses `SoCGameState` +
  dedicated fields — avoid ad-hoc globals.
- **Saves are per-product.** `AvasiaKoN/` vs `AvasiaSoC/` under Application
  Support (`AvasiaProduct.saveDirectoryName`).
- **Tests script the engine.** Prefer `engine.submit("go north")` over UI tests
  for gameplay logic.
- **Docs are source of truth** for narrative and room behavior; update docs when
  you add content.

---

## Documentation map

### Everyone

| Doc | Purpose |
|---|---|
| [`BUILD.md`](BUILD.md) | Build, test, sign, CLI `xcodebuild` |
| [`SAGA.md`](SAGA.md) | Series bible — duology + future titles |

### King of Nacastrum

| Doc | Purpose |
|---|---|
| [`STORY.md`](STORY.md) | Lore, plot, characters |
| [`ENGINE_SPEC.md`](ENGINE_SPEC.md) | Original behavior + Swift architecture |
| [`WORLD_MAP.md`](WORLD_MAP.md) | Room graph + walkthrough |
| [`WIREFRAMES.md`](WIREFRAMES.md) | UI layouts |
| [`ASSETS.md`](ASSETS.md) | Art & audio manifest |
| [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) | Achievement + death screen system |
| [`META_PROGRESSION.md`](META_PROGRESSION.md) | Chronicler saga meta rank (1.0.0 MVP + post-1.0 roadmap) |

### Blade of Courage

| Doc | Purpose |
|---|---|
| [`sequel/README.md`](sequel/README.md) | Sequel doc index |
| [`sequel/STORY.md`](sequel/STORY.md) | Story bible |
| [`sequel/ENGINE_SPEC.md`](sequel/ENGINE_SPEC.md) | Python + iOS architecture |
| [`sequel/WORLD_MAP.md`](sequel/WORLD_MAP.md) | Room graph |
| [`sequel/STATUS.md`](sequel/STATUS.md) | Living port checklist |
| [`sequel/ROADMAP.md`](sequel/ROADMAP.md) | Phased plan |

---

## Getting unstuck

| Problem | Fix |
|---|---|
| `Avasia-iOS.xcodeproj` missing | `xcodegen generate` |
| Scheme or target not found | Regenerate project; open `Avasia-iOS` scheme |
| Signing errors on device | `Config/Signing.xcconfig` + Xcode Accounts |
| Room not reached in test | Check `World.build()` / `SoCWorld.build()` registration |
| Parser behaves differently than Python | Check `parseMode` on the room; see ENGINE_SPEC §A.3 |
| UI not updating | `GameViewModel` is `@MainActor`; engine calls should go through it |

---

## Credits

Based on *Avasia: King of Nacastrum* and *Avasia: Blade of Courage* by Jacob
Rozell and contributors. See in-app **Credits** and the root [`README.md`](../README.md).
