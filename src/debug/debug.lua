debug_mode = false
debug_text = ""
mx = 0
my = 0
mb = 0

function debug_init()
	if debug_mode then
		-- enable cursor
		poke(0x5f2d, 0x1)
	end
end

function debug_update()
	if not debug_mode then
		return
	end
	
	mx = stat(32)
	my = stat(33)
	mb = stat(34)
end

function debug_try_player_teleport(player_entity)
	if not debug_mode then
		return false
	end
	
	if mb & 1 == 0 then
		return false
	end
	
	player_entity.x = mx-3 + room_x()*128
	player_entity.y = my-4 + room_y()*128
	player_entity.dx = 0
	player_entity.dy = 0
	return true
end

function debug_draw_hitboxes()
	for entity in all(entities.all) do
		rect(
			entity.x, entity.y,
			entity.x + entity.w-1,
			entity.y + entity.h-1, 11
		)
		
		pset(
			entity.x + entity.w\2,
			entity.y + entity.h\2,
			8
		)
		
		if entity.hp then
			print(
				entity.hp .. " " .. entity.iframes,
				entity.x,
				entity.y-5,
				7
			)
		end
	end
end

function debug_draw_world()
	if not debug_mode then
		return
	end
	
	debug_draw_hitboxes()
end

function debug_draw_overlay()
	if not debug_mode then
		return
	end
	
	spr(48, mx, my)
	print(debug_text, 8, 64, 7)
end
