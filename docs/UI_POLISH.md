# UI Polish Spec

Follow-on polish for the SwiftUI app (`App/Views/`). Complements
[`WIREFRAMES.md`](WIREFRAMES.md) (layout), [`ASSETS.md`](ASSETS.md) (art/audio
manifest), and the recent interaction pass (`PressScaleButtonStyle`, chapter
cards, parchment transcript, progress bars).

**Goal:** make the app feel tactile, deliberate, and place-aware without
competing with the transcript — the text stays the hero.

---

## Current baseline (shipped)

| Area | Status |
|---|---|
| Press-scale on buttons/chips | `PressScaleButtonStyle` in `Theme.swift` |
| Saga chapter cards + save hints | `ChapterCard`, `GameViewModel.sagaSaveHint` |
| Parchment transcript wash | `ParchmentBackground` |
| Region label on illustration band | `RegionIllustration` gradient scrim |
| Combat badge | `StatusBadge` in game status strip |
| Screen crossfade | `RootView` `.animation(.easeInOut, value: vm.screen)` |
| Achievement/trophy progress | `ProgressBar` in list headers |
| Light/dark palettes | `ThemeColors`, `AppAppearance` |

**Not yet shipped:** haptics, per-screen enter motion, region-change crossfade,
celebration moments, settings for motion/haptics.

---

## Design principles

1. **Deference** — motion and haptics confirm actions; they never delay reading.
2. **Reduce Motion first** — every animation has an instant or opacity-only
   fallback when `accessibilityReduceMotion` is on.
3. **Offline & lightweight** — no network, no Lottie; Core Haptics + SwiftUI only.
4. **Graceful degradation** — missing art/audio/haptics hardware never breaks play.
5. **One settings surface** — haptics and “extra motion” live in Settings next to
   sound and appearance.

---

## 1. Haptics

### 1.1 Purpose

Give the parser-adventure a physical “click” on intentional taps — menu choices,
quick verbs, send — and stronger pulses on story beats (death, level-up, unlock).

### 1.2 Settings

Add to `AppSettings` + `SettingsView`:

| Setting | Default | Notes |
|---|---|---|
| `hapticsEnabled` | `true` | Master toggle; independent of sound mute |

Copy: **“Haptic feedback”** — “Light taps on buttons and story moments.”

Respect system **Settings → Sounds & Haptics** — if the device has haptics
disabled globally, `HapticManager` no-ops (check
`CHHapticEngine.capabilitiesForHardware().supportsHaptics` on iOS).

### 1.3 `HapticManager` (new, `App/Haptics/HapticManager.swift`)

Thin `@MainActor` singleton, mirroring `AudioManager`:

```swift
enum HapticCue {
    case tap          // menus, chips, send
    case confirm      // primary actions (New Game, checkpoint restart)
    case notify       // achievement/trophy toast, level-up dismiss
    case warning      // death overlay appear
    case impactLight  // room transition (optional; pairs with sfx_move)
}
```

| Cue | API | When |
|---|---|---|
| `.tap` | `UIImpactFeedbackGenerator(.light)` | `MenuButton`, `ChapterCard`, quick-action chip, send |
| `.confirm` | `UIImpactFeedbackGenerator(.medium)` | New Game, Continue, Restart from checkpoint |
| `.notify` | `UINotificationFeedbackGenerator(.success)` | Trophy/achievement toast appear; level-up dismiss |
| `.warning` | `UINotificationFeedbackGenerator(.error)` | Death overlay presented |
| `.impactLight` | `UIImpactFeedbackGenerator(.soft)` | Optional: room change after `sfx_move` |

**Do not** haptic on: every transcript line, typewriter tick, or pacing skip tap
(to avoid fatigue during long narration).

### 1.4 Wiring map

| View / VM hook | Cue |
|---|---|
| `MenuButton` action | `.tap` (standard) / `.confirm` (`.primary`) |
| `ChapterCard` | `.tap` |
| `GameView` quick-action + send | `.tap` |
| `GameViewModel.restartFromCheckpoint` | `.confirm` |
| `GameViewModel.startNewGame` / `continueGame` | `.confirm` |
| `finishAchievements` / `finishSocTrophies` | `.notify` (once per batch) |
| `pendingDeath = true` | `.warning` |
| `pendingLevelUp` set | `.notify` (soft; optional) |
| `GameViewModel.submit` + `.move` transition | `.impactLight` (optional, behind setting) |

Call pattern inside `HapticManager`:

```swift
func play(_ cue: HapticCue) {
    guard AppSettings.hapticsEnabled, supportsHaptics else { return }
    // prepare + fire appropriate generator
}
```

### 1.5 Acceptance

- [ ] Toggle off → zero haptics anywhere
- [ ] Reduce Motion on → haptics still work (unless user disables in Settings)
- [ ] Simulator: no crash when generators unavailable
- [ ] VoiceOver: haptics do not replace accessibility labels

---

