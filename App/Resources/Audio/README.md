# Audio resources

Drop audio files here. The app loads them by base name (no extension); accepted
formats: `.m4a`, `.mp3`, `.caf`, `.wav`. Missing files are silently ignored.

Expected names (see `docs/ASSETS.md` for the full manifest):

- Ambient loops: `amb_oceandale`, `amb_beach`, `amb_graveyard`, `amb_splitpath`,
  `amb_mountain`, `amb_cave`, `amb_forest`, `amb_tree`, `amb_road`, `amb_shore`,
  `amb_nacastrum`, `amb_aylova`
- Music: `music_title`
- SFX: `sfx_item`, `sfx_spell`, `sfx_death`, `sfx_win`, `sfx_move`
- Combat SFX: `sfx_hit`, `sfx_miss`, `sfx_block`, `sfx_heal`, `sfx_combat_start`, `sfx_victory`

Regenerate combat placeholders: `python3 scripts/generate_combat_sfx.py`
