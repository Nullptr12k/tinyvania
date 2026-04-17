function init_player()
	local x, y
	
	for i=0,127 do
		for j=0,63 do
			if mget(i, j) == pconst.pspr then
				x = i*8
				y = j*8
				mset(i, j, 0)
				goto done
			end
		end
	end
	
	::done::
	
	player = new_entity(
		x+1, y, 6, 8
	)
	
	player.constant = true
	
	player.dx = 0
	player.dy = 0
	player.grav =
		pconst.grav
	
	player.state = pconst.normal
	player.facing = true
	
	player.items = {}
	player.money = 0
	entity_add_hp(
		player,
		pconst.start_hp,
		pconst.iframes,
		function(self)
			self:jump(pconst.knockback)
		end
	)
	
	player.grounded = true
	player.coyote = 0
	player.ladoff = 0
	
	entity_add_draw(
		player,
		pconst.pspr
	)
	player.front = true
	player.sw = .75
	
	player.slash_dir = false
	
	function player:update()
		if debug_try_player_teleport(self) then
			return
		end
		
		if self.state == pconst.normal then
			self:normal_control()
			
			if self.state ~= pconst.normal then
				return
			end
			
			self:horz_motion()
			self:vert_motion()
		
		elseif self.state == pconst.ladder then
			self:ladder_control()
		end
		
		self:handle_items()
		
		if self.x+3 >= 8*128 then
			self.x -= 8*128
		end
		
		if self.x+3 < 0 then
			self.x += 8*128
		end
		
		if self.y+4 >= 4*128 then
			self.y -= 4*128
		end
		
		if self.y+4 < 0 then
			self.y += 4*128
		end
		
		self.hflip = not self.facing
	end
	
	function player:normal_control()
		self.dx = 0
		
		if btn(0) then
		 self.dx -= pconst.h_speed
		 self.facing = false
		end
		
		if btn(1) then
			self.dx += pconst.h_speed
		 self.facing = true
		end
		
		if btnp(4) and (
			self.grounded or
				self.coyote > 0) then
			self:jump()
		end
		
		if btn(2) or btn(3) and self.ladoff <= 0 then
			self:grab_ladder()
		end
		
		if self.ladoff > 0 then
			self.ladoff -= 1
		end
	end
	
	function player:ladder_control()
		self.dy = 0
		
		if (btn(3)) self.dy += pconst.l_speed
		if (btn(2)) self.dy -= pconst.l_speed
		if (btn(0)) self.facing = false
		if (btn(1)) self.facing = true
		
		self.y += self.dy
		
		if self:solid_under() and
			not self:ladder_entity_at(
				self.x+3, self.y+8) then
			
			self:ladder_off()
			return
		end
		
		if self:solid_above() and
			not self:ladder_entity_at(
				self.x+3, self.y-1) then
			
			self:recenter_y()
			return
		end
		
		if btnp(4) and
			not self:collide_solid() then
			
			if not cancel then
				self.ladoff = pconst.ladoff
				self.state = pconst.normal
				self:jump()
				return
			end
		end
		
		if not self:ladder_touching() then
			self:ladder_off()
			return
		end
		
		if not self:ladder_at(self.x+3, self.y+4) and
			not self:ladder_at(self.x+3, self.y) and
			not self:ladder_entity_at(self.x+3, self.y+7) then
			
			self.y = flr(self.y)
			self.dy = 0
			
			local times = 0
			while not self:ladder_at(self.x+3, self.y+4) do
				self.y += 1
				times += 1
			end
		end
	end
	
	function player:horz_motion()
		self.x += self.dx
		
		if self:collide_solid() then
			self.x = flr(self.x)
			
			while self:collide_solid() do
				self.x -= sign(self.dx)
			end
		end
	end
	
	function player:vert_motion()
		self.y += self.dy
		
		if not self.grounded then
			self.dy += self.grav
			self.coyote -= 1
		end
		
		if self:collide_solid() then
			while self:collide_solid() do
				self.y -= sign(self.dy)
			end
			
			self:recenter_y()
		end
		
		self.grounded = self:solid_under()
		
		if self.grounded then
			self.coyote =
				pconst.coyote
		end
	end
	
	function player:jump(power)
		power = power or 1
		
		self.grounded = false
		self.coyote = 0
		self.dy =
			pconst.j_speed * power
	end
	
	function player:solid_under()
		return solid_at(
			self.x, self.y+self.h
		) or solid_at(
			self.x+self.w-1, self.y+self.h
		)
	end
	
	function player:solid_above()
		return solid_at(
			self.x, self.y-1
		) or solid_at(
			self.x+self.w-1, self.y-1
		)
	end
	
	function player:grab_ladder()
		if self.grounded and btn(3) then
			if self:ladder_entity_at(
				self.x+3, self.y+8, true) then
			
				self:ladder_on()
				self.y += 1
				
			else
				return
			end
		end
		
		local touch =
			self:ladder_at(self.x+3, self.y+4) or
			self:ladder_at(self.x+3, self.y)
		
		if touch then
			self:ladder_on()
			return
		end
	end
	
	function player:recenter_x()
		self.dx = 0
		self.x = (self.x+3)\8*8+1
	end
	
	function player:recenter_y()
		self.dy = 0
		self.grounded = true
		self.y = (self.y+4)\8*8
	end
	
	function player:ladder_on()
		self.state = pconst.ladder
		self:recenter_x()
	end
	
	function player:ladder_off()
		self.state = pconst.normal
		local dy = self.dy
		self:recenter_y()
		
		if dy > 0 then
			self.dy = dy
		end
	end
	
	function player:ladder_touching()
		return
			self:ladder_at(self.x+3, self.y) or
			self:ladder_at(self.x+3, self.y+7)
	end
	
	function player:ladder_at(x, y)
		return
			self:ladder_tile_at(x, y) or
			self:ladder_entity_at(x, y)
	end
	
	function player:ladder_tile_at(x, y)
		return fget(mget(x\8, y\8), 4)
	end
	
	function player:ladder_entity_at(x, y, no_secret)
		for entity in all(entities.ladders) do
				if entity.is_secret and no_secret then
					goto continue
				end
				
				if aprect(x, y, entity) then
					return true
				end
				
				::continue::
		end
		
		return false
	end
	
	function player:has(item)
		return self.items[item]
	end
	
	function player:handle_items()
		if (not self:has(1)) return
		
		if btnp(5) then
			local pts = {
				{x=3, y=-3},
				{x=-2, y=-12},
				{x=-11, y=-3},
				{x=-2, y=4},
			}
			
			local dir = self.facing and 1 or 3
			if (btn(0)) dir = 3
			if (btn(1)) dir = 1
			if (btn(3)) dir = 4
			if (btn(2)) dir = 2
			
			new_slash(
				3+pts[dir].x,
				4+pts[dir].y,
				dir,
				self.slash_dir
			)
			self.slash_dir = not self.slash_dir
		end
	end
end


