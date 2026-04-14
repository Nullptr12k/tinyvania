function pad(val, dig)
	local sval = tostr(val)
	while #sval < dig do
		sval = "0" .. sval
	end
	return sval
end

function rectrect(x0, y0, w0, h0, x1, y1, w1, h1)
	return
		x0 < x1 + w1 and
		x1 < x0 + w0 and
		y0 < y1 + h1 and
		y1 < y0 + h0 
end

function arectrect(a0, a1)
	return rectrect(
		a0.x, a0.y, a0.w, a0.h,
		a1.x, a1.y, a1.w, a1.h
	)
end

function prect(px, py, rx, ry, rw, rh)
	return
		px >= rx and
		px < rx + rw and
		py >= ry and
		py < ry + rh
end

function aprect(px, py, ar)
	return prect(
		px, py,
		ar.x, ar.y,
		ar.w, ar.h
	)
end

function solid_at(x, y)
	return fget(mget(x\8, y\8), 0)
end

function sign(v)
	if (v < 0) return -1
	--if (v == 0) return 0
	return 1
end

function room_x()
	return (player.x+3)\128
end

function room_y()
	return (player.y+4)\128
end

function room_pal_main()
	return palettes.map[pal_main]
end

function room_pal_sub()
	return palettes.map[pal_sub]
end

function room_pal_gem()
	return palettes.map[pal_gem]
end

function mset_redo(x, y, n)
	add(map_repls, {
		x = x,
		y = y,
		n = mget(x, y)
	})
	
	mset(x, y, n)
end

function spr_xy(n)
	return (n % 16) * 8, (n \ 16) * 8
end

function spr_mini(n, x, y)
	local sx, sy = spr_xy(n)
	
	sspr(sx, sy, 8, 8, x, y, 4, 4)
end

function apply_bob(entity, period, amp)
	entity.bob_t = t
	entity.bob_y = entity.y
	amp = amp or 1
	
	function entity:update_bob()
		local phase = ((t-self.bob_t)\period)%2
		self.y = self.bob_y + (phase == 0 and -amp or amp)
	end
end

function loop(v, a, b)
	while (v < a) do
		v += (b-a)
	end
	return (v-a)%(b-a)+a
end

function analyze_colors(n, p)
	local sx, sy = spr_xy(n)
	local result = {}
	
	for i=sx,sx+7 do
		for j=sy,sy+7 do
			local c = sget(i, j)
			
			if p then
				c = p[c]
			end
			
			add(result, c)
		end
	end
	
	return result
end

function analyze_colors_tile(n)
	local p = room_pal_main()
	if fget(n,7) then
		p = room_pal_sub()
	end
	if fget(n,6) then
		p = room_pal_gem()
	end
	
	return analyze_colors(n, p)
end

function find_first_solid_mask(tx, ty, skip0, skip1)
	for j=ty+1,ty+16 do
		local mask = mget(tx, j)
		if mask ~= skip0 and mask ~= skip1 and fget(mask, 0) then
			return mask, j
		end
	end
end

