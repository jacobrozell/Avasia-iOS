# Combat & Status Animation Spec

Combat feedback and status-strip motion for the SwiftUI app (`App/Views/`).

**Complements:** [`UI_POLISH.md`](UI_POLISH.md), [`POLISH_ROADMAP.md`](POLISH_ROADMAP.md), [`WIREFRAMES.md`](WIREFRAMES.md)  
**Scope:** SoC combat, anthology arena, and shared status-strip moments (HP, gold, level-up).  
**Status:** Core implementation shipped — see [`POLISH_ROADMAP.md`](POLISH_ROADMAP.md) for checklist.  
**Principle:** The transcript stays the hero. Animations reinforce numbers and beats — they don't replace reading.

---

## Inspiration: Warsim

[Warsim: The Realm of Aslona](https://store.steampowered.com/app/659540/Warsim_The_Realm_of_Aslona/) is a deep text-based kingdom sim with charming ASCII presentation. Its lesson for Avasia isn't "add ASCII art" — it's that **text-heavy games feel premium when every number change has a visible consequence**.

Warsim makes procedural chaos readable through:

| Warsim pattern | Avasia equivalent |
|---|---|
| Arena fights feel physical despite being text | HP bar ticks down; hit lines flash; SFX on land/miss |
| Throne-room encounters have personality in presentation | Transcript emphasis synced to typewriter pacing |
| Stats and kingdom meters are always visible | Status strip shows animated HP/gold, not static labels |
| Absurd scale (millions of races) still feels tactile | Small motion cues so each combat turn feels distinct |
| Celebration moments (arena victory, festivals) | Kill fanfare, gold float, trophy toasts |

**What we borrow:** responsiveness, visible state, beat-synced feedback.  
**What we don't borrow:** ASCII aesthetic, kingdom-sim UI density, or anything that competes with the parchment transcript.

---

## 1. Current baseline

| Area | Today |
|---|---|
| Combat state | `socState.inCombat`, `anthologyState.arenaInCombat` |
| HP display | Static `Label("12/20", systemImage: "heart.fill")` in status strip |
| Combat narrative | Engine lines: hit, miss, block, potion, turn summary |
| Text reveal | Typewriter pacing on transcript lines |
| Combat badge | Red `StatusBadge("Combat")` — appears instantly |
| Death / level-up | Full-screen overlays (opacity transition only) |
| SFX | `sfx_death`, `sfx_move`, etc. — **no combat cues yet** |
| Reusable bar | `ProgressBar` exists but is not animated |

**Gap:** HP and gold snap to new values the moment `GameViewModel.submitSoc` returns. The player reads damage in the transcript, but the status strip doesn't visually confirm it.

---

## 2. Design principles

1. **Sync with transcript, not ahead of it** — HP ticks down while or just after the damage line types, not before the player reads "hits you for 4 damage!"
2. **One beat per turn** — at most one HP animation sequence per attack command; no stacking flashes.
3. **Reduce Motion** — animated counts become instant value updates; keep color flash optional (opacity-only).
4. **Engine stays pure** — combat math stays in `SoCCombat`; the app layer derives presentation events from before/after state + line content.
5. **Graceful no-op** — missing SFX/haptics never block combat.
6. **Warsim test** — if a number changed and the player wouldn't notice without re-reading the transcript, add a status-strip cue.

---

## 3. Architecture: presentation events

Add a lightweight event enum the ViewModel emits after each turn (not persisted):

```swift
enum CombatPresentationEvent: Equatable {
    case combatBegan(enemyName: String)
    case combatEnded(victory: Bool)
    case playerDamaged(from: Int, to: Int, max: Int)
    case playerHealed(from: Int, to: Int, max: Int)
    case enemyDamaged(from: Int, to: Int, max: Int, name: String)
    case playerMiss
    case enemyMiss(name: String)
    case block(name: String)          // guardian absorb
    case lowHpWarning                 // ≤ 25% max
    case expGained(amount: Int)       // on kill
}
```

**Derivation (ViewModel, after `socEngine.submit`):**

```swift
let hpBefore = state.playerHp
let enemyHpBefore = state.enemy?.hp
// ... submit ...
// diff hpBefore → hpAfter, parse lines for miss/block/heal keywords
// enqueue CombatPresentationEvent(s) into @Published var combatEvents: [CombatPresentationEvent]
```

Alternative (cleaner long-term): engine returns `SoCCombatResult.events: [CombatPresentationEvent]` alongside `lines`. **Recommend ViewModel diff for v1** — zero engine API change.

Anthology arena: same event shape, smaller surface (no potion/flee).

---

## 4. Combat UI components

### 4.1 Animated HP bar (status strip)

Replace the plain HP label during combat (or always for SoC once class is chosen).

```
┌─────────────────────────────────────────────┐
│ ♥  ████████████░░░░░░  12 → anim → 8 / 20  │
└─────────────────────────────────────────────┘
```

| Property | Spec |
|---|---|
| Component | `AnimatedHealthBar(current:max:displayedValue:)` |
| Bar fill | Reuse `ProgressBar` gradient; animate `displayedValue` with `.easeOut(duration: 0.45)` |
| Number | Count from `from` → `to` over same duration (`Animatable` or `TimelineView`) |
| Color tiers | >50% parchment/accent · 26–50% amber · ≤25% red (matches `lowHpWarning` in combat text) |
| Heart icon | Brief `scaleEffect(1.15→1)` + red tint flash on damage; green tint on heal |
| Reduce Motion | Jump to final value; bar width snaps |

**When to show enemy HP:** Optional compact row under status strip **only in combat**:

```
⚔ Bandit Captain  ██████░░░░  14/30
```

Hidden when not `inCombat`. Enemy bar animates on `enemyDamaged` events only.

### 4.2 Transcript line emphasis

When a combat event fires, briefly highlight the matching transcript line:

| Event | Line treatment |
|---|---|
| Player damaged | Line containing "hits you" — parchment → red flash → normal (0.3s) |
| Player hit enemy | "You strike" — accent flash |
| Miss | Opacity pulse 0.6→1 (subtle) |
| Block | Accent + brief shield SF Symbol inline (optional) |
| Kill | "You killed" — `.death` style already red; add one-time scale pulse |

Implementation: tag `TranscriptDisplayLine` with `emphasis: CombatEmphasis?` set when line is appended; `LineView` applies `.foregroundColor` animation.

**Timing:** Emphasis triggers when typewriter **finishes** that line (hook into pacing completion), not when line starts.

### 4.3 Combat enter / exit

| Moment | Animation |
|---|---|
| **Enter** | Status strip slides down 4pt + fades in enemy HP row; Combat badge scales 0.9→1 with red pulse; optional `sfx_combat_start` |
| **Exit (victory)** | Enemy row fades out; badge crossfades away; brief gold shimmer on gold label if exp granted |
| **Exit (flee)** | Badge fades; no celebration |
| **Exit (death)** | Hand off to existing death overlay (skull pulse per UI_POLISH §4.3) |

### 4.4 Turn feedback (micro)

| Action | Feedback |
|---|---|
| ATTACK chip tap | Existing `PressScaleButtonStyle` + `.tap` haptic |
| Turn resolving | Disable input + quick actions for duration of combat animations (~0.5–1.2s max) |
| Low HP | Status strip subtle red vignette pulse (opacity 0→0.12→0, once per threshold entry) |

---

## 5. Audio & haptics (combat)

Extend `SoundCue`:

| Cue | File | When |
|---|---|---|
| `sfx_hit` | player or enemy lands hit | First damage line completes |
| `sfx_miss` | whoosh | Miss line completes |
| `sfx_block` | shield clang | Guardian block |
| `sfx_heal` | potion glug | HP increases from EAT |
| `sfx_combat_start` | short sting | `combatBegan` |
| `sfx_victory` | short fanfare | kill, before exp lines |

Haptics (if `HapticManager` shipped per UI_POLISH):

| Event | Cue |
|---|---|
| Player hit | `.impactLight` |
| Player crit/low HP hit | `.warning` (only if crossing ≤25%) |
| Kill | `.notify` |
| Miss | none |

---

## 6. Non-combat status animations

Same `AnimatedValue` primitive for anything in the status strip:

| Moment | Animation |
|---|---|
| **Gold change** | Count up/down 0.35s; `+N` float label fades up and out (only on gain) |
| **Level up** | Existing overlay + animate status strip level number before overlay dismisses |
| **Item gained** | Inventory icon bounces in (`symbolEffect(.bounce)`) when new item appears in strip |
| **Spell learned (KoN)** | Sparkle icon pulse on new spell chip |
| **Achievement/trophy** | Already specced in UI_POLISH §4.2 |
| **Codex entry unlocked** | Toast pattern (slide + opacity), same as trophies |
| **Region change** | Already specced in UI_POLISH §3.3 |

**Gold float label sketch:**

```
        +15 ✦
Gold  ● 120  →  anim → 135
```

Only show float on increase; decreases snap or count down without float.

---

## 7. Timing budget

Per combat turn (player attacks):

```
0.0s   Submit; disable input
0.0s   Transcript: first line begins typewriter
~0.3s  Hit/miss line completes → trigger emphasis + SFX + start HP animation
~0.8s  HP animation completes
       Second attacker line(s) continue via normal pacing
       Turn summary line types
       Re-enable input when pacing idle OR after max 1.2s animation cap
```

**Rule:** Animations never add more than **~0.5s** beyond what pacing already takes. If pacing is Off, entire turn feedback completes in ≤0.8s.

---

## 8. Settings & accessibility

| Setting | Effect |
|---|---|
| Reduce Motion (system) | Instant HP/gold values; opacity-only emphasis |
| Text pacing Off | Faster animation cap (0.4s) |
| Sound off | No combat SFX |
| VoiceOver | `accessibilityValue` on HP bar announces "8 of 20 health, took 4 damage" on change; don't rely on color alone |

---

## 9. Implementation phases

| Phase | Deliverable | Status |
|---|---|---|
| **C1** | `AnimatedHealthBar` + player HP in status strip | ✅ |
| **C2** | ViewModel event diffing from SoC submit | ✅ |
| **C3** | Sync HP animation to pacing completion | ✅ |
| **C4** | Enemy HP row + combat enter/exit | ✅ |
| **C5** | Transcript line emphasis | ✅ |
| **C6** | Combat SFX + haptic wiring | ✅ |
| **C7** | Gold animate + item bounce | ✅ |
| **C8** | Anthology arena parity | ✅ |

**Recommended order:** C1 → C2 → C3 → C4 → C5 → C6 → C7 → C8.

**Quick win:** C1 + C2 — `AnimatedHealthBar` wired to a `displayedPlayerHp` that tweens whenever `socState.playerHp` changes. Ships without transcript sync and already makes combat feel much better.

---

## 10. Acceptance criteria

- [x] Player HP bar animates down on enemy hit, up on potion — never jumps backward incorrectly
- [x] With pacing On, HP moves after the damage line finishes typing
- [x] With Reduce Motion, values update instantly with no slide/count
- [x] Combat badge + enemy row appear only during `inCombat`
- [x] Input disabled during animation window; no double-attack on rapid tap
- [x] Death overlay still appears after final combat lines
- [x] Arena combat uses same HP bar behavior
- [x] KoN unaffected (no combat UI)

---

## 11. Open questions

1. **Always show HP bar outside combat?** Recommend yes once SoC class is chosen — reinforces RPG feel; bar just sits at full until first hit.
2. **Enemy HP in transcript only vs status row?** Status row is clearer for mobile; transcript lines remain canonical for accessibility.
3. **Engine events vs ViewModel diff?** Diff is faster to ship; migrate to engine events if anthology/KoN ever share a unified combat system.
4. **Block input during pacing?** Already partially true via pacing wait; combat should extend that through HP tween.

---

## 12. Doc cross-references

| Topic | Doc |
|---|---|
| General motion & haptics | [`UI_POLISH.md`](UI_POLISH.md) |
| Screen layout | [`WIREFRAMES.md`](WIREFRAMES.md) |
| Combat rules (engine) | [`sequel/ENGINE_SPEC.md`](sequel/ENGINE_SPEC.md) |
| Sound asset names | [`ASSETS.md`](ASSETS.md) |
| Styled text colors | [`ENGINE_SPEC.md`](ENGINE_SPEC.md) §B.7 |
