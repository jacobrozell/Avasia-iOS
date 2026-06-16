# Vashirr's Redoubt

> Final confrontation — Kaefden IV vs Vashirr (iOS authored, 2026-06-15).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `vashirrStand` |
| **Display name** | Vashirr's Redoubt |
| **Act** | IV |
| **Region** | `shore` |
| **Critical path** | **yes** |
| **iOS port** | ✅ authored |
| **Source** | `SoCVashirrStandRoom.swift` |

## Story & purpose

Shoreside portal camp. **Ideological debate** between Kaefden IV and Vashirr before
combat — Many Hands vs Restoration, classroom history, Kimious. PC class beat opens
the ward; PC fights **Vashirr's War Mage**; coalition mages bind Vashirr and collapse
the portal.

## Characters

| Name | Role |
|---|---|
| **Kaefden IV** | Coalition king; KoN protagonist |
| **Vashirr** | Sincere Many Hands leader; not redeemable |
| **War Mage** | Combat encounter |

## State flags

| Flag | Phases |
|---|---|
| `vashirrStandPhase` | `arrival` → `confrontation` → `playerBeat` → `finalCombat` → `resolution` → `done` |
| `vashirrDefeated` | After resolution |

## Prose beats (canonical)

- **Confrontation:** Kaefden accuses; Vashirr offers *one army, one law*; references teaching Kaefden.
- **Player beat:** Class-specific breach (Wolf/Bear/Fox).
- **Resolution:** War mage falls; crystal net; Vashirr bound; portal collapsed.

## Combat

| Enemy | ATK | SPD | HP |
|---|---:|---:|---:|
| Vashirr's War Mage | 11 | 8 | 28 |

+50 quest XP. Sets `vashirrDefeated`.

## Navigation

`CONTINUE` → `ageEpilogue`

## Related

[`../../VASHIRR.md`](../../VASHIRR.md) · [`mage-outpost.md`](mage-outpost.md) · [`age-epilogue.md`](age-epilogue.md)
