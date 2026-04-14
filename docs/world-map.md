# World And Map Flow

World state is in `src/world/camera_map.lua`.

## Room lifecycle

- `room_x()/room_y()` derive room from player position.
- `update_camera()` detects room changes.
- `room_transition()` clears transient entities and initializes room data.

## Tile-driven spawning

`init_map_entities()` scans the room tile window and dispatches constructors from a tile->factory table, including enemies and interactables.

## Map replacement tracking

`mset_redo()` records tile changes in `map_repls` so map edits can be restored on transition.
