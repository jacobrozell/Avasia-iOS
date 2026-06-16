# Firebase Analytics & Crashlytics — Implementation Spec

**Status:** Future work — not scheduled for current release (June 2026)  
**Audience:** iOS implementers, narrative/content leads (for event naming review), release owners  
**Scope:** Add Firebase **Analytics** and **Crashlytics** to the Avasia iOS app with **verbose, structured, no-PII telemetry** across all three products (KoN, SoC, Anthology), saga meta (Chronicler), and app shell.

**Related docs:** [`DEVELOPERS.md`](DEVELOPERS.md) · [`BUILD.md`](BUILD.md) · [`ENGINE_SPEC.md`](ENGINE_SPEC.md) · [`META_PROGRESSION.md`](META_PROGRESSION.md) · [`ACHIEVEMENTS.md`](ACHIEVEMENTS.md) · [`anthology/CONTENT_MANIFEST.md`](anthology/CONTENT_MANIFEST.md)

---

## Table of contents

1. [Goals & non-goals](#1-goals--non-goals)
2. [Current state](#2-current-state)
3. [Privacy & no-PII policy](#3-privacy--no-pii-policy)
4. [Architecture overview](#4-architecture-overview)
5. [Firebase project setup](#5-firebase-project-setup)
6. [SDK & build integration](#6-sdk--build-integration)
7. [Telemetry API design](#7-telemetry-api-design)
8. [Global context & user properties](#8-global-context--user-properties)
9. [Event catalog — app shell](#9-event-catalog--app-shell)
10. [Event catalog — King of Nacastrum](#10-event-catalog--king-of-nacastrum)
11. [Event catalog — Blade of Courage](#11-event-catalog--blade-of-courage)
12. [Event catalog — Short Stories (Anthology)](#12-event-catalog--short-stories-anthology)
13. [Event catalog — Chronicler & saga meta](#13-event-catalog--chronicler--saga-meta)
14. [Event catalog — achievements & trophies](#14-event-catalog--achievements--trophies)
15. [Event catalog — combat & presentation](#15-event-catalog--combat--presentation)
16. [Event catalog — persistence & errors](#16-event-catalog--persistence--errors)
17. [Event catalog — audio, haptics & accessibility](#17-event-catalog--audio-haptics--accessibility)
18. [Crashlytics integration](#18-crashlytics-integration)
19. [Integration map (files & hooks)](#19-integration-map-files--hooks)
20. [Phased rollout plan](#20-phased-rollout-plan)
21. [Testing & validation](#21-testing--validation)
22. [Dashboards & operational use](#22-dashboards--operational-use)
23. [Privacy policy & App Store](#23-privacy-policy--app-store)
24. [Open decisions](#24-open-decisions)
25. [Appendix A — full event index](#appendix-a--full-event-index)
26. [Appendix B — parameter reference](#appendix-b--parameter-reference)

---

## 1. Goals & non-goals

### Goals

| # | Goal | Success signal |
|---|------|----------------|
| G1 | **Crash visibility** — symbolicated stack traces, non-fatals for recoverable engine errors | Crash-free sessions > 99.5% after stabilization |
| G2 | **Funnel clarity** — where players start, quit, die, win, per product | KoN/SoC/Anthology completion rates visible in Firebase |
| G3 | **Content telemetry** — region/story/chapter reach without transcript text | Heatmaps of `region_enter`, `story_complete`, `soc_chapter` |
| G4 | **Meta progression** — Chronicler rank bands, achievement claims, ledger activity | Rank distribution + claim rates per achievement |
| G5 | **No PII** — zero player names, zero save payloads, zero command text | Privacy review passes; App Privacy labels accurate |
| G6 | **Engine-testable** — telemetry behind a protocol; engines stay UI-free | Unit tests use `NoOpTelemetry`; no Firebase in `AvasiaEngine` targets |
| G7 | **Opt-out respect** — honor a Settings toggle (default **on** for new installs) | Events suppressed when disabled; Crashlytics collection off |

### Non-goals (this phase)

- Firebase Remote Config feature flags (future; stub `TelemetryConfig` only)
- Firebase Performance Monitoring
- Firebase Auth / cloud saves
- Real-time multiplayer or server-side analytics
- Marketing attribution (SKAdNetwork / Google Ads)
- Logging raw parser input, room descriptions, or NPC dialogue
- Per-device persistent IDs exposed to developers (Firebase handles instance IDs)

---

## 2. Current state

### What exists today

| Area | State | Notes |
|------|-------|-------|
| Firebase SDK | **Not integrated** | No `GoogleService-Info.plist`, no SPM Firebase deps in `project.yml` |
| Analytics / logging | **None** | No `os.log`, `Logger`, or third-party SDK |
| Semantic game events | **Partial** | `GameEvent` enum in `AvasiaEngine` — already documented as "usable for analytics/telemetry later" |
| Achievement / trophy hooks | **Rich** | `AchievementTracker`, `SoCTrophy`, `SagaXPTracker` — natural emit points |
| Privacy copy | **Offline-first** | `PrivacyPolicyView` states no analytics SDK; **must update** before ship |
| App entry | `AvasiaApp.swift` | SwiftUI `@main`; no `AppDelegate` yet |
| Bundle ID | `com.jacobrozell.avasia-ios` | `project.yml` |
| Build | XcodeGen + SPM | Engine in `Package.swift`; app target in `project.yml` |

### Natural extension point

`GameEvent` is the KoN-side semantic event stream. The spec extends this pattern:

- **KoN:** map `GameEvent` → analytics in one place (`GameViewModel` or `SagaXPTracker.apply` companion)
- **SoC / Anthology:** parallel semantic enums or transition observers (room ID + phase enums already exist)
- **Shell:** screen transitions in `GameViewModel.screen` / `screenDidChange()`

---

## 3. Privacy & no-PII policy

### Hard rules (enforced in code review)

| Rule | Rationale |
|------|-----------|
| **Never log** player-typed strings | SoC name prompt, parser commands, journal notes |
| **Never log** `GameState` / save JSON | Contains implicit progress; use enum keys only |
| **Never log** `UUID` run IDs | Use opaque run sequence integers scoped to session, or omit |
| **Never log** device contacts, photos, location | App does not use these |
| **Never set** `Crashlytics.crashlytics().setUserID()` to a stable ID | Use anonymous session only |
| **Never include** IP-derived geo in custom params | Firebase may collect at platform level — disclose in privacy policy |
| **Hash nothing** that isn't already a stable enum `rawValue` | Prefer catalog IDs over hashes |

### Allowed dimensions

- Product: `kon` | `soc` | `stories`
- Screen: `saga`, `title`, `game`, `settings`, …
- Room / region / story IDs from engine enums (`RoomID`, `SoCRoomID`, `AnthologyStoryID`, `Region`)
- Death cause: `DeathCause.rawValue`
- Achievement / trophy: `Achievement.rawValue`, `SoCTrophy.rawValue`
- Chronicler: rank **band** (0–5), not exact XP
- Settings enums: `AppAppearance`, `TypewriterSpeed`, `TextDelay`, `CursorStyle` (booleans for sound/haptics)
- Combat: enemy **archetype** key (e.g. `soc_patrol`), not display name if player-chosen
- Counts: turn index, death count **bucket**, regions visited count
- Build: `app_version`, `build_number`, `platform` (iOS), `device_class` (phone/pad)
- Error codes: `save_load_failed`, `decode_error` — no file paths with user home dir

### SoC player name

SoC collects a name for in-fiction dialogue. **Do not log the name.** Log only `soc_name_set: true` when confirmed.

### Analytics collection toggle

Add `AppSettings.analyticsEnabled` (default `true`). When `false`:

- `Analytics.setAnalyticsCollectionEnabled(false)`
- `Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)`
- `AvasiaTelemetry` becomes no-op (still compiles)

Show in Settings under a new **Privacy** card with link to updated policy.

### GDPR / CCPA posture

- No account = no data subject access request workflow for gameplay content
- Provide support email for deletion requests (Firebase console per-app instance reset is manual)
- Document in privacy policy: Firebase Google processing, retention, opt-out

---

## 4. Architecture overview

```
┌─────────────────────────────────────────────────────────────────┐
│  App/ (SwiftUI)                                                 │
│  GameViewModel, SettingsView, OnboardingView, …                 │
│       │ screen / lifecycle / UI actions                         │
│       ▼                                                         │
│  App/Telemetry/AvasiaTelemetry.swift  ← façade (main actor)       │
│       │ implements TelemetryRecording protocol                  │
├───────┼─────────────────────────────────────────────────────────┤
│  App/Telemetry/FirebaseTelemetry.swift  (#if canImport Firebase)│
│       │ Analytics.logEvent + Crashlytics.log / setCustomValue   │
├───────┼─────────────────────────────────────────────────────────┤
│  App/Telemetry/NoOpTelemetry.swift  (tests, previews, opt-out)  │
└───────┴─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Sources/AvasiaEngine (+ SoC, Anthology)                      │
│  GameEngine, SagaXPTracker, AchievementTracker                  │
│       │ pure Swift — NO Firebase imports                        │
│       │ optional: TelemetrySink protocol injected in tests only │
└─────────────────────────────────────────────────────────────────┘
```

### Module placement

| Module | Firebase? | Role |
|--------|-----------|------|
| `AvasiaEngine` | **No** | Semantic events only (`GameEvent`) |
| `AvasiaSoCEngine` | **No** | Room/chapter enums |
| `AvasiaAnthologyEngine` | **No** | Story/alignment enums |
| `App/` | **Yes** | `AvasiaTelemetry`, Firebase wiring, `AppDelegate` |

### Initialization flow

1. `UIApplicationDelegateAdaptor` → `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
2. `FirebaseApp.configure()` if `AppSettings.analyticsEnabled`
3. Set default user properties (build, first-open cohort)
4. `AvasiaTelemetry.shared.configure(backend: FirebaseTelemetry())`
5. Log `app_open` with `source: cold_start | warm_start`

### Threading

- All `AvasiaTelemetry` entry points: `@MainActor` (matches `GameViewModel`)
- Firebase SDK calls from main thread
- Crashlytics `log()` may be called from background if needed — wrap in `DispatchQueue.main.async` for consistency

---

## 5. Firebase project setup

### Prerequisites

- Apple Developer account with bundle ID `com.jacobrozell.avasia-ios`
- Firebase CLI via `npx -y firebase-tools@latest`
- Decision: **new project** vs existing (see [§24 Open decisions](#24-open-decisions))

### CLI workflow (preferred over Console download)

```bash
# 1. Auth & project
npx -y firebase-tools@latest login
npx -y firebase-tools@latest projects:create avasia-ios --display-name "Avasia"

# 2. Register iOS app
npx -y firebase-tools@latest apps:create IOS com.jacobrozell.avasia-ios --project avasia-ios

# 3. Fetch config (save to repo — see .gitignore note below)
npx -y firebase-tools@latest apps:sdkconfig IOS <IOS_APP_ID> --project avasia-ios \
  > App/GoogleService-Info.plist
```

### Console enablement

After first SDK run, enable in Firebase Console:

- **Analytics** — auto-enabled with Google Analytics property
- **Crashlytics** — enable for the iOS app (may require a test crash)

### Config file handling

- Add `App/GoogleService-Info.plist` to the Xcode target (via `project.yml` resources)
- **Not secret** but project-specific — commit to private repo is standard; use separate Firebase projects for Debug vs Release if desired
- Add `GoogleService-Info.plist` to Crashlytics run script `inputPaths`

### Environments

| Build | Firebase project | Notes |
|-------|------------------|-------|
| Debug (local) | `avasia-ios-dev` (recommended) | Avoid polluting production funnels |
| TestFlight / App Store | `avasia-ios` | Production dashboards |

Implement via duplicate plist + Xcode build configuration, or single project with `analytics_debug` user property.

---

## 6. SDK & build integration

### Swift Package dependencies

Add to `project.yml` under `packages:` (not `Package.swift` — keep engines Firebase-free):

```yaml
packages:
  Firebase:
    url: https://github.com/firebase/firebase-ios-sdk.git
    from: 11.0.0
```

Target dependencies:

```yaml
dependencies:
  - package: Firebase
    product: FirebaseAnalytics
  - package: Firebase
    product: FirebaseCrashlytics
```

`FirebaseCore` is pulled transitively.

### project.yml changes checklist

- [ ] Add Firebase SPM package
- [ ] Link `FirebaseAnalytics` + `FirebaseCrashlytics` to `Avasia-iOS` target
- [ ] Add `App/GoogleService-Info.plist` to resources
- [ ] Set `DEBUG_INFORMATION_FORMAT = dwarf-with-dsym` for Release
- [ ] Add Crashlytics run script build phase:

```bash
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
```

- [ ] Input files: `$(SRCROOT)/App/GoogleService-Info.plist`, dSYM paths per Firebase docs

### AppDelegate

Create `App/AppDelegate.swift`:

```swift
import UIKit
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if AppSettings.analyticsEnabled {
            FirebaseApp.configure()
        }
        return true
    }
}
```

Wire in `AvasiaApp.swift`:

```swift
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
```

### Version alignment

Log on each cold start:

- `app_version` ← `Bundle.main.infoDictionary["CFBundleShortVersionString"]`
- `build_number` ← `CFBundleVersion`
- Matches `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml` (currently 1.0.0 / 1)

---

## 7. Telemetry API design

### Protocol

```swift
@MainActor
protocol TelemetryRecording: Sendable {
    func log(_ event: TelemetryEvent)
    func setUserProperty(_ name: String, value: String?)
    func setCrashKey(_ key: String, value: String)
    func recordNonFatal(_ error: TelemetryError)
}
```

### Event struct

```swift
struct TelemetryEvent {
    let name: String           // snake_case, max 40 chars
    let parameters: [String: TelemetryValue]
}

enum TelemetryValue {
    case string(String)        // max 100 chars — truncate in backend
    case int(Int)             // Analytics accepts Int64
    case bool(Bool)
}
```

### Naming conventions

| Rule | Example |
|------|---------|
| `snake_case`, ≤ 40 characters | `kon_region_enter` |
| Prefix by domain | `kon_`, `soc_`, `story_`, `shell_`, `chronicler_` |
| Past tense for completed actions | `kon_died`, not `kon_die` |
| Pair start/complete where useful | `story_start` / `story_complete` |
| Avoid reserved prefixes | No `firebase_`, `google_`, `ga_` |

### Parameter conventions

| Param | Type | Example |
|-------|------|---------|
| `product` | string | `kon` |
| `room_id` | string | `mainCave` (enum rawValue) |
| `region_id` | string | `cave` |
| `story_id` | string | `good_one` |
| `cause` | string | `chasm` |
| `achievement_id` | string | `firstSteps` |
| `screen` | string | `achievements` |
| `turn_index` | int | 42 |
| `rank_band` | int | 3 |
| `success` | bool | true |
| `error_code` | string | `save_decode_failed` |

### Batching & volume

Firebase Analytics has event limits (500 distinct event names, 25 params per event, 100 char param values). This catalog is within limits but:

- **Do not** log every parser turn by default — use `kon_turn` only in verbose/debug mode OR sample 1/N turns
- **Do** log every region enter, death, win, story complete (low volume)
- **Debounce** repeated screen impressions (log `screen_view` on appear, not every SwiftUI body refresh)

### Debug mode

`#if DEBUG`: call `Analytics.setAnalyticsCollectionEnabled(true)` and optionally `-FIRAnalyticsDebugEnabled` launch arg for DebugView.

Add hidden Settings gesture (tap version 5×) → `shell_debug_telemetry_toast` — no separate UI per polish freeze.

---

## 8. Global context & user properties

Set once at configure, refresh on change:

| User property | Values | When |
|---------------|--------|------|
| `product_last_played` | `kon` / `soc` / `stories` | On `openProduct` |
| `chronicler_rank_band` | `0`…`6` | After XP grant |
| `onboarding_complete` | `true` / `false` | Onboarding finish |
| `appearance` | `system` / `light` / `dark` | Settings change |
| `text_pacing` | `on` / `off` / `tap` | Settings change |
| `typewriter_speed` | `slow` / `normal` / `fast` | Settings change |
| `sound_enabled` | `true` / `false` | Settings |
| `haptics_enabled` | `true` / `false` | Settings |
| `achievements_unlocked_bucket` | `0`, `1-5`, `6-10`, … `30+` | On achievement unlock |
| `stories_completed_count` | `0`…`19` | Anthology completion |

### Crashlytics custom keys (updated each session)

| Key | Example |
|-----|---------|
| `active_product` | `soc` |
| `active_screen` | `game` |
| `kon_room` | `fireballRoom` |
| `soc_room` | `varatroFalls` |
| `story_id` | `elk_feast` |
| `in_combat` | `true` |
| `app_version` | `1.0.0` |

---

## 9. Event catalog — app shell

### Lifecycle

| Event | Params | Emit when |
|-------|--------|-----------|
| `app_open` | `source`: `cold_start` \| `warm_start` | `onLaunch` |
| `app_background` | `session_seconds` | `scenePhase` → background |
| `splash_complete` | `duration_ms` | Splash dismiss (~1400ms) |

### Navigation / screens

| Event | Params | Emit when |
|-------|--------|-----------|
| `screen_view` | `screen`, `previous_screen`? | `GameViewModel.screen` changes |
| `onboarding_start` | — | First onboarding show |
| `onboarding_complete` | `skipped`: bool | `completeOnboarding()` |
| `onboarding_replay` | `from_screen` | `openOnboarding(from:)` |

**`screen` values:** `onboarding`, `saga`, `title`, `settings`, `game`, `credits`, `achievements`, `trophies`, `codex`, `timeline`, `privacy_policy`, `chronicler_ledger`

### Saga hub

| Event | Params | Emit when |
|-------|--------|-----------|
| `saga_product_select` | `product` | `openProduct(_:)` |
| `saga_timeline_open` | `from_screen` | `openTimeline` |
| `saga_chronicler_open` | `from_screen` | `openChroniclerLedger` |
| `saga_back` | — | `backToSaga()` |

### Title screen (per product)

| Event | Params | Emit when |
|-------|--------|-----------|
| `title_new_game` | `product` | New game tapped |
| `title_continue` | `product`, `has_save`: bool | Continue tapped |
| `title_continue_failed` | `product`, `error_code` | Save load failed → fresh start |
| `title_open_achievements` | `product` | KoN achievements |
| `title_open_trophies` | `product` | SoC trophies |
| `title_open_codex` | `product` | Codex |
| `title_open_settings` | `from_screen` | Settings |

### Settings & legal

| Event | Params | Emit when |
|-------|--------|-----------|
| `settings_change` | `key`, `value` | Any `AppSettings` write |
| `settings_reset_chronicler` | — | Chronicler reset |
| `privacy_policy_view` | — | Privacy screen appear |
| `support_link_tap` | `destination`: `bmc` \| `github` \| other | `AppLinks` taps |
| `analytics_opt_out` | `enabled`: bool | Analytics toggle |

**`settings_change` keys:** `appearance`, `sound`, `haptics`, `text_delay`, `typewriter_speed`, `cursor_style`, `chronicler_xp_toasts`, `chronicler_auto_claim`, `chronicler_this_run`

### Credits

| Event | Params | Emit when |
|-------|--------|-----------|
| `credits_view` | — | Credits appear |

---

## 10. Event catalog — King of Nacastrum

### Run lifecycle

| Event | Params | Emit when |
|-------|--------|-----------|
| `kon_run_start` | `load_error`: bool | `startNewGame` KoN branch |
| `kon_run_resume` | `room_id`, `region_id` | Continue from save |
| `kon_run_end` | `reason`: `win` \| `death` \| `menu` \| `reset` | Leaving game screen / win / death dismiss |
| `kon_turn` | `turn_index`, `room_id` | **Optional / sampled** — every 10th turn or debug only |
| `kon_command_class` | `verb_bucket` | Parser result class — **no raw text** |

**`verb_bucket` values:** `movement`, `take`, `use`, `cast`, `talk`, `inventory`, `meta`, `unknown` — derive from parser, not player string.

### World / exploration

| Event | Params | Emit when |
|-------|--------|-----------|
| `kon_region_enter` | `region_id`, `first_visit`: bool | `GameEvent.enteredRegion` |
| `kon_room_enter` | `room_id`, `region_id` | Room transition (move) |
| `kon_flag_gain` | `flag` | Spell/item `GameEvent.gained` — flag enum only |

### Narrative flavor (`GameEvent` mapping)

| Event | Params | Source `GameEvent` |
|-------|--------|-------------------|
| `kon_flavor` | `flavor_id` | See table below |

**`flavor_id` values:**

| flavor_id | GameEvent |
|-----------|-----------|
| `heard_42` | `.heard42` |
| `gold_fish` | `.caughtGoldFish` |
| `orange_fish` | `.tossedOrangeFish` |
| `beach_yoga` | `.didBeachYoga` |
| `no_idea` | `.admittedNoIdea` |
| `dream_bridge` | `.swamDreamBridge` |
| `gate_lore` | `.heardGateGuardLore` |
| `relit_lantern` | `.relitLanternAtPedestal` |
| `old_shoe` | `.caughtOldShoe` |
| `fishing_crab_survive` | `.survivedFishingCrab` |
| `proved_ears` | `.provedWithEars` |
| `trading_grief` | `.heardTradingPostGrief` |

### Death & win

| Event | Params | Emit when |
|-------|--------|-----------|
| `kon_died` | `cause`, `room_id`, `region_id`, `turn_index`, `death_count_lifetime` | Death overlay |
| `kon_death_dismiss` | `action`: `retry` \| `title` | Death screen button |
| `kon_won` | `clean_win`: bool, `turn_index` | `GameEvent.won` |
| `kon_win_celebration` | — | Win audio/haptic fired |

### Checkpoint / save

| Event | Params | Emit when |
|-------|--------|-----------|
| `kon_save` | `slot`: `autosave` \| `checkpoint` | Successful `SaveStore.save` |
| `kon_save_failed` | `slot`, `error_code` | Save throw |

---

## 11. Event catalog — Blade of Courage

### Run lifecycle

| Event | Params | Emit when |
|-------|--------|-----------|
| `soc_run_start` | `load_error`: bool | New game |
| `soc_run_resume` | `room_id`, `chapter_id` | Continue |
| `soc_name_set` | — | Name confirmed (**no name param**) |
| `soc_run_end` | `reason` | Exit / complete |

### Progression

| Event | Params | Emit when |
|-------|--------|-----------|
| `soc_room_enter` | `room_id`, `chapter_id` | Room transition |
| `soc_chapter_enter` | `chapter_id` | `SoCChapter` boundary crossed |
| `soc_level_up` | `level` | Player level increase |
| `soc_item_gain` | `item_id` | `SoCItem` acquired |
| `soc_class_select` | `class_id` | Class choice at throne (enum only) |

**`chapter_id`:** map from `SoCChapter` cases — `cataracta`, `nacastrum`, `war_front`, `age_epilogue`, etc.

### Combat

| Event | Params | Emit when |
|-------|--------|-----------|
| `soc_combat_start` | `enemy_id`, `room_id` | Combat begins |
| `soc_combat_end` | `enemy_id`, `outcome`: `win` \| `flee` \| `death` | Combat resolves |
| `soc_combat_turn` | `turn_index` | Optional sampled |

### Key story beats

| Event | Params | Emit when |
|-------|--------|-----------|
| `soc_trophy_unlock` | `trophy_id` | Trophy earned |
| `soc_throne_phase` | `phase` | `ThronePhase` transition |
| `soc_war_camp_phase` | `phase` | `WarCampPhase` |
| `soc_game_complete` | `blade_bearer`: bool | `gameComplete` flag |
| `soc_epilogue` | `phase` | Age epilogue milestones |

### Death

| Event | Params | Emit when |
|-------|--------|-----------|
| `soc_died` | `room_id`, `chapter_id`, `in_combat`: bool | SoC death |
| `soc_death_dismiss` | `action` | Retry / menu |

---

## 12. Event catalog — Short Stories (Anthology)

### Hub & economy

| Event | Params | Emit when |
|-------|--------|-----------|
| `story_hub_enter` | `faction_points`, `alignment` | Hub room describe |
| `story_picker_open` | `completed_count` | Story picker shown |
| `story_picker_select` | `story_id`, `fp_cost`, `affordable`: bool | Story chosen |
| `story_alignment_set` | `alignment` | `AnthologyAlignment` locked |
| `story_fp_gain` | `amount`, `source` | FP awarded |
| `story_fp_spend` | `amount`, `story_id` | Story purchase |

### Story playthrough

| Event | Params | Emit when |
|-------|--------|-----------|
| `story_start` | `story_id` | Launcher enters story |
| `story_room_enter` | `story_id`, `room_id` | Anthology room move |
| `story_phase` | `story_id`, `phase_key` | Story-specific phase enum change |
| `story_complete` | `story_id`, `alignment`, `turn_index` | Completion flag set |
| `story_abandon` | `story_id`, `room_id` | Return to hub mid-story |

**`phase_key` examples (Story #0):** `parley_arrival`, `parley_schism`, `ridge_captured`, `ridge_withdrew` — use enum `rawValue` only.

### Arena

| Event | Params | Emit when |
|-------|--------|-----------|
| `arena_enter` | — | `PLAY ARENA` |
| `arena_wave_start` | `wave` | Wave N begins |
| `arena_wave_clear` | `wave` | Wave cleared |
| `arena_end` | `outcome`: `clear` \| `death` \| `quit`, `waves_cleared`, `gold_earned` | Arena exit |
| `arena_first_clear` | — | First-ever arena clear (FP bonus) |

### Shop

| Event | Params | Emit when |
|-------|--------|-----------|
| `shop_enter` | — | Training shop |
| `shop_purchase` | `item_id`, `gold_spent`, `success`: bool | Buy gear |
| `shop_insufficient_gold` | `item_id` | Failed buy |

### Combat (arena / story)

| Event | Params | Emit when |
|-------|--------|-----------|
| `story_combat_start` | `story_id`?, `enemy_id` | Arena or story fight |
| `story_combat_end` | `outcome` | Same as soc pattern |

---

## 13. Event catalog — Chronicler & saga meta

| Event | Params | Emit when |
|-------|--------|-----------|
| `chronicler_run_begin` | `product` | `SagaXPTracker.beginRun` |
| `chronicler_xp_grant` | `product`, `category`, `amount`, `rank_band` | Ledger entry added |
| `chronicler_rank_up` | `new_rank` | Rank band increased |
| `chronicler_achievement_claim` | `achievement_id`, `xp` | Manual or auto claim |
| `chronicler_death_xp` | `grant_index` (1–3) | Death XP grant |
| `chronicler_ledger_view` | `rank_band`, `total_xp_bucket` | Ledger screen |
| `chronicler_reset` | — | Settings reset |

**`category`:** maps to `SagaXPEntry` category — `milestone`, `exploration`, `secret`, `completion`, `death`, `achievement`

**`total_xp_bucket`:** `0-99`, `100-499`, `500-999`, `1000+` — avoid exact XP in analytics

---

## 14. Event catalog — achievements & trophies

| Event | Params | Emit when |
|-------|--------|-----------|
| `achievement_unlock` | `achievement_id`, `secret`: bool | `AchievementTracker` unlock |
| `achievement_toast_show` | `achievement_id` | Toast presented |
| `achievement_view_list` | `unlocked_count` | Achievements screen |
| `trophy_unlock` | `trophy_id` | SoC trophy |
| `trophy_toast_show` | `trophy_id` | Trophy toast |
| `trophy_view_list` | `unlocked_count` | Trophies screen |

---

## 15. Event catalog — combat & presentation

UI-layer events (SoC + Anthology arena) — `GameViewModel` / `CombatTriggerPlanner`:

| Event | Params | Emit when |
|-------|--------|-----------|
| `combat_ui_lock` | `product`, `duration_ms` | Input locked for animation |
| `combat_hp_flash` | `target`: `player` \| `enemy` | Health bar flash |
| `combat_line_emphasis` | `emphasis`: `hit` \| `miss` \| `heal` \| … | Transcript emphasis |
| `combat_low_hp_vignette` | `product` | Low HP pulse started |
| `combat_gold_float` | `delta` | Gold +N animation |
| `gold_display_sync` | `product`, `new_total_bucket` | Gold count-up complete |

Keep `new_total_bucket` coarse (e.g. `0`, `1-50`, `51-200`, `201+`) to avoid fingerprinting play style.

---

## 16. Event catalog — persistence & errors

| Event | Params | Emit when |
|-------|--------|-----------|
| `save_write` | `product`, `slot` | Any successful save |
| `save_read` | `product`, `slot`, `found`: bool | Load attempt |
| `save_failed` | `product`, `slot`, `error_code` | Catch block on IO/decode |
| `saga_profile_load` | `found`: bool | `SagaProfileStore.load` |
| `saga_profile_save` | — | Profile persist |
| `achievement_persist` | `product` | Achievement state save |

**`error_code` enum:** `file_missing`, `decode_failed`, `encode_failed`, `permission_denied`, `unknown`

All persistence errors also call `recordNonFatal` for Crashlytics non-fatal issue grouping.

---

## 17. Event catalog — audio, haptics & accessibility

| Event | Params | Emit when |
|-------|--------|-----------|
| `audio_ambient_start` | `track_id` | `AudioManager.playAmbient` |
| `audio_sfx` | `cue_id` | Optional — high volume; **sample 1/5** or debug only |
| `haptic_fire` | `kind` | Optional sampled — `confirm`, `impact`, `warning` |
| `typewriter_skip` | `lines_skipped` | Tap-to-advance skip |
| `typewriter_complete` | `line_index`, `char_count_bucket` | Line finished pacing |
| `reduce_motion_active` | `active`: bool | On launch — `accessibilityReduceMotion` |

**Note:** `track_id` / `cue_id` use internal `SoundCue.rawValue` — not file paths.

---

## 18. Crashlytics integration

### Automatic crash reporting

- Enabled when analytics enabled
- dSYM upload via run script (§6)
- Verify with one **manual** test crash in dev, then remove test code

### Non-fatal errors (`recordNonFatal`)

| Domain | Examples |
|--------|----------|
| Save I/O | Decode failure, corrupt JSON |
| Engine invariant | Unexpected `TurnResult` state — should be rare |
| Audio | Missing asset fallback (if treated as error) |

Use structured `TelemetryError`:

```swift
struct TelemetryError: Error {
    let code: String
    let domain: String
    let context: [String: String]  // enum keys only
}
```

### Breadcrumb log stream

Call `Crashlytics.crashlytics().log()` on:

- Every `screen_view`
- Every `kon_room_enter` / `soc_room_enter` / `story_room_enter`
- Combat start/end
- Save failures

Limit log line length to 64 KB total per session (SDK manages); keep each line < 200 chars.

### Custom keys

Refresh on `GameViewModel` state change (§8). On crash, report shows last room/product.

### ANR / hangs

Not applicable on iOS same way as Android — skip.

---

## 19. Integration map (files & hooks)

### New files

| File | Purpose |
|------|---------|
| `App/AppDelegate.swift` | Firebase configure |
| `App/Telemetry/TelemetryRecording.swift` | Protocol + types |
| `App/Telemetry/TelemetryEvent.swift` | Event definitions / helpers |
| `App/Telemetry/AvasiaTelemetry.swift` | Façade singleton |
| `App/Telemetry/FirebaseTelemetry.swift` | Firebase backend |
| `App/Telemetry/NoOpTelemetry.swift` | Tests / opt-out |
| `App/GoogleService-Info.plist` | Firebase config (from CLI) |

### Modified files

| File | Changes |
|------|---------|
| `project.yml` | Firebase SPM, Crashlytics script, plist resource |
| `App/AvasiaApp.swift` | `UIApplicationDelegateAdaptor`, `scenePhase` background event |
| `App/Settings/AppSettings.swift` | `analyticsEnabled` key |
| `App/Views/SettingsView.swift` | Privacy card + analytics toggle |
| `App/Views/PrivacyPolicyView.swift` | Firebase disclosure |
| `App/ViewModels/GameViewModel.swift` | Primary instrumentation hub |
| `App/Audio/AudioManager.swift` | Optional sampled SFX events |
| `App/Haptics/HapticManager.swift` | Optional sampled haptic events |

### Engine files (no Firebase imports)

| File | Hook |
|------|------|
| `GameViewModel.submit` / KoN path | Map `GameEvent` → telemetry after `SagaXPTracker.apply` |
| `GameViewModel.submitStories` | Anthology completions, arena |
| `GameViewModel.submitSoc` | SoC transitions |
| `SagaXPTracker` | Consider callback or return type already has grants — log in VM |
| `SaveStore` / `SoCSaveStore` / `AnthologySaveStore` | Wrap save/load in VM, not store (keeps engines pure) |

### Single hub principle

**Prefer one instrumentation site:** `GameViewModel` observes engine outputs already. Avoid sprinkling `AvasiaTelemetry` in 50 room files.

Exception: `AppDelegate` lifecycle, `SettingsView` toggles.

---

## 20. Phased rollout plan

### Phase 0 — Foundation (1–2 days)

- [ ] Create Firebase project(s) + iOS app registration
- [ ] Add SPM deps, plist, AppDelegate, dSYM script
- [ ] Implement `TelemetryRecording` + `NoOpTelemetry`
- [ ] Implement `FirebaseTelemetry`
- [ ] `AppSettings.analyticsEnabled` + Settings UI
- [ ] Update privacy policy copy
- [ ] Verify test crash → Crashlytics dashboard
- [ ] Unit test: `NoOpTelemetry` receives events from façade

### Phase 1 — Shell & lifecycle (0.5 day)

- [ ] `app_open`, `screen_view`, saga/title navigation
- [ ] `settings_change`, `analytics_opt_out`
- [ ] User properties for appearance/sound/haptics

### Phase 2 — KoN core funnel (1 day)

- [ ] Run start/end, region enter, death, win
- [ ] `GameEvent` flavor mapping
- [ ] Achievement unlock events
- [ ] Save failure non-fatals

### Phase 3 — SoC (1 day)

- [ ] Room/chapter enter, combat start/end, death, win
- [ ] Trophy unlocks, throne phases
- [ ] `soc_name_set` without PII

### Phase 4 — Anthology (1 day)

- [ ] Hub, story start/complete, picker, FP economy
- [ ] Arena waves + shop purchases
- [ ] Alignment events

### Phase 5 — Chronicler & polish (0.5 day)

- [ ] XP grants, rank up, claims, ledger view
- [ ] Crashlytics custom keys fully wired
- [ ] Sampled combat/audio events (if desired)

### Phase 6 — Release hardening (0.5 day)

- [ ] App Store Privacy Nutrition Labels
- [ ] Debug vs Release project split (optional)
- [ ] Dashboard review with narrative lead
- [ ] Remove/disable `kon_turn` sampling in Release

**Total estimate:** ~5–6 dev days

---

## 21. Testing & validation

### Local debug

1. Add `-FIRAnalyticsDebugEnabled` to scheme launch arguments
2. Open Firebase Console → Analytics → DebugView
3. Walk through scripted path: onboarding → saga → KoN new game → die → title
4. Confirm events appear with expected params (no PII)

### Crashlytics

1. Dev build: `fatalError("telemetry_test")` once
2. Relaunch app (upload on next launch)
3. Confirm symbolicated stack in Console
4. Remove test crash

### Unit tests

```swift
final class TelemetryTests: XCTestCase {
    func testScreenViewLogs() {
        let backend = SpyTelemetry()
        let telemetry = AvasiaTelemetry(backend: backend)
        telemetry.logScreen("settings", previous: "title")
        XCTAssertEqual(backend.events.last?.name, "screen_view")
    }
}
```

Engine tests unchanged — no Firebase linkage.

### Pre-release checklist

- [ ] Analytics opt-out suppresses all events (verify DebugView empty)
- [ ] Privacy policy matches behavior
- [ ] No `print()` of player input in codebase with telemetry added
- [ ] Param values ≤ 100 chars
- [ ] Event names ≤ 40 chars
- [ ] SoC name not in any param
- [ ] dSYM upload succeeds on Archive build

### Manual playthrough script

Use existing polish checklist paths:

1. KoN: beach → first death → win run
2. SoC: name entry → Cataracta → one combat → save quit
3. Anthology: Story #0 → hub → arena 1 wave → shop
4. Chronicler: claim one achievement, open ledger
5. Settings: toggle analytics off → confirm no new DebugView events

---

## 22. Dashboards & operational use

### Recommended Firebase explorations

| Question | Events / dimensions |
|----------|---------------------|
| Where do players quit KoN? | `kon_room_enter` funnel, drop-off room_id |
| Death difficulty | `kon_died.cause` breakdown |
| SoC completion rate | `soc_run_start` → `soc_game_complete` |
| Anthology story popularity | `story_start` / `story_complete` by `story_id` |
| Arena difficulty | `arena_end.outcome` by `waves_cleared` |
| Chronicler engagement | `chronicler_achievement_claim` rate |
| Settings preferences | User properties `appearance`, `text_pacing` |

### BigQuery export (optional, Phase 7+)

Enable GA4 linking for SQL funnels — useful for "time to first win" with `turn_index` on `kon_won`.

### Alerts

- Crashlytics velocity alert → email on new fatal issue
- Non-fatal spike on `save_failed` → investigate persistence bug

### What narrative/content leads should review

- `flavor_id` list matches intended secret discovery tracking
- Story `phase_key` names are meaningful in dashboards
- No story spoilers in event names (IDs are dev-facing, not player-facing)

---

## 23. Privacy policy & App Store

### Privacy policy updates (`PrivacyPolicyView`)

Replace "no analytics SDK" with:

- Firebase Analytics & Crashlytics operated by Google
- Data collected: app interactions, crashes, coarse device info
- No account, no player names, no game transcript
- Opt-out via Settings
- Link to [Google Privacy Policy](https://policies.google.com/privacy)

### App Privacy (Nutrition Labels)

Declare:

- **Analytics** — gameplay interaction data (not linked to identity)
- **Crash data** — diagnostics
- **Not collected:** contact info, user content, precise location

### ATT

Not required for first-party analytics without cross-app tracking.

---

## 24. Open decisions

| # | Decision | Options | Recommendation |
|---|----------|---------|----------------|
| D1 | Firebase project | Single vs dev/prod split | **Split** — `avasia-ios-dev` for Debug |
| D2 | Analytics default | On vs off | **On** with clear opt-out (industry standard) |
| D3 | `kon_turn` logging | Off / sampled / verbose | **Off in Release**, sample 1/10 in Debug |
| D4 | Audio SFX events | Off / sampled | **Off** initially — high noise |
| D5 | Exact Chronicler XP | Log or bucket | **Bucket only** in analytics |
| D6 | Commit plist | Yes vs CI inject | **Commit** for solo dev; CI secret for OSS |
| D7 | Firebase in SPM vs CocoaPods | SPM | **SPM** (matches project.yml) |

---

## Appendix A — full event index

Alphabetical — 100 events target cap respected.

`achievement_toast_show`, `achievement_unlock`, `achievement_view_list`, `analytics_opt_out`, `app_background`, `app_open`, `arena_end`, `arena_enter`, `arena_first_clear`, `arena_wave_clear`, `arena_wave_start`, `chronicler_achievement_claim`, `chronicler_death_xp`, `chronicler_ledger_view`, `chronicler_rank_up`, `chronicler_reset`, `chronicler_run_begin`, `chronicler_xp_grant`, `combat_gold_float`, `combat_hp_flash`, `combat_line_emphasis`, `combat_low_hp_vignette`, `combat_ui_lock`, `credits_view`, `gold_display_sync`, `kon_command_class`, `kon_death_dismiss`, `kon_died`, `kon_flag_gain`, `kon_flavor`, `kon_region_enter`, `kon_room_enter`, `kon_run_end`, `kon_run_resume`, `kon_run_start`, `kon_save`, `kon_save_failed`, `kon_turn`, `kon_win_celebration`, `kon_won`, `onboarding_complete`, `onboarding_replay`, `onboarding_start`, `privacy_policy_view`, `reduce_motion_active`, `saga_back`, `saga_chronicler_open`, `saga_product_select`, `saga_timeline_open`, `save_failed`, `save_read`, `save_write`, `screen_view`, `settings_change`, `settings_reset_chronicler`, `shop_enter`, `shop_insufficient_gold`, `shop_purchase`, `soc_chapter_enter`, `soc_class_select`, `soc_combat_end`, `soc_combat_start`, `soc_combat_turn`, `soc_death_dismiss`, `soc_died`, `soc_epilogue`, `soc_game_complete`, `soc_item_gain`, `soc_level_up`, `soc_name_set`, `soc_room_enter`, `soc_run_end`, `soc_run_resume`, `soc_run_start`, `soc_throne_phase`, `soc_trophy_unlock`, `soc_war_camp_phase`, `splash_complete`, `story_abandon`, `story_alignment_set`, `story_combat_end`, `story_combat_start`, `story_complete`, `story_fp_gain`, `story_fp_spend`, `story_hub_enter`, `story_phase`, `story_picker_open`, `story_picker_select`, `story_room_enter`, `story_start`, `support_link_tap`, `title_continue`, `title_continue_failed`, `title_new_game`, `title_open_achievements`, `title_open_codex`, `title_open_settings`, `title_open_trophies`, `trophy_toast_show`, `trophy_unlock`, `trophy_view_list`, `typewriter_complete`, `typewriter_skip`

**Count:** 108 — trim optional events (`kon_turn`, `soc_combat_turn`, audio/haptic) if approaching Firebase custom event registration limits in practice. Group low-value SFX under single sampled `media_cue` if needed.

---

## Appendix B — parameter reference

| Parameter | Type | Used by |
|-----------|------|---------|
| `product` | string | Most game events |
| `screen` | string | Navigation |
| `previous_screen` | string | `screen_view` |
| `room_id` | string | Exploration |
| `region_id` | string | KoN |
| `chapter_id` | string | SoC |
| `story_id` | string | Anthology |
| `cause` | string | Death |
| `outcome` | string | Combat, arena |
| `achievement_id` | string | Achievements |
| `trophy_id` | string | SoC trophies |
| `flavor_id` | string | KoN secrets |
| `phase` / `phase_key` | string | Story/state machines |
| `alignment` | string | Anthology |
| `enemy_id` | string | Combat |
| `item_id` | string | Items/shop |
| `class_id` | string | SoC class |
| `track_id` / `cue_id` | string | Audio |
| `turn_index` | int | Progress depth |
| `wave` | int | Arena |
| `amount` | int | FP/gold (coarse) |
| `rank_band` | int | Chronicler |
| `secret` | bool | Achievement |
| `success` / `found` / `affordable` | bool | Outcomes |
| `load_error` | bool | Run start |
| `clean_win` | bool | KoN win |
| `error_code` | string | Errors |
| `session_seconds` | int | Background |
| `duration_ms` | int | Timing |
| `source` | string | Attribution |
| `destination` | string | External links |
| `key` / `value` | string | Settings |
| `verb_bucket` | string | Parser class |

---

*Last updated: June 2026 — draft for implementation. Update status checkboxes in §20 as phases land.*
