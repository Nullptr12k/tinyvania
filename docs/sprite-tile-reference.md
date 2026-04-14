# Sprite/Tile Reference

## Palette Table Locations (`init_palettes`)
These are sprite-sheet data regions sampled with `sget(x, y)` via `generate_palette(sx, sy, cols, opts)`.

| Table | Origin (x,y) | Orientation | Entries (`opts`) | Colors per Entry (`cols`) | Notes |
|---|---|---|---:|---:|---|
| `palettes.map` | `(0,0)` | Horizontal | 6 | 5 | Used for various room palettes |
| `palettes.wands` | `(0,5)` | Horizontal | 5 | 3 | - |
| `palettes.flowers` | `(0,8)` | Horizontal | 5 | 4 | - |
| `palettes.coins` | `(5,8)` | Horizontal | 3 | 4 | - |
| `palettes.gems` | `(0,16)` | Horizontal | 6 | 3 | - |
| `palettes.slimes` | `(64,32)` | Horizontal | 5 | 4 | - |
| `palettes.skeletons` | `(64,36)` | Horizontal | 5 | 3 | - |
| `palettes.potions` | `(0,6)` | Vertical | 5 | 2 | - |

## Animation Sets
- Heart pickup: `20-25`
- Coin pickup: `26-31`
- Slash horizontal: `67-68`
- Slash vertical: `69-70`
- Slime: `73-74`
- Skeleton: `75-76`

## Flag Legend
- `0`: Is solid
- `1`: Undefined
- `2`: Undefined
- `3`: Is solid for blocking enemy pathing (for tiles that are otherwise nonsolid)
- `4`: Is a ladder
- `5`: Is a key item
- `6`: Uses room gem palette
- `7`: Uses room subpalette
- Tiles without flags `6` or `7` use the room main palette.
- Palette flags (`6`/`7`) apply to static map tiles.

