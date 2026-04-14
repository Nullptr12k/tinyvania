function new_enemy(
		x, y, n,
		hp_tab, dmg_tab, pal_tab
	)
	
	local diff = loop(diff_off, 1, #hp_tab+1)
	diff_off = 1
	
	local hp = hp_tab[diff]
	local dmg = dmg_tab[diff]
	--local pid = pal_tab[diff_off]
	--local p = palettes.enemies[pid]
	local p = pal_tab[diff]
	
	local enemy = new_entity(
		x, y,
		8, 8
	)
	enemy.enemy = true
	enemy.diff = diff
	
	entity_add_hp(
		enemy, hp, 10, function(self)
			self:burst(10)
		end
	)
	
	enemy.dmg = dmg
	
	entity_add_draw(enemy, n)
	enemy.as = 1/10
	enemy.af = 2
	enemy.pal = p
	
	enemy.colors = analyze_colors(enemy.n, p)
	
	enemy.hflip = rnd{true, false}
	
	function enemy:patrol()
		local dx = self.hflip and 1 or -1
		dx *= 0.33
		
		self.x += dx
		
		if not self:valid_dir(sign(dx)) then
			self.hflip = not self.hflip
			self.x = flr(self.x)
			
			while not self:valid_dir(sign(dx)) do
				self.x -= sign(dx)
			end
		end
	end
	
	function enemy:valid_dir(dir)
		return self:valid_spot(
			self.x+(self.w-1)/2*(1+dir), self.y
		)
	end
	
	function enemy:valid_spot(x, y)
		local sx = self.x\128
		local tx = x\128
		
		return sx == tx and
			not solid_at(x, y) and
			solid_at(x, y+self.h) and
			not fget(mget(x\8, y\8), 3)
	end
	
	function enemy:collide_player(other)
		if (self.iframes > 0) return
		other:damage(self.dmg)
	end
	
	function enemy:die()
		self:delete()
		dissolve(
			self:get_spr(),
			self.x, self.y,
			self.hflip,
			self.vflip,
			self.pal
		)
	end
	
	function enemy:burst(num)
		burst(
			self.x+self.w\2,
			self.y+self.h\2,
			self.colors,
			num
		)
	end
	
	return enemy
end

function new_slime(x, y)
	local hp =  {2,3,4, 6, 8}
	local dmg = {2,4,8,12,16}
	local p = palettes.slimes
	
	local slime = new_enemy(
		x, y+1, 73,
		hp, dmg, p
	)
	slime.h = 7
	
	function slime:update()
		self:patrol()
	end
	
	return slime
end

function new_skeleton(x, y)
	local hp =  {3,4,6,8,12}
	local dmg = {3,5,6,8,12}
	local bone_dmg = {2,3,4,6,8}
	local p = palettes.skeletons
	
	local skel = new_enemy(
		x+1, y, 75,
		hp, dmg, p
	)
	skel.w = 6
	skel.sw = .75
	
	skel.bone_dmg = bone_dmg[skel.diff]
	
	function skel:new_timer()
		return flr(30 * (6 - self.diff + rnd(2)))
	end
	
	skel.timer = skel:new_timer()
	
	function skel:update()
		if self.diff > 1 then
			if self.timer > 0 then
				self.timer -= 1
			else
				self.timer = self:new_timer()
			end
		end
		
		if self.timer == 15 then
			local ct = ({0,1,1,2,3})[self.diff]
			
			for i=1,ct do
				local flip = self.hflip and 1 or -1
				local dir = 90 - 30 * flip
				local spread = 45
				local between = spread / (ct + 1)
				dir -= spread / 2
				dir += between * i
				
				new_bone(
					self.x+self.w\2,
					self.y+self.h\2,
					dir, 2,
					self.bone_dmg,
					self.pal
				)
			end
		end
		
		if self.timer >= 30 then
			self:patrol()
		end
	end
	
	return skel
end

function new_bone(x, y, dir, spd, dmg, p)
	local bone = new_entity(x-2.5, y-2.5, 5, 5)
	entity_add_draw(bone, 77)
	bone.front = true
	bone.sw = 5/8
	bone.sh = 5/8
	bone.pal = p
	
	bone.dx = spd * cos(dir/360)
	bone.dy = spd * sin(dir/360)
	bone.grav = .125
	
	bone.dmg = dmg
	
	function bone:update()
		if (t - self.toff)%5==0 then
			self.hflip = not self.hflip
		end
		
		self.x += self.dx
		self.y += self.dy
		self.dy += self.grav
	end
	
	function bone:collide_player(other)
		other:damage(self.dmg)
		self:delete()
	end
end




