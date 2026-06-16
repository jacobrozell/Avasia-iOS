# Onboarding — Welcome Tour

> **Status:** Shipped in app · first launch + replay from Settings  
> **Goal:** Orient new players on what Avasia is, how it plays, and where it came from — without blocking repeat players.

---

## 1. When it shows

| Trigger | Behavior |
|---|---|
| **First launch** | After the splash screen fades, before the saga hub |
| **Settings → Replay welcome tour** | Full tour; does not reset the completion flag until finished |
| **Saga hub → How to play** | Same tour, returns to hub when done |

Completion is stored in `UserDefaults` (`avasia.onboarding.completed`). Skipping or finishing both mark it complete.

---

## 2. Pages (6)

### 1 — Where it began

**Tone:** Personal, warm, honest.

Copy anchors the origin story:

- High-school friends (Chase, Devan, Joshua, and the rest) teaching themselves Python after class
- Building text adventures for fun
- Months of collective obsession over this world
- Years later: a faithful native iOS remake of that saga

No individual attribution by first name beyond the team. No in-fiction spoilers.

### 2 — A living saga

Explain the hub model:

- One app, multiple **chapters** (KoN, SoC, Short Stories)
- Each chapter has its own save file and engine
- The fiction spans eras; the way you play may change as the saga grows

Show the three chapter cards conceptually (crown / shield / book).

### 3 — How you play

Text-adventure basics:

- Read the transcript; type commands or tap suggestions
- Tap the transcript to skip ahead while text is typing
- Settings: text pacing, typewriter speed, cursor style, sound, haptics

### 4 — Fights & saves

Core mechanics new players hit early:

- **Auto-save** after each turn; **Continue** on the chapter title screen
- **One save per chapter** (KoN, SoC, Short Stories)
- **Combat** — HP strip, attack/defend/flee when battle starts
- **Death** — restart from checkpoint or start a new run

### 5 — The Chronicler

Meta progression (see [`META_PROGRESSION.md`](META_PROGRESSION.md)):

- Saga XP persists across chapters and runs
- Chronicler Rank on the hub; ledger for lifetime gains
- Achievements (KoN) and trophies (SoC) feed the ledger

### 6 — Explore

Secondary features worth knowing on day one:

- **Codex** — lore unlocked in play (per chapter)
- **Saga Timeline** — series chronology from the hub
- **Short Stories** — parallel tales; pick allegiances or refuse both

Primary CTA: **Enter the saga** → saga hub.

---

## 3. UX rules

- **Paged carousel** (`TabView` + page style) with dot indicator
- **Skip** on pages 1–5; **Next** advances; last page uses primary **Enter the saga**
- Matches title-screen art direction (`TitleScreenBackground`, serif type, accent)
- Respects Reduce Motion (no decorative motion when enabled)
- VoiceOver: each page is a combined accessibility element with title + body

---

## 4. Out of scope (for now)

- Per-chapter onboarding inside KoN/SoC intros (engines already have prologues)
- Tooltips on first hub tap
- Chronicler rank-gated tutorial content

---

## 5. Files

| File | Role |
|---|---|
| `App/Views/OnboardingView.swift` | Paged UI |
| `App/Settings/AppSettings.swift` | `hasCompletedOnboarding` |
| `App/ViewModels/GameViewModel.swift` | `.onboarding` screen, `completeOnboarding()`, `openOnboarding(from:)` |
| `App/AvasiaApp.swift` | `RootView` routing |
| `App/Views/SagaTitleView.swift` | "How to play" entry |
| `App/Views/SettingsView.swift` | "Replay welcome tour" |
