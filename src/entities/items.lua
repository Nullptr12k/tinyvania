function new_slash(xoff, yoff, dir, fp, parent)
	local slash = new_entity(
		player.x+xoff,
		player.y+yoff,
		8, 6
	)
	
	slash.xoff = xoff
	slash.yoff = yoff
	
	slash.life = 3
	
	entity_add_draw(slash, 67)
	slash.af = 3
	slash.as = .5
	slash.front = true
	slash.dir = dir
	
	if dir == 1 or dir == 3 then
		slash.n = 67
		slash.vflip = fp
		slash.sh = .75
		slash.hflip = dir == 3
		
	else
		slash.xoff -= 1
		slash.n = 69
		slash.hflip = fp
		slash.sw = .75
		slash.vflip = dir == 4
		slash.w = 8
		slash.h = 8
	end
	
	function slash:update()
		self.life -= 1
		
		if self.life == -1 then
			self:delete()
		end
		
		self.x = player.x + self.xoff
		self.y = player.y + self.yoff
	end
	
	function slash:collide_enemy(other)
		other:damage(1)
		
		if self.dir == 4 then
			player:jump(.75)
		end
	end
	
	return slash
end



