function new_key_item(x, y, n)
	if player:has(n) then
		return
	end
	
	local item = new_entity(x, y-1)
	entity_add_draw(item, n)
	apply_bob(item, 30, 1)
	
	function item:update()
		self:update_bob()
	end
	
	function item:collide_player(other)
		other.items[self.n] = true
		self:delete()
		
		if self.n == 13 then
 		poke(0x5f60, 0x02, 0x82)
		end
		
		if self.n == 10 then
			dissolve_all()
 		poke(0x5f60, 0x00, 0x00)
		end
	end
	
	return item
end

function new_heart(x, y)
	local heart = new_entity(x, y)
	
	entity_add_draw(heart, 20)
	heart.af = 6
	heart.as = 1/3.5
	apply_bob(heart, 55, 1)
	
	function heart:update()
		self:update_bob()
	end
	
	function heart:collide_player(other)
		other.max_hp += 25
		other.hp = other.max_hp
		mset_redo(x\8, (y+4)\8, 0)
		self:delete()
	end
	
	return heart
end

function new_torch(x, y)
	local torch = new_entity(x, y)
	
	torch.flip = false
	torch.back = true
	
	torch.toff = flr(rnd(4))
	
	function torch:update()
		if ((t-self.toff)/2)%2==0 then
			self.flip = not self.flip
		end
		
		if t%9 == 0 then
			p = new_particle(
				self.x+2+rnd(4), self.y+1,
				90, 0.33, 30, rnd{5,6}, 0.99
			)
		end
	end
	
	function torch:draw()
		sspr(
			64, 16, 4, 4,
			self.x + 2, self.y,
			4, 4, self.flip
		)
		
		sspr(
			64, 20, 4, 4,
			self.x + 2, self.y + 4
		)
	end
	
	return torch
end

function new_secret_ladder(x, y)
	local ladder = new_entity(x, y)
	ladder.is_ladder = true
	ladder.is_secret = true
	
	if solid_at(x, y-1) then
		new_secret_ladder(x, y-8)
	end
	
	return ladder
end

function new_coin(x, y, denom)
	if (denom != 5 and denom != 25) denom = 1
	denom = 5
	
	local coin = new_entity(x, y)
	
	entity_add_draw(coin, 26)
	coin.af = 6
	coin.as = 0.25
	
	if (denom == 5) coin.pal = palettes.coins[2]
	if (denom == 25) coin.pal = palettes.coins[3]
	
	function coin:collide_player(other)
		other.money += denom
		mset_redo(x\8, y\8, 0)
		self:delete()
	end
	
	return coin
end



