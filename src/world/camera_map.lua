repl = {
	[20] = new_heart,
	[26] = new_coin,
	[38] = new_crumble,
	[39] = new_crumble,
	[40] = new_torch,
	[46] = new_fake,
	[47] = new_breakable,
	[55] = new_button,
	[59] = new_ladder_extension,
	[62] = new_spikes,
	[63] = new_spikes,
	[66] = new_secret_ladder,
	
	[72] = function()
		diff_off += 1
	end,
	
	[73] = new_slime,
	[74] = new_slime,
	[75] = new_skeleton,
	[76] = new_skeleton,
}

function init_camera()
	map_repls = {}
	
	cx = room_x()
	cy = room_y()
	
	room_transition(
		-1, -1,
		room_x(), room_y()
	)
end

function room_transition(x0, y0, x1, y1)
	cx = x1
	cy = y1
	
	clear_entities()
	
	if x0 ~= -1 then
		reset_map(x0, y0)
	end
	
	init_map_data(x1, y1)
	init_map_entities(x1, y1)
end

function reset_map(x, y)
	for repl in all(map_repls) do
		mset(repl.x, repl.y, repl.n)
	end
	
	map_repls = {}
end

function init_map_data(x, y)
	pal_main = 1
	pal_sub = 2
	pal_gem = 5
	
	local mode = 0
	
	for i=x*16,x*16+15 do
		for j=y*16,y*16+15 do
			local tile = mget(i, j)
			
			if tile == 16 then
				pal_main += 1
				mset_redo(i, j, 0)
			end
			
			if tile == 32 then
				pal_sub += 1
				mset_redo(i, j, 0)
			end
			
			if tile == 48 then
				pal_gem += 1
				mset_redo(i, j, 0)
			end
			
			tile -= 75
		end
	end
	
	while pal_main > 6 do
		pal_main -= 6
	end
	
	while pal_sub > 6 do
		pal_sub -= 6
	end
	
	while pal_gem > 6 do
		pal_gem -= 6
	end
end

function init_map_entities(x, y)
	diff_off = 1
	
	-- for each cell
	for i=x*16,x*16+15 do
		for j=y*16,y*16+15 do
			local n = mget(i, j)
			
			-- specific replacements
			if repl[n] then
				mset_redo(i, j, 0)
				repl[n](i*8, j*8, n)
			end
			
			-- key item replacements
			if fget(n, 5) then
				mset_redo(i, j, 0)
				new_key_item(i*8, j*8, n)
			end
		end
	end
end

function update_camera()
	local nx = room_x()
	local ny = room_y()
	
	if nx ~= cx or ny ~= cy then
		room_transition(cx, cy, nx, ny)
	end
end



