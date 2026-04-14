function init_palettes()
	palettes = {}
	
	poke(0x5f5f, 0x30)
	
	for i=0,14 do
		poke(0x5f10+i, i)
	end
 poke(0x5f1f, 128)
 
	for i=0,15 do
 	poke(0x5f60+i, 0x00)
 end
 
 poke(0x5f60, 0x01, 0x81)
	
	--[[
	for i=0,14 do
		poke(0x5f70+i, 0b01000000)
	end
	
	poke(0x5f71, 0)--]]
	
	poke(0x5f70, 0x40)
	
	palettes.map =
		generate_palette(
			0, 0, 5, 6
		)
	
	palettes.wands =
		generate_palette(
			0, 5, 3, 5
		)
	
	palettes.flowers =
		generate_palette(
			0, 8, 4, 5
		)
	
	palettes.coins =
		generate_palette(
			5, 8, 4, 3
		)
	
	palettes.gems =
		generate_palette(
			0, 16, 3, 6
		)
	
	palettes.slimes =
		generate_palette(
			64, 32, 4, 5
		)
	
	palettes.skeletons =
		generate_palette(
			64, 36, 3, 5
		)
	
	palettes.eggplant = {
 	[0]=0x00, 0x02, 0x02, 0x02,
 	0x8d, 0x02, 0x06, 0x07,
 	0x0e, 0x0e, 0x0e, 0x06,
 	0x06, 0x8d, 0x0e, 0x80
	}
	
	local _sget = sget
	sget = function(x, y)
		return _sget(y, x)
	end
	
	palettes.potions =
		generate_palette(
			0, 6, 2, 5
		)
	
	sget = _sget
end

function generate_palette(sx, sy, cols, opts)
	local pal_table = {}
	
	for o=1,opts do
		pal_table[o] = {}
		
		for i=0,15 do
			pal_table[o][i] = i
		end
		
		for c=sy,sy+cols-1 do
			local key = sget(sx, c)
			local val = sget(sx+o-1, c)
			
			pal_table[o][key] = val
		end
	end
	
	return pal_table
end



