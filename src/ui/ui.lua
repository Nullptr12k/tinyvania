function draw_ui()
	draw_bar(
		8, 24, 5,
		4, 4,
		player.max_hp,
		player.hp
	)
	
	draw_bar(
		8, 28, 4,
		4, 8, 5, 5
	)
	
	draw_inventory()
	
	local money = pad(player.money, 3)
	
	print_shadow(
		money,
		128-4*3-8-4, 1+4,
		9, 4
	)
	spr(26+(t\4)%6, 128-8-4, 0+4)
end

function draw_bar(sx, sy, sh, dx, dy, tw, pw)
	sspr(sx, sy, 1, sh, dx, dy)
	sspr(sx+1, sy, 1, sh, dx+1, dy, pw, sh)
	sspr(sx+2, sy, 1, sh, dx+pw+1, dy, tw-pw, sh)
	sspr(sx, sy, 1, sh, dx+tw+1, dy)
end

function draw_inventory()
	for i=1,13 do
		if not player:has(i) then
			goto continue
		end
		
		local x = (i-1)*8+47
		local y = 0
		
		if i > 6 then
			x -= 48
			y = 8
		end
		
		spr(i, x, y)
		
		::continue::
	end
end

function print_shadow(val, x, y, c0, c1)
	color(c1)
	print(val, x, y+1)
	color(c0)
	print(val, x, y)
end



