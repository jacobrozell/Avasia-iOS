# Aylova War Camp

> Act IV coalition muster (iOS authored, 2026-06-15).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `aylovaWarCamp` |
| **Python `current_room_id`** | — (not in source) |
| **Display name** | Aylova War Camp |
| **Room type** | logic |
| **Act** | IV |
| **Region** | `aylova` |
| **Critical path** | **yes** |
| **iOS port** | ✅ authored |
| **Source file** | — · `SoCAylovaWarCampRoom.swift` |

## Story & purpose

Coalition muster after throne audience. PC receives war briefing, provisions from Thekia,
and deploys north with their class-assigned unit.

## Characters

| Name | Role | Notes |
|---|---|---|
| Coalition Sergeant | Field command | Briefing officer |
| **Thekia** | Quartermaster | Provisions potion + class gear |
| Cataractan remnant | Fellow soldiers | March column |

## Prerequisites

- `throneAudience` complete
- `warCampBriefed` from throne mobilization

## State flags

| Flag | When |
|---|---|
| `warCampPhase` | Scene machine |
| `aylovaProvisioned` | After quartermaster (+1 potion) |
| `aylovaMusterComplete` | Ready to march |

## Player options

| Input | Phase | Outcome |
|---|---|---|
| `CONTINUE` | each phase | Briefing → quartermaster → deploy |
| `QUARTERMASTER` | briefing | Skip to provisioning |
| `MARCH` / `NORTH` | ready | Auto-march to `northernMarch` |

## Navigation

→ `northernMarch` on final CONTINUE or MARCH

## Related

[`northern-march.md`](northern-march.md) · [`throne-room.md`](throne-room.md)
