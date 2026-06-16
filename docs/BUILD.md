# Build & Run

> **New developers:** see [`DEVELOPERS.md`](DEVELOPERS.md) for onboarding,
> architecture, and day-to-day workflows.

This repo is split into three main pieces:

- **`AvasiaEngine`** — pure-Swift KoN engine + content (`Package.swift`).
- **`AvasiaSoCEngine`** — Blade of Courage engine (depends on `AvasiaEngine`).
- **`Avasia-iOS`** — the SwiftUI app (`App/`), generated from `project.yml` via
  [XcodeGen](https://github.com/yonaskolb/XcodeGen). Bundle ID:
  `com.jacobrozell.avasia-ios`.

## Prerequisites

- macOS with **Xcode 15+** (iOS 16 deployment target).
- **XcodeGen**: `brew install xcodegen`.

## Test the engine (no Xcode project needed)

```bash
swift test                              # all engine tests (KoN + SoC + anthology)
swift test --filter AvasiaEngineTests   # King of Nacastrum only
swift test --filter AvasiaSoCEngineTests
swift test --filter AvasiaAnthologyEngineTests
swift build                             # builds both engine libraries
```

Engines are validated by scripting input sequences through `GameEngine` and
`SoCGameEngine` (see `Tests/AvasiaEngineTests/` and
`Tests/AvasiaSoCEngineTests/`). Build out new rooms against these tests before
wiring UI.

## Generate and run the iOS app

```bash
xcodegen generate     # creates Avasia-iOS.xcodeproj from project.yml
open Avasia-iOS.xcodeproj
# select the Avasia-iOS scheme + an iOS Simulator or device, then Run (Cmd-R)
```

`Avasia-iOS.xcodeproj` is git-ignored — it is always regenerated from
`project.yml`, so edit the spec, not the project.

### Run anthology tests from Xcode

The `Avasia-iOS` scheme includes **`AvasiaAnthologyEngineTests`** (Story #0 paths,
FP economy, tier-two unlocks). Cmd-U in Xcode, or:

```bash
xcodegen generate
xcodebuild -project Avasia-iOS.xcodeproj -scheme Avasia-iOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

SwiftPM remains the fastest loop for engine-only work (`swift test --filter AvasiaAnthologyEngineTests`).

### Code signing (real device)

1. Open **Xcode → Settings → Accounts** and sign in with the Apple ID that owns
   team `QMQUNRJSLH` (or your own team).
2. Copy `Config/Signing.xcconfig.example` → `Config/Signing.xcconfig` if needed
   and set `DEVELOPMENT_TEAM` to your team ID.
3. Regenerate: `xcodegen generate`, then build from Xcode or CLI.

CLI device builds need `-allowProvisioningUpdates` so Xcode can create the
development provisioning profile for `com.jacobrozell.avasia-ios`:

```bash
xcodebuild -project Avasia-iOS.xcodeproj -scheme Avasia-iOS \
  -destination 'id=YOUR_DEVICE_ID' -configuration Debug \
  -allowProvisioningUpdates build
```

Simulator (no signing):

```bash
xcodegen generate
xcodebuild -project Avasia-iOS.xcodeproj -scheme Avasia-iOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Project layout

```
Package.swift                # SwiftPM — AvasiaEngine + AvasiaSoCEngine
project.yml                  # XcodeGen spec for the iOS app
Config/Signing.xcconfig      # DEVELOPMENT_TEAM for device signing
Sources/AvasiaEngine/        # KoN engine + content
Sources/AvasiaSoCEngine/     # SoC engine + content
Tests/AvasiaEngineTests/     # KoN XCTest suites
Tests/AvasiaSoCEngineTests/  # SoC XCTest suites (incl. critical-path E2E)
App/                         # SwiftUI app
  AvasiaApp.swift            # @main + RootView router
  Views/                     # Title, Game, Settings, Credits, Theme
  ViewModels/                # GameViewModel (engine <-> SwiftUI bridge)
docs/                        # DEVELOPERS, STORY, ENGINE_SPEC, WORLD_MAP, BUILD
Avasia-SoC/                  # Python SoC prototype (reference)
```

## Current status

### King of Nacastrum

**All regions are implemented** end-to-end: Oceandale through the Aylova ending.
A scripted full playthrough runs as a test
(`ContentTests.testFullPlaythroughReachesWin`). Remaining work is polish: more
verbatim text, optional off-path content, and art/audio per `WIREFRAMES.md`.

### Blade of Courage

The Age-era critical path is **playable end-to-end** on iOS. See
[`sequel/STATUS.md`](sequel/STATUS.md) for the living checklist and
`SoCCriticalPathTests` for automated coverage.

### Tests

`swift test` runs **52** engine tests across both packages (as of 2026-06).
