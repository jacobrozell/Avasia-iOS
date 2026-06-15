# Avasia: iOS

An iOS remake of **Avasia: King of Nacastrum** — a text-based fantasy adventure
in which an amnesiac mage must gather three lost spells, unlock the floating city
of Nacastrum, and reunite a people scattered by a usurper king.

This repository currently holds the **design documentation** for a faithful port
of the original game ([Avasia-KoN](https://github.com/jacobrozell/avasia-kon)).
Game code will follow.

## Documentation

See [`docs/`](docs/README.md):

- **[Story bible](docs/STORY.md)** — lore, plot, world, characters, tone.
- **[Engine spec](docs/ENGINE_SPEC.md)** — how the original works + the target
  iOS architecture.
- **[World map](docs/WORLD_MAP.md)** — areas, exits, gates, and the walkthrough.

## Goal

Faithful first: reproduce the original's content, pacing, and progression
exactly, on a clean, testable Swift/SwiftUI engine. See the fidelity checklist in
`docs/ENGINE_SPEC.md` §B.8.

## Credits

Based on the original *Avasia: King of Nacastrum* by Jacob Rozell and
contributors (Chase Pernatozzi, Devan Deloach, Joshua Rogers).