## Sprite Index (0-127)
| ID | Name | Status | Kind | Flags | Code Usage | Notes |
|---|---|---|---|---|---|---|
| 0 | Palette Data | Used | Utility | - | - | Used in map editor as empty space |
| 1 | Sword Item | Used | Both | 5 | draw_inventory, player:has(1), item use gate | Spawner marker |
| 2 | Axe Item | Used | Both | 5 | draw_inventory, player:has(2) | Spawner marker |
| 3 | Wand Item | Used | Both | 5 | draw_inventory, player:has(3) | Spawner marker |
| 4 | Orb Item | Used | Both | 5 | draw_inventory, player:has(4) | Spawner marker |
| 5 | Bow Item | Used | Both | 5 | draw_inventory, player:has(5) | Spawner marker |
| 6 | Bomb Item | Used | Both | 5 | draw_inventory, player:has(6) | Spawner marker |
| 7 | Potion Item 1 | Used | Both | 5 | draw_inventory, player:has(7) | Spawner marker |
| 8 | Key Item | Used | Both | 5 | draw_inventory, player:has(8) | Spawner marker |
| 9 | Ring Item | Used | Both | 5 | draw_inventory, player:has(9) | Spawner marker |
| 10 | Skull Item | Used | Both | 5 | draw_inventory, player:has(10), new_key_item | Spawner marker; Joke item; Subject to change |
| 11 | Book Item | Used | Both | 5 | draw_inventory, player:has(11) | Spawner marker |
| 12 | Helmet Item | Used | Both | 5 | draw_inventory, player:has(12) | Spawner marker |
| 13 | Eggplant Item | Used | Both | 5 | draw_inventory, player:has(13), new_key_item | Spawner marker; Joke item; Subject to change |
| 14 | Potion Item 2 | Reserved | Both | 5 | - | - |
| 15 | Potion Item 3 | Reserved | Both | 5 | - | - |
| 16 | Palette Data | Used | Utility | - | - | Used in map editor to change a room's main palette |
| 17 | Arrow Item | Reserved | Sprite | - | - | - |
| 18 | Large Gem | Reserved | Sprite | - | - | - |
| 19 | Small Gem | Reserved | Sprite | - | - | - |
| 20 | Heart Pickup | Used | Both | - | new_heart, init_map_entities tile 20 | Spawner marker |
| 21 | Heart Pickup | Used | Sprite | - | - | - |
| 22 | Heart Pickup | Used | Sprite | - | - | - |
| 23 | Heart Pickup | Used | Sprite | - | - | - |
| 24 | Heart Pickup | Used | Sprite | - | - | - |
| 25 | Heart Pickup | Used | Sprite | - | - | - |
| 26 | Coin Pickup | Used | Both | - | new_coin, init_map_entities tile 26, draw_ui coin icon | Spawner marker |
| 27 | Coin Pickup | Used | Sprite | - | - | - |
| 28 | Coin Pickup | Used | Sprite | - | - | - |
| 29 | Coin Pickup | Used | Sprite | - | - | - |
| 30 | Coin Pickup | Used | Sprite | - | - | - |
| 31 | Coin Pickup | Used | Sprite | - | - | - |
| 32 | Blank | Used | Utility | - | - | Used in map editor to change a room's subpalette; contents subject to change |
| 33 | Unassigned | Unused | Unknown | - | - | - |
| 34 | Shaped Tile | Used | Tile | 0,7 | - | - |
| 35 | Smooth Tile | Used | Tile | 0 | - | - |
| 36 | Bricks | Used | Tile | 0 | - | - |
| 37 | Fading Tile | Used | Tile | 0,7 | - | - |
| 38 | Crumble Tile A | Used | Tile | 0,7 | new_crumble, init_map_entities tile 38 | Crumble state machine tile; Copies tile below |
| 39 | Crumble Tile B | Used | Tile | 7 | new_crumble, init_map_entities tile 39 | Crumble state machine tile; Do not use in editor |
| 40 | Wall Torch | Used | Both | - | new_torch, init_map_entities tile 40 | Spawner marker |
| 41 | Flat Tile | Used | Tile | 0 | - | - |
| 42 | Cracked Tile 1 | Used | Tile | 0 | - | - |
| 43 | Cracked Tile 2 | Used | Tile | 0 | - | - |
| 44 | Flower | Reserved | Tile | - | - | - |
| 45 | Pillar | Used | Tile | 0,7 | - | - |
| 46 | Fake Wall Marker | Used | Tile | 3 | new_fake, init_map_entities tile 46 | Walk-through tile; Copies tile below |
| 47 | Breakable Marker | Used | Tile | - | new_breakable, init_map_entities tile 47 | Breakable tile; Copies tile below |
| 48 | Debug Cursor | Used | Utility | - | _draw debug cursor spr(48,mx,my) | Used in map editor to change a room's gem palette |
| 49 | UI Bars and Misc. Item | Used | Sprite | - | - | Misc. Item subject to change |
| 50 | Apple | Reserved | Sprite | - | - | - |
| 51 | Bread | Reserved | Sprite | - | - | - |
| 52 | Meat | Reserved | Sprite | - | - | - |
| 53 | Gate Off | Used | Tile | 3,6 | new_button rewrite target | Replaces Gate On on button press; Do not use in editor |
| 54 | Gate On | Used | Tile | 0,6 | new_button scans room for 54 | Converted to Gate Off on button press. |
| 55 | Button Unpressed | Used | Tile | 6 | new_button, init_map_entities tile 55 | Converted to Button Pressed when pressed |
| 56 | Button Pressed | Used | Tile | 6 | new_button sets tile 56 | Do not use in editor |
| 57 | Unassigned | Unused | Unknown | - | - | - |
| 58 | Ladder | Used | Tile | 4,7 | new_ladder_extension sets mset(i,j,58) | - |
| 59 | Ladder Extension | Used | Both | 4,7 | new_ladder_extension, init_map_entities tile 59 | Extends through above block |
| 60 | Unassigned | Unused | Unknown | 0,7 | - | - |
| 61 | Pillar Base | Used | Tile | 0,7 | - | - |
| 62 | Spikes Horizontal | Used | Tile | 6 | new_spikes, init_map_entities tile 62 | Attaches to solid block above or below |
| 63 | Spikes Vertical | Used | Tile | 6 | new_spikes, init_map_entities tile 63 | Attaches to solid block to left or right |
| 64 | Player | Used | Both | - | pconst.pspr, init_player, actor draw | Spawner marker |
| 65 | Unassigned | Unused | Unknown | - | - | - |
| 66 | Secret Ladder | Used | Utility | 4 | new_secret_ladder, init_map_entities tile 66 | Invisible; Extends through above solid block |
| 67 | Slash Horizontal | Used | Sprite | - | new_slash | - |
| 68 | Slash Horizontal | Used | Sprite | - | - | - |
| 69 | Slash Vertical | Used | Sprite | - | new_slash | - |
| 70 | Slash Vertical | Used | Sprite | - | - | - |
| 71 | Enemy Turn Point | Used | Tile | 3 | - | - |
| 72 | Difficulty Marker | Used | Utility | - | init_map_entities special handler | Increments difficulty for next enemy |
| 73 | Slime | Used | Both | - | new_slime, init_map_entities tile 73/74 | Spawner marker |
| 74 | Slime | Used | Sprite | - | new_slime, init_map_entities tile 73/74 | - |
| 75 | Skeleton | Used | Both | - | new_skeleton, init_map_entities tile 75/76 | Spawner marker |
| 76 | Skeleton | Used | Sprite | - | new_skeleton, init_map_entities tile 75/76 | - |
| 77 | Bone Projectile | Used | Sprite | - | new_bone | - |
| 78 | Unassigned | Unused | Unknown | - | - | - |
| 79 | Unassigned | Unused | Unknown | - | - | - |
| 80 | Unassigned | Unused | Unknown | - | - | - |
| 81 | Unassigned | Unused | Unknown | - | - | - |
| 82 | Unassigned | Unused | Unknown | - | - | - |
| 83 | Unassigned | Unused | Unknown | - | - | - |
| 84 | Unassigned | Unused | Unknown | - | - | - |
| 85 | Unassigned | Unused | Unknown | - | - | - |
| 86 | Unassigned | Unused | Unknown | - | - | - |
| 87 | Unassigned | Unused | Unknown | - | - | - |
| 88 | Unassigned | Unused | Unknown | - | - | - |
| 89 | Unassigned | Unused | Unknown | - | - | - |
| 90 | Unassigned | Unused | Unknown | - | - | - |
| 91 | Unassigned | Unused | Unknown | - | - | - |
| 92 | Unassigned | Unused | Unknown | - | - | - |
| 93 | Unassigned | Unused | Unknown | - | - | - |
| 94 | Unassigned | Unused | Unknown | - | - | - |
| 95 | Unassigned | Unused | Unknown | - | - | - |
| 96 | Unassigned | Unused | Unknown | - | - | - |
| 97 | Unassigned | Unused | Unknown | - | - | - |
| 98 | Unassigned | Unused | Unknown | - | - | - |
| 99 | Unassigned | Unused | Unknown | - | - | - |
| 100 | Unassigned | Unused | Unknown | - | - | - |
| 101 | Unassigned | Unused | Unknown | - | - | - |
| 102 | Unassigned | Unused | Unknown | - | - | - |
| 103 | Unassigned | Unused | Unknown | - | - | - |
| 104 | Unassigned | Unused | Unknown | - | - | - |
| 105 | Unassigned | Unused | Unknown | - | - | - |
| 106 | Unassigned | Unused | Unknown | - | - | - |
| 107 | Unassigned | Unused | Unknown | - | - | - |
| 108 | Unassigned | Unused | Unknown | - | - | - |
| 109 | Unassigned | Unused | Unknown | - | - | - |
| 110 | Unassigned | Unused | Unknown | - | - | - |
| 111 | Unassigned | Unused | Unknown | - | - | - |
| 112 | Unassigned | Unused | Unknown | - | - | - |
| 113 | Unassigned | Unused | Unknown | - | - | - |
| 114 | Unassigned | Unused | Unknown | - | - | - |
| 115 | Unassigned | Unused | Unknown | - | - | - |
| 116 | Unassigned | Unused | Unknown | - | - | - |
| 117 | Unassigned | Unused | Unknown | - | - | - |
| 118 | Unassigned | Unused | Unknown | - | - | - |
| 119 | Unassigned | Unused | Unknown | - | - | - |
| 120 | Unassigned | Unused | Unknown | - | - | - |
| 121 | Unassigned | Unused | Unknown | - | - | - |
| 122 | Unassigned | Unused | Unknown | - | - | - |
| 123 | Unassigned | Unused | Unknown | - | - | - |
| 124 | Unassigned | Unused | Unknown | - | - | - |
| 125 | Unassigned | Unused | Unknown | - | - | - |
| 126 | Unassigned | Unused | Unknown | - | - | - |
| 127 | Invisible Wall | Used | Tile | 0 | - | - |
