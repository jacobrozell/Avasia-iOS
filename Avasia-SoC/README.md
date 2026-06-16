# Avasia: Blade of Courage

Python reference build of **Avasia #2** — imported from
[github.com/jacobrozell/Avasia](https://github.com/jacobrozell/Avasia).

**This is the original 2019-era prototype as-is** (plus a few dev fixes). Content
stops at the **throne room stub** in Nacastrum castle.

Design docs: [`../docs/sequel/`](../docs/sequel/README.md)

iOS: selectable from the saga home screen; Swift port in `Sources/AvasiaSoCEngine/`.

## Run (Python)

```bash
python3 -m pip install colorama
python3 game.py
```

## Source scope (what existed)

| Area | Status in original |
|---|---|
| Cataracta (pre-attack) | 11 rooms — explorable |
| Courtyard | Class select + Vashirr massacre → portal |
| Nacastrum castle | Portal puzzle, library, hallway, **throne stub** |

## Layout

`Cataracta/` · `Nacastrum/` · `Logic/` · `Combat/` · `Player/` · `Room/` · `Enemy/` · `Items/`