## 2. Screen-enter animations

### 2.1 Problem

`RootView` crossfades on `vm.screen` change, but all screens share the same
transition. Menus, lists, and the game screen benefit from distinct enter cues.

### 2.2 Navigation classes

| Class | Screens | Enter behavior |
|---|---|---|
| **Hub** | `SagaTitleView`, `TitleView` | Content fades + slides up 12pt (hero first, then menu) |
| **Stack** | Settings, Credits, Privacy, Achievements, Trophies | Single panel: opacity 0→1 + 8pt upward drift, 0.28s ease-out |
| **Play** | `GameView` | Illustration band slides down 8pt; transcript opacity 0→1 (no slide on text) |
| **Modal** | Death overlay, level-up | Existing scrim; add scale 0.96→1 on card, 0.32s spring |

### 2.3 Implementation sketch

**Option A (recommended):** per-view `.transition` + tagged `ZStack` in
`RootView`:

```swift
switch vm.screen {
case .saga:
    SagaTitleView()
        .transition(.hubEnter)
case .game:
    GameView()
        .transition(.playEnter)
// ...
}
```

Define custom `AnyTransition` extensions in `App/Views/Transitions.swift`:

```swift
extension AnyTransition {
    static var hubEnter: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 12)),
            removal: .opacity
        )
    }
    static var stackEnter: AnyTransition { ... }
    static var playEnter: AnyTransition { ... }
}
```

**Option B:** `@State private var appeared` per view with staggered
`.opacity(appeared ? 1 : 0)` on hero vs menu — more control, more boilerplate.

Use **Option A** for screen-level; **Option B** inside `SagaTitleView` /
`TitleView` to stagger hero (0ms) → buttons (+60ms) → footer (+120ms).

### 2.4 Reduce Motion

When `accessibilityReduceMotion`:

| Normal | Fallback |
|---|---|
| offset + opacity | opacity only, duration 0.15s |
| spring on modals | linear opacity |
| staggered hub children | all appear together |

Centralize in `Motion.accessible(_ animation:)` helper that reads environment.

### 2.5 Game ↔ menu

Leaving `GameView` for title: **no** slide-left iOS navigation metaphor — keep
opacity crossfade so it feels like lifting a overlay, not popping a stack.

### 2.6 Acceptance

- [ ] Saga → Title → Game → Settings → Back: no layout jump or double-fade flash
- [ ] Reduce Motion: all screens usable, no sliding
- [ ] iPad split game layout: play-enter does not reflow sidebar abruptly

---

## 3. Region illustration & background rollout

### 3.1 Asset pipeline (unchanged convention)

Per [`ASSETS.md`](ASSETS.md): `bg_<region>` (full bleed @ ~45% opacity),
`art_<region>` (header band). Names from `Media.backgroundName` /
`illustrationName`.

**Gap to fix in ASSETS.md:** add `cataracta` row — Blade of Courage Act I
depends on it (`Region.cataracta`).

### 3.2 Rollout priority

Ship art in player-journey order so the first hours look finished:

| Priority | Region | KoN | SoC | Art direction (one line) |
|---|---|---|---|---|
| P0 | `cataracta` | — | Act I hub | Misty falls, green stone, legion banners |
| P0 | `oceandale` | Act I | War front | Ruined gate, smoke, grey sea |
| P1 | `beach` / `shore` | Act I | — | Sand, wreckage, cold surf |
| P1 | `splitpath` | Hub | — | Forked road, worn signposts |
| P1 | `aylova` | Endgame | War camp / throne | Capital spires, cool regal blue |
| P2 | `mountain` / `cave` | Midgame | — | Ridge wind; pink crystal cavern |
| P2 | `forest` / `tree` | Midgame | Silvarium elders | Deep green; interior great tree |
| P2 | `nacastrum` | Endgame | Portal / library | Floating city, blue crystal hum |
| P3 | `graveyard` / `road` | Side content | Northern march | Bleak outskirts; dusty road |

P0 = marketing screenshots + first-session retention. P3 = completeness.

### 3.3 Region change transition (code)

When `vm.media.region` changes during play:

1. Crossfade **background** over 0.4s (`RegionBackground` keyed on `media`).
2. Crossfade **illustration** over 0.35s; brief accent flash on bottom label
   (opacity pulse on region title, 0.2s).
3. Optional haptic `.impactLight` if haptics enabled.
4. Ambient already swaps via `AudioManager.playAmbient` — keep as-is.

Implementation: pass `media` as `.id(media.region)` on `RegionBackground` and
`RegionIllustration` with `.animation(.easeInOut(duration: 0.4), value: media.region)`.

### 3.4 Placeholder → art upgrade path

Until `art_*` exists, placeholders show:

- Region gradient (`RegionPalette`)
- Sparkle + small-caps region name (center)
- Bottom scrim + region title (always)

When art lands, **no code change** — `assetExists` branch swaps automatically.
QA: verify label contrast on both light and dark appearance for each delivered
`art_*`.

