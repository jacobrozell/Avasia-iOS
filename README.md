# Avasia (iOS)

Native iOS home for the **Avasia** text-adventure saga — a saga picker with
separate chapters, each with its own engine, save file, and story.

**Status:** Story slice / polish · v1.0.0 (1) · **Branch:** `main` · [Polish roadmap](docs/POLISH_ROADMAP.md)

| Chapter | Status | Engine |
|---|---|---|
| **King of Nacastrum** | Complete critical path + achievements | `AvasiaEngine` |
| **Blade of Courage** | Age-era saga playable end-to-end | `AvasiaSoCEngine` |

Faithful ports of the original games: [KoN](https://github.com/jacobrozell/avasia-kon)
and the Python prototype in [`Avasia-SoC/`](Avasia-SoC/).

---

## Quick start

```bash
swift test            # 52 engine tests — no Xcode project required
xcodegen generate     # create Avasia-iOS.xcodeproj
open Avasia-iOS.xcodeproj
```

Run the **Avasia-iOS** scheme on a simulator (⌘R).

**New here?** Read the **[Developer Guide](docs/DEVELOPERS.md)** for architecture,
workflows, and where to find everything.

---

## Repository layout

```
App/                        SwiftUI app (views, view models, assets)
Sources/AvasiaEngine/       King of Nacastrum — engine + content
Sources/AvasiaSoCEngine/    Blade of Courage — engine + content
Tests/                      XCTest suites for both engines
Avasia-SoC/                 Python reference prototype (SoC)
docs/                       Design docs, build guide, developer guide
Package.swift               SwiftPM — both engine libraries
project.yml                 XcodeGen spec (generates the Xcode project)
```

The Xcode project is **generated** from `project.yml` and is not checked in.
After changing targets, dependencies, or resources, run `xcodegen generate`.

---

## Documentation

### For developers

- **[Developer guide](docs/DEVELOPERS.md)** — onboarding, architecture, workflows
- **[Build & run](docs/BUILD.md)** — prerequisites, signing, CLI builds

### King of Nacastrum

- [Design docs index](docs/README.md)
- [Story bible](docs/STORY.md) · [Engine spec](docs/ENGINE_SPEC.md) · [World map](docs/WORLD_MAP.md)
- [Wireframes](docs/WIREFRAMES.md) · [Assets](docs/ASSETS.md) · [Achievements](docs/ACHIEVEMENTS.md)

### Blade of Courage

- [Sequel docs index](docs/sequel/README.md)
- [Story](docs/sequel/STORY.md) · [Engine spec](docs/sequel/ENGINE_SPEC.md) · [World map](docs/sequel/WORLD_MAP.md)
- [Port status](docs/sequel/STATUS.md) · [Roadmap](docs/sequel/ROADMAP.md)

### Series

- [Saga bible](docs/SAGA.md) — Age-era duology and planned future titles

---

## Goal

**Faithful first:** reproduce each original's content, pacing, and progression on
a clean, testable Swift/SwiftUI stack. Structural improvements (typed state,
checkpoints, tap-to-advance text) are allowed when they do not change what the
player sees. See the fidelity checklist in [`docs/ENGINE_SPEC.md`](docs/ENGINE_SPEC.md).

---

## Credits

Based on *Avasia: King of Nacastrum* and *Avasia: Blade of Courage* by Jacob
Rozell and contributors (Chase Pernatozzi, Devan Deloach, Joshua Rogers).
