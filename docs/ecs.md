# Entity Component System Notes

The runtime uses lightweight entity composition.

## Registry

`entities` stores indexed lists for behavior groups:

- `all`
- `draw`
- `update`
- `update_hp`
- `collide_player`
- `collide_enemy`
- `ladders`
- `enemies`

## Base entity

`new_entity(x, y, w, h)` creates an entity and attaches metatable hooks.

Metatable `__newindex` auto-registers an entity in specialized lists when it gains behavior keys (`draw`, `update`, `collide_*`, etc).

## Mixins

- `entity_add_draw(entity, sprite)` adds animated draw behavior.
- `entity_add_hp(entity, hp, iframes, callback)` adds HP/iframes/damage behavior.

## Lifecycle

- `update_entities()` runs `update` and `update_hp`, then collision passes.
- `draw_entities_back()`, `draw_entities()`, `draw_entities_front()` render layers.
- `entity:delete()` removes an entity from all registry lists.