### 3.5 Illustration safe zones

Header band height is dynamic (`LayoutMetrics.illustrationHeight`: 68–240pt).
Art brief for designers:

```
┌─────────────────────────────────────┐
│  [ focal subject — upper 60% ]       │  ← keep faces/icons here
│                                      │
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← bottom 36pt: scrim + label (don't put critical detail)
└─────────────────────────────────────┘
```

Export: 3:1 landscape master, dark enough for white/parchment label @ 92%
opacity.

### 3.6 Acceptance

- [ ] Adding `art_cataracta` alone upgrades SoC opening without rebuild of engine
- [ ] Region change mid-game crossfades without transcript scroll jump
- [ ] Missing asset: gradient fallback matches `RegionPalette` hues

---

## 4. Additional polish (phase 2+)

Lower priority; spec now so they don’t get ad-hoc implementations later.

### 4.1 Transcript line reveal

- New completed line: optional 4pt upward fade-in (0.18s) on `LineView`.
- Skip when pacing is Off or Reduce Motion on.
- Hint lines (`> command`) use a subtler fade (opacity only).

### 4.2 Toast celebrations

Achievement/trophy toasts (`GameView`):

- Insert: slide from top + spring (existing) + `.notify` haptic.
- Icon: one-time `symbolEffect(.bounce)` on trophy SF Symbol (iOS 17+).
- Auto-dismiss unchanged (4s).

### 4.3 Death & level-up modals

| Overlay | Enhancement |
|---|---|
| Death | Skull `symbolEffect(.pulse)` once; card `scaleEffect` 0.96→1 |
| Level-up | Star icon rotate 0→360° (0.5s) once on appear |

### 4.4 Input bar focus

When `TextField` focused: accent border brightens to 0.45 opacity; unfocused
0.2. No layout shift.

### 4.5 iPad split layout

- Sidebar status strip: vertical dividers between controls / inventory / deaths.
- Optional: pin region illustration in sidebar while transcript scrolls (already
  structurally supported by `splitLayout`).

### 4.6 Parchment texture (optional asset)

Procedural gradient is shipped. Optional `parchment_noise` tile (@2x, seamless,
very low contrast) overlaid at 4–6% opacity in `ParchmentBackground` for light
mode richness. Not required for MVP.

---

## 5. Implementation phases

| Phase | Scope | Touch points | Effort |
|---|---|---|---|
| **P1** | Haptics + setting | `HapticManager`, `AppSettings`, `SettingsView`, `Theme.swift`, `GameViewModel` | ~½ day |
| **P2** | Screen transitions + Reduce Motion | `Transitions.swift`, `RootView`, hub views | ~½ day |
| **P3** | Region crossfade | `RegionArt.swift`, `GameView` | ~2 hrs |
| **P4** | P0 art (`cataracta`, `oceandale`) | Asset catalog only | design-dependent |
| **P5** | Toasts + modal motion | `GameView`, overlays | ~½ day |
| **P6** | Transcript line reveal | `LineView` | ~2 hrs |

Recommended order: **P1 → P3 → P2 → P4 (parallel art) → P5 → P6**.

---

## 6. Testing checklist

### Manual

- [ ] First launch saga: chapter cards, settings, credits — haptics on/off
- [ ] New game KoN + SoC: region crossfade on first move
- [ ] Death + level-up + trophy unlock: feedback fires once, not per line
- [ ] Light + dark + System appearance
- [ ] Largest Dynamic Type on iPhone SE + iPad split layout
- [ ] Reduce Motion: no sliding; game still playable
- [ ] VoiceOver through saga → game → back

### Automated (optional)

- Unit: `HapticManager` respects `hapticsEnabled` flag (injectable settings).
- UI test: saga chapter card tap navigates to title (`accessibilityIdentifier`
  `saga-kon` / `saga-soc`).

---

## 7. Doc cross-references

| Topic | Doc |
|---|---|
| Screen layout | [`WIREFRAMES.md`](WIREFRAMES.md) |
| Asset file names | [`ASSETS.md`](ASSETS.md) — add `cataracta` when implementing P4 |
| Styled text colors | [`ENGINE_SPEC.md`](ENGINE_SPEC.md) §B.7 |
| SoC regions / rooms | [`sequel/WORLD_MAP.md`](sequel/WORLD_MAP.md) |
| Blue-crystal motif | [`STORY.md`](STORY.md) §8 |

---

## 8. Open questions

1. **Room-level art** — stay region-scoped (current engine) or add optional
   `art_<room>` override for set-piece rooms (Throne, Varatro Falls)? *Recommend:
   region-only until a second illustration slot is needed.*
2. **Haptics on pacing tap** — skip (spec default) or very light `.tap`? *Skip.*
3. **“Extra motion” master toggle** — separate from Reduce Motion, or rely on
   system only? *Rely on system + per-animation fallbacks for v1.*
