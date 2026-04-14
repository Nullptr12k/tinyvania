function draw_map()
	local tx = cx*16
	local ty = cy*16+2
	local sx = cx*128
	local sy = cy*128+16
	
	-- main color map
	pal(room_pal_main())
	map(
		tx, ty, sx, sy,
		16, 16
	)
	
	-- sub color map
	pal(room_pal_sub())
	map(
		tx, ty, sx, sy,
		16, 16, 0x80
	)
	
	-- puzzle color map
	pal(room_pal_gem())
	map(
		tx, ty, sx, sy,
		16, 16, 0x40
	)
	
	-- reset palette
	pal(0)
end

function draw_hitboxes()
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



