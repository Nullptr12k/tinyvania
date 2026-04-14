debug_mode = false

function _init()
	if debug_mode then
		-- enable cursor
		poke(0x5f2d, 0x1)
	end
	
	-- global timer
	t = 0
	
	debug = ""
	
	-- init other modules
	init_palettes()
	init_entities()
	init_player()
	init_camera()
end

function _update()
	mx = stat(32)
	my = stat(33)
	mb = stat(34)
	
	--[[
	if mb ~= 0 then
		dissolve_all()
	end]]
	
	-- entities
	update_entities()
	
	update_camera()
end

function _draw()
	cls(0)
	
	camera(128 * cx, 128 * cy)
	
	-- map
	draw_map()
	
	-- background entities
	draw_entities_back()
	
	-- mid-scene entities
	draw_entities()
	
	-- front entities
	draw_entities_front()
	
	if debug_mode then
		-- debug
		draw_hitboxes()
	end
	
	camera()
	
	-- ui
	if not diss then
		draw_ui()
	end
	
	if player:has(13) then
		pal(palettes.eggplant, 1)
	end
	
	if debug_mode then
		-- draw cursor
		spr(48, mx, my)
		
		--[[print_shadow(
			debug,
			64-2*#debug + room_x()*128,
			4 + room_y()*128,
			7, 5
		)]]
		print(debug, 8, 64, 7)
	end
	
	-- global timer
	t += 1
end



