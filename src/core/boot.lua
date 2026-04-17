function _init()
	-- global timer
	t = 0
	
	debug_init()
	
	-- init other modules
	init_palettes()
	init_entities()
	init_player()
	init_camera()
end

function _update()
	debug_update()
	
	--[[
	if mb ~= 0 then
		dissolve_all()
	end]]
	
	if debug_handle_player_teleport() then
		return
	end
	
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
	
	debug_draw_world()
	
	camera()
	
	-- ui
	if not diss then
		draw_ui()
	end
	
	if player:has(13) then
		pal(palettes.eggplant, 1)
	end
	
	debug_draw_overlay()
	
	-- global timer
	t += 1
end



