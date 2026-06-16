# Bad #1 — Walking with Vashirr (spec)

> **Requires:** Story #0 `alignment == agroman` · **Cost:** 500 FP · **1.0.0:** ✅
> **Status:** ✅ Playable in `BadOneRooms.swift`
> **Tone:** Uncomfortable witness — PC sees discipline and doctrine, not redemption.

---

## Logline

After choosing **FOLLOW**, the scout marches with Agroman column. Vashirr
assigns reconnaissance along the **northern march** corridor. PC learns how
Many Hands trains common soldiers to cast.

## Cast

| Name | Role |
|---|---|
| PC | Reluctant follower — FOLLOW path from Story #0 |
| **Vashirr** | Teacher-commander; checks whether PC believes |
| Sergeant **Dentros** (name only) | Drill instructor echo — not SoC courtyard NPC |
| Column soldiers | Pamphlets, shared rations, discipline speech |
| Mira | Absent; guilt thread via `miraStatus` |

## Beats

1. **Column march** — pamphlets, shared rations, no looting speech; soldier gossip about ridge scouts.
2. **Training yard** — low-tier battle magic demo; Paladin pairs drill; moral unease.
3. **Vashirr audience** — "Do you still think mages should gatekeep?" + recon assignment.
4. **Scout task** — REPORT truthfully vs LIE to protect Silvarium (`badOneTruthfulRecon`).
5. **Close:** PC marked agroman; unlocks Bad #2 (Cataracta periphery observer).

## Player verbs

| Room | Commands |
|---|---|
| Column | CONTINUE · TALK |
| Training yard | CONTINUE · LOOK at drill |
| Vashirr's tent | CONTINUE · TALK |
| Northern ridge | REPORT · LIE |

## Story #0 callbacks

| Flag | Effect |
|---|---|
| `miraStatus == brokeAway` | Soldier comments on partner who ran |
| LIE branch | Mira memory — bought Silvarium a week |

## Rooms

| ID | Type | Status |
|---|---|---|
| `badOneColumn` | logic | ✅ |
| `badOneTraining` | logic | ✅ |
| `badOneAudience` | logic | ✅ |
| `badOneRecon` | logic (branch) | ✅ |
| `badOneEpilogue` | logic | ✅ |

## Links

[Vashirr doctrine](../VASHIRR.md) · [Northern march (SoC)](../sequel/rooms/northern-march.md) · [margin-i Paladin Zero](../../fiction/margin-i/i-m01-paladin-zero.html)
