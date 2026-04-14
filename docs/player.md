# Player System

Player logic is in `src/player/player.lua` and uses constants from `src/player/constants.lua`.

## States

- `pconst.normal`
- `pconst.ladder`
- `pconst.cutscene`

## Core responsibilities

- Horizontal and vertical movement with gravity/coyote-time.
- Ladder enter/exit and alignment logic.
- Inventory ownership (`player.items`) and item-use handling.
- Damage/iframes via `entity_add_hp`.
