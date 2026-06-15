# Build & Run

This repo is split into two pieces:

- **`AvasiaEngine`** — a pure-Swift, UI-free Swift Package (`Package.swift`) with
  the game logic, content, and unit tests. Builds and tests on any platform with
  a Swift toolchain.
- **`AvasiaKoN`** — the SwiftUI iOS app (`App/`), generated into an Xcode project
  from `project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen). The
  app depends on `AvasiaEngine`.

## Prerequisites

- macOS with **Xcode 15+** (iOS 16 deployment target).
- **XcodeGen**: `brew install xcodegen`.

## Test the engine (no Xcode project needed)

```bash
swift test            # runs Tests/AvasiaEngineTests
swift build           # builds the AvasiaEngine library
```

The engine is validated by scripting input sequences through `GameEngine`
(see `Tests/AvasiaEngineTests/EngineTests.swift`). Build out new rooms against
these tests before wiring UI.

## Generate and run the iOS app

```bash
xcodegen generate     # creates AvasiaKoN.xcodeproj from project.yml
open AvasiaKoN.xcodeproj
# select the AvasiaKoN scheme + an iOS Simulator, then Run (Cmd-R)
```

`AvasiaKoN.xcodeproj` is git-ignored — it is always regenerated from
`project.yml`, so edit the spec, not the project.

## Project layout

```
Package.swift              # AvasiaEngine package manifest
project.yml                # XcodeGen spec for the iOS app
Sources/AvasiaEngine/      # engine + content (pure Swift)
  Model/                   # GameState, Flag, RoomID, RuneSymbol, StyledText, Room
  Engine/                  # GameEngine, Parser
  Content/                 # World registry + Rooms/
  Persistence/             # SaveStore (JSON save + checkpoint)
Tests/AvasiaEngineTests/   # XCTest suites
App/                       # SwiftUI app
  AvasiaApp.swift          # @main + RootView router
  Views/                   # Title, Game, Settings, Credits, Theme
  ViewModels/              # GameViewModel (engine <-> SwiftUI bridge)
docs/                      # STORY, ENGINE_SPEC, WORLD_MAP, WIREFRAMES, BUILD
```

## Current status

**All regions are implemented** end-to-end: Oceandale, the mountain & cave (with
the fireball rune puzzle), the forest & great tree (blood seal / Stonebend), the
western-road gauntlet (ambush → spires → dream bridge), and the endgame
(teleporter → memory reveal → Nacastrum → Aylova → win). A scripted full
playthrough runs as a test (`ContentTests.testFullPlaythroughReachesWin`).

`StubRoom` now exists only as a safety fallback. Remaining work is polish:
restore more verbatim original text, add the optional fishing/flavor content not
on the critical path, and build out art/audio per `WIREFRAMES.md`.
