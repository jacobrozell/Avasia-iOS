# Polish Roadmap

**Living checklist** for app feel — motion, haptics, audio, and art.  
Merges and tracks [`UI_POLISH.md`](UI_POLISH.md) + [`COMBAT_UI.md`](COMBAT_UI.md).

**North star:** the transcript stays the hero. Polish confirms actions and makes
numbers legible; it never delays reading. Inspired in part by
[Warsim](https://store.steampowered.com/app/659540/Warsim_The_Realm_of_Aslona/) —
text-heavy games feel premium when every stat change has a visible consequence.

**Principles:** deference · Reduce Motion fallbacks · offline/lightweight · graceful
missing assets · one Settings surface for sound/haptics/appearance.

---

## Polish freeze — narrative priority

**Status:** Active (June 2026). Motion/haptics/combat-feedback targets are met.
**Default work is story and content**, not new app surfaces.

### Gate (ask before any polish task)

1. Does the player learn something about the plot they could not get from the transcript?
2. Does it add a new UI screen, toast type, or state to maintain?
3. Can the player ignore it entirely?

If **1 = no** and **2 = yes** → **do not build** until the freeze lifts.

### Allowed during freeze (low risk)

| Item | Why |
|---|---|
| Room / codex / saga **content** in engine + `docs/` | This *is* the plot |
| **Asset drops** (P4 art/audio) with no code change | Gradients already fall back |
| **`sfx_move`** on region change only | One cue, reinforces place |
| Bug fixes in shipped polish | Regression only |
| Manual playthrough + test checklist below | Validates story, not features |

### Deferred until freeze lifts

| Item | Why defer |
|---|---|
| A1 full audio (title music, all ambients, item/spell SFX) | Breadth, not plot |
| UX: objectives pin, codex unlock toast, timeline “you are here”, first-combat tooltip | Duplicate journal/codex/timeline |
| Combat extensions (EXP float, flee strip, arena wave chip) | Transcript already carries combat |
| iPad dividers, Dynamic Type pass, typewriter tick | Layout sweep, not narrative |

### Content focus (current)

- SoC Act I rooms (`SoCCataractaRooms.swift`, related flavor)
- Codex + saga seeds (`KonCodex`, `SoCCodex`, `docs/SAGA.md`, `docs/FORESHADOWING.md`)
- Full SoC playthrough against manual checklist (§Testing)

**To resume polish:** remove or date-stamp this section and pick one lane from §Deferred.

---

## Shipped ✅

### Core interaction
- [x] Press-scale buttons (`PressScaleButtonStyle`)
- [x] Saga chapter cards + save hints
- [x] **Chronicler** saga meta rank — hub strip, ledger, achievement claims, this-run XP ([`META_PROGRESSION.md`](META_PROGRESSION.md))
- [x] Parchment transcript wash
- [x] Light/dark palettes + appearance setting
- [x] Screen crossfade (`RootView`)
- [x] Region crossfade on travel (`RegionArt.swift`, `Motion.swift`)
- [x] Typewriter pacing + tap-to-advance
- [x] Achievement/trophy toasts (slide + spring)

### Combat & status ([`COMBAT_UI.md`](COMBAT_UI.md))
- [x] `AnimatedHealthBar` — player HP in SoC + arena
- [x] Enemy HP row during combat
- [x] HP/gold sync to typewriter line completion
- [x] Transcript line emphasis (hit, damage, miss, block, kill, heal)
- [x] Combat input lock during animation window
- [x] Gold count-up + `+N` float on gain
- [x] Item icon bounce on acquire
- [x] Low-HP vignette pulse
- [x] Combat presentation events (`CombatTriggerPlanner`)
- [x] Combat SFX placeholders (`scripts/generate_combat_sfx.py`)
- [x] Haptics on combat beats (hit, kill, low HP)
- [x] Haptics setting in Settings

### Motion polish (P2, P3, P5, P6)
- [x] Screen-enter transitions (`Transitions.swift`, hub/stack/play)
- [x] Play screen illustration drift + transcript fade
- [x] Transcript line reveal on typewriter completion
- [x] Death / level-up modal enter + toast bounce (P5)

### Partial
- [x] **Haptics** — menus, buttons, story beats, combat (`HapticManager` + Settings toggle)
- [~] **Audio** — combat SFX only; no `sfx_move` / ambient loops yet
- [~] **Art** — region gradients as fallback; no `art_*` / `bg_*` shipped

---

## Recommended order

```
Frozen  → Narrative content + manual playthrough (see §Polish freeze)
Maybe   → sfx_move only · P4 asset drops (no code)
Parked  → A1 full audio · UX meta-features · combat extensions · iPad/Dynamic Type
```

---

## P1 — Haptics everywhere (~½ day)

**Spec:** [`UI_POLISH.md` §1](UI_POLISH.md#1-haptics)

| Task | Status |
|---|---|
| `.tap` on `MenuButton`, `ChapterCard`, quick verbs, send | [x] |
| `.confirm` on New Game, Continue, checkpoint restart | [x] |
| `.notify` on achievement/trophy toast, level-up | [x] |
| `.warning` on death overlay | [x] |
| `.impactLight` on room change (optional) | [x] |
| Toggle off → zero haptics | [x] |
| Simulator safe no-op | [x] |

**Touch:** `HapticManager.swift`, `Theme.swift`, `GameView.swift`, `GameViewModel.swift`

---

## P2 — Screen-enter transitions (~½ day)

**Spec:** [`UI_POLISH.md` §2](UI_POLISH.md#2-screen-enter-animations)

| Task | Status |
|---|---|
| `Transitions.swift` + `Motion.accessible()` helper | [x] |
| Hub enter (Saga, Title) — fade + 12pt up | [x] |
| Stack enter (Settings, Achievements, …) | [x] |
| Play enter (GameView) — illustration drift, transcript fade | [x] |
| Modal enter (death, level-up) — scale 0.96→1 | [x] via `celebrationModalEnter` |
| Reduce Motion → opacity-only | [x] |

**Touch:** `RootView` / `AvasiaApp.swift`, hub views

---

## P3 — Region crossfade (~2 hrs)

**Spec:** [`UI_POLISH.md` §3.3](UI_POLISH.md#33-region-change-transition-code)

| Task | Status |
|---|---|
| Crossfade `RegionBackground` on `media.region` change (0.4s) | [x] |
| Crossfade `RegionIllustration` (0.35s) | [x] |
| Region label accent pulse | [x] |
| Optional haptic on region change | [x] via `playMoveFeedback` |
| No transcript scroll jump | [x] background is outside transcript |

**Touch:** `RegionArt.swift`, `GameView.swift`

---

## P4 — P0 region art (design-dependent)

**Spec:** [`UI_POLISH.md` §3.2`](UI_POLISH.md#32-rollout-priority), [`ASSETS.md`](ASSETS.md)

| Asset | Region | Priority |
|---|---|---|
| `art_cataracta` / `bg_cataracta` | SoC Act I hub | P0 |
| `art_oceandale` / `bg_oceandale` | KoN + SoC war front | P0 |
| `amb_cataracta` / `amb_oceandale` | ambient loops | P0 |

No code change when art lands — drop into asset catalog + `Audio/`.

---

## P5 — Celebration modals & toasts (~½ day)

**Spec:** [`UI_POLISH.md` §4.2–4.3](UI_POLISH.md#4-additional-polish-phase-2)

| Task | Status |
|---|---|
| Death overlay — skull pulse, card spring | [x] |
| Level-up — star rotate, card spring | [x] |
| Trophy toast — `symbolEffect(.bounce)` + `.notify` haptic | [x] |
| Achievement toast — same treatment | [x] |

**Touch:** `GameView.swift` death/level-up overlays, toast sections

---

## P6 — Transcript line reveal (~2 hrs)

**Spec:** [`UI_POLISH.md` §4.1](UI_POLISH.md#41-transcript-line-reveal)

| Task | Status |
|---|---|
| New line — 4pt upward fade-in (0.18s) | [x] |
| Hint lines (`> cmd`) — opacity only | [x] |
| Skip when pacing Off or Reduce Motion | [x] |

**Touch:** `LineView` in `Theme.swift`

---

## A1 — Core audio (~½ day + assets)

**Status:** **Parked** (freeze). Combat placeholders shipped; expand only if unfreezing.

**Spec:** [`ASSETS.md`](ASSETS.md)

| Cue | File | Status |
|---|---|---|
| Combat hit/miss/block/heal/start/victory | `sfx_*` | [x] placeholders |
| Room transition | `sfx_move` | [ ] |
| Item / spell | `sfx_item`, `sfx_spell` | [ ] |
| Death / win | `sfx_death`, `sfx_win` | [ ] |
| Title music | `music_title` | [ ] |
| Region ambients | `amb_<region>` | [ ] |

Extend `scripts/generate_combat_sfx.py` or add `generate_core_sfx.py` for placeholders.

---

## Combat extensions (optional)

**Status:** **Parked** (freeze).

**Spec:** [`COMBAT_UI.md`](COMBAT_UI.md) — core done; nice-to-haves below.

| Task | Status |
|---|---|
| EXP `+N` float on kill (mirror gold) | [ ] |
| Flee — strip fades out, no victory sting | [ ] |
| Class flair — hunter first-strike line accent | [ ] |
| Arena wave chip (“Wave 2”) on new foe | [ ] |
| KoN spell-learn / item-gain trigger reuse | [ ] |

---

## UX polish (no new systems)

**Status:** **Parked** (freeze). Journal, codex, and timeline already exist — avoid parallel UI.

| Task | Effort | Notes |
|---|---|---|
| Input bar focus — brighter accent border | ~1 hr | [`UI_POLISH.md` §4.4](UI_POLISH.md#44-input-bar-focus) |
| Objectives one-liner under status strip (SoC) | ~2 hrs | Pin current goal from journal |
| Codex unlock toast | ~2 hrs | Reuse trophy toast pattern |
| Save hint with region name on chapter cards | ~1 hr | `sagaSaveHint` enrichment |
| Saga timeline “you are here” highlight | ~2 hrs | `SagaTimelineView` |
| iPad sidebar dividers | ~1 hr | [`UI_POLISH.md` §4.5](UI_POLISH.md#45-ipad-split-layout) |
| Dynamic Type pass on status strip + combat bars | ~½ day | SE + largest text |
| First-combat tooltip (dismissible) | ~1 hr | Optional onboarding |

---

## Later / bigger swings

- Room-set illustrations (Throne, Varatro Falls, portal) — see open question in [`UI_POLISH.md` §8](UI_POLISH.md#8-open-questions)
- Parchment noise texture tile for light mode
- Typewriter tick SFX (off by default)
- “Extra motion” master toggle (v1 relies on system Reduce Motion only)

---

## Testing checklist

### Manual
- [ ] Saga → Title → Game → Settings → Back — no layout flash
- [ ] SoC combat: HP after damage line, input lock, SFX with sound on
- [ ] Arena parity in Stories
- [ ] Death + level-up + trophy — feedback once per event
- [ ] Haptics on/off in Settings
- [ ] Reduce Motion — no sliding; combat HP snaps
- [ ] Light + dark + largest Dynamic Type
- [ ] VoiceOver through saga → game → combat

### Automated (optional)
- [ ] `HapticManager` respects `hapticsEnabled`
- [ ] UI test: `saga-soc` → title → new game

---

## Doc map

| Topic | Doc |
|---|---|
| **This checklist** | `POLISH_ROADMAP.md` |
| General motion spec | [`UI_POLISH.md`](UI_POLISH.md) |
| Combat / status spec | [`COMBAT_UI.md`](COMBAT_UI.md) |
| Asset names | [`ASSETS.md`](ASSETS.md) |
| Layout | [`WIREFRAMES.md`](WIREFRAMES.md) |
| Styled text | [`ENGINE_SPEC.md`](ENGINE_SPEC.md) §B.7 |

**When shipping polish:** check the box here first, then add a one-line note to the
relevant detail spec if behavior changed.
