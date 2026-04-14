# Tinyvania Architecture

This project is split into source-first modules under `src/` and cartridge data sections under `assets/`.

## Runtime flow

- `_init` initializes palettes, entity registry, player, and camera room state.
- `_update` updates input state, entities, and room transitions.
- `_draw` renders map layers, entity layers, and UI.

## Source layout

- `src/ecs/entities.lua`: ECS-style entity registry + component mixins.
- `src/entities/*.lua`: gameplay entity constructors (items, platforming, enemies, interactables).
- `src/effects/particle_system.lua`: particles, burst, dissolve effects.
- `src/player/*.lua`: player constants and state machine.
- `src/world/camera_map.lua`: room transitions and tile-driven spawning.
- `src/render/*.lua`: map draw + palette generation.
- `src/shared/util.lua`: utility helpers and collision primitives.
- `src/core/boot.lua`: `_init`, `_update`, `_draw`.

## Build

Run:

```powershell
./scripts/build_cart.ps1
```

Output cart:

- `build/tinyvania.p8`
