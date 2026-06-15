# Future Room Specs — Sword of Courage

> **Design intent only** — not in `Avasia-SoC/` Python source. Use the same schema
> as [`../ROOM_SPEC_STANDARD.md`](../ROOM_SPEC_STANDARD.md) when authoring.
> Do not treat these as implemented gameplay.

---

## Index

| Spec | Proposed ID | Act | Status |
|---|---|---|---|
| [Throne audience](future/throne-audience.md) | `throne_room` (extension) | III | design |
| [Aylova war camp](future/aylova-war-camp.md) | `aylova_war_camp` | IV | ✅ promoted → [`../aylova-war-camp.md`](../aylova-war-camp.md) |
| [Northern march](future/northern-march.md) | `northern_march` | IV | ✅ promoted → [`../northern-march.md`](../northern-march.md) |
| [Oceandale front](future/oceandale-front.md) | `oceandale_front` | IV | partial → [`../oceandale-front.md`](../oceandale-front.md) |
| [Cataracta ruins revisit](future/cataracta-ruins.md) | `cataracta_ruins` | IV–V | design optional |

## Principles (from [`../ROADMAP.md`](../ROADMAP.md))

- SoC must **resolve the Vashirr war** in text before game 3 (2D).
- Combat: **authored encounters**, not random grind.
- Kaefden IV = KoN protagonist; Druid PC is ground-level soldier.
- Block peaceful Cataracta after Act II (partially done in iOS).

## When to promote a spec

1. Write Python or Swift scene matching the spec.
2. Move file from `future/` to `rooms/` and update metadata **iOS port**.
3. Add `SoCRoomID` case + register in `SoCWorld`.
