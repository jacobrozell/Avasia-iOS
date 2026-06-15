# Room Spec Index — Sword of Courage

Standard: [`../ROOM_SPEC_STANDARD.md`](../ROOM_SPEC_STANDARD.md) · Global: [`_global.md`](_global.md) · Future: [`future/README.md`](future/README.md)

| Spec | Swift ID | Type | Act | Path | iOS |
|---|---|---|---|---|---|
| [Housing](cataracta-housing.md) | `cataractaHousing` | link | I | hub | ✅ |
| [North](cataracta-north.md) | `cataractaNorth` | link | I | hub | ✅ |
| [Shopping](cataracta-shopping.md) | `cataractaShopping` | link | I | hub | ✅ |
| [Hunter's Path](cataracta-hunter-path.md) | `cataractaHunterPath` | logic | I | optional | ✅ |
| [Barracks](cataracta-barracks.md) | `cataractaBarracks` | logic | I | optional | ✅ |
| [Athalos' House](cataracta-athalos.md) | `cataractaAthalos` | logic | I | optional | ✅ |
| [Ulric's Blacksmith](cataracta-blacksmith.md) | `cataractaBlacksmith` | logic | I | optional | ✅ |
| [Doran's Pier](cataracta-pier.md) | `cataractaPier` | logic | I | optional | ✅ |
| [Fishing](cataracta-fishing.md) | `cataractaFishing` | logic | I | optional | ✅ |
| [Castle Garden](cataracta-garden.md) | `cataractaGarden` | logic | I | optional | ✅ (wired N from North) |
| [Courtyard](cataracta-courtyard.md) | `cataractaCourtyard` | logic | II | **critical** | ✅ |
| [Portal Room](portal-room.md) | `portalRoom` | logic | III | **critical** | ✅ |
| [Library](library.md) | `library` | logic | III | **critical** | ✅ |
| [West Hallway](west-hallway.md) | `westHallway` | link | III | hub | ✅ |
| [Throne Room](throne-room.md) | `throneRoom` | logic | III | **critical** | ✅ audience |
| [Aylova War Camp](aylova-war-camp.md) | `aylovaWarCamp` | logic | IV | **critical** | ✅ |
| [Northern March](northern-march.md) | `northernMarch` | logic | IV | **critical** | ✅ |
| [Oceandale Ridge](oceandale-front.md) | `oceandaleFront` | logic | IV | **critical** | ✅ |
| [Mage Outpost](mage-outpost.md) | `mageOutpost` | logic | IV | **critical** | ✅ |
| [Vashirr's Redoubt](vashirr-stand.md) | `vashirrStand` | logic | IV | **critical** | ✅ |
| [Age Epilogue](age-epilogue.md) | `ageEpilogue` | logic | IV | ending | ✅ |

## Quest chains (optional Act I)

```
Shopping ──E──► Ulric (blacksmith) ──► Doran (pier) ──► Fishing
    │
    ├──S──► Athalos (flavor only)
    └──N──► Pier (direct; 15g path is dead code — see pier spec)
```

## Critical path spine

```
Housing → … → Oceandale → Mage Outpost → Vashirr's Redoubt → Aylova epilogue ✅
```

## Rooms not in source

Oceandale battle through epilogue — ✅. Cataracta ruins revisit — optional future.
