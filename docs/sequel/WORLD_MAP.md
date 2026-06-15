# Avasia: Sword of Courage — World Map

> Room graph from the **original Python prototype** (`Avasia-SoC/`). No rooms
> beyond what existed in source. **Bold** = logic room (`on_enter`).

---

## Overview

```
[CATARACTA — pre-courtyard]
         │
    Courtyard ★ ──► massacre ──► c_portal_room ★
                                    │
                               n_library ★
                                    │
                              west_hallway
                              E: throne_room ★
                                    │
                               MARCH (audience done)
                                    ▼
                            aylova_war_camp ★
                                    │
                                  MARCH
                                    ▼
                            northern_march ★
                                    │
                                    ▼
                            oceandale_front ★
                                    │
                                 ADVANCE
                                    ▼
                             mage_outpost ★
                                    │
                                  MARCH
                                    ▼
                             vashirr_stand ★
                                    │
                                 CONTINUE
                                    ▼
                             soc_epilogue ★ (ending)
```

---

## Cataracta

| Room ID | Type | Notes |
|---|---|---|
| `Cataracta_Housing` | Link | Start after intro |
| `Cataracta_North` | Link | E → courtyard |
| `Cataracta_Shopping` | Link | Pier, Athalos, Ulric |
| `Cataracta_Hunter_Path` | Logic | Redirect to courtyard |
| `Cataracta_Barracks` | Logic | Guards turn you away |
| `Cataracta_Athalos` | Logic | Shopkeeper scene |
| `Cataracta_Blacksmith` | Logic | Ulric → Doran quest |
| `Cataracta_Pier` | Logic | Fishing fee / brother chain |
| `Cataracta_Fishing` | Logic | Minigame |
| `Cataracta_Garden` | Logic | Fountain easter egg; **iOS: N from North** |
| **`Cataracta_Courtyard`** | Logic | Class select + massacre → `c_portal_room` |

### Housing exits

N → North · W → Hunter Path · E → Shopping

### North exits

N → Garden (iOS) · E → Courtyard · S → Housing · W → Barracks

---

## Nacastrum Castle (post-massacre)

| Room ID | Type | Notes |
|---|---|---|
| **`c_portal_room`** | Logic | Vent / books puzzle → library |
| **`n_library`** | Logic | Purple-robed woman → alert king |
| `west_hallway` | Link | N library · E throne · W portal |
| **`throne_room`** | Logic | **Stub** — no branches in source |

---

## Critical path (original)

1. Housing → North → Courtyard (class + massacre).
2. Portal room: search → vent/books → library.
3. Library → south → hallway → east → throne → **MARCH** → Aylova camp → northern march → Oceandale (teaser).

---

## iOS-authored Act IV (complete)

`aylova_war_camp` → `northern_march` → `oceandale_front` → `mage_outpost` → `vashirr_stand` → `soc_epilogue`

Optional future: `cataracta_ruins` revisit.

Per-room detail for all **15 source rooms**: [`rooms/README.md`](rooms/README.md).
