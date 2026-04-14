function new_spikes(x, y, tile)
	local spikes = new_entity(
		x, y, 8, 8
	)
	
	entity_add_draw(spikes, 62)
	spikes.pal = room_pal_sub()
	
	local function det_vert()
		if solid_at(x, y+8) then
			spikes.y += 4
			spikes.h = 4
			spikes.sh = .5
			
			return true
			
		elseif solid_at(x, y-1) then
			spikes.h = 4
			spikes.hflip = true
			spikes.vflip = true
			spikes.sh = .5
			
			return true
		end
		
		return false
	end
	
	local function det_horz()
		if solid_at(x-1, y) then
			spikes.w = 4
			spikes.n += 1
			spikes.hflip = true
			spikes.vflip = true
			spikes.sw = .5
			
			return true
		
		elseif solid_at(x+8, y) then
			spikes.x += 4
			spikes.w = 4
			spikes.n += 1
			spikes.sw = .5
			
			return true
		end
		
		return false
	end
	
	if tile == 63 then
		if (det_horz()) goto done
		det_vert()
	else
		if (det_vert()) goto done
		det_horz()
	end
	
	::done::
	
	function spikes:collide_player(other)
		other:damage(3)
	end
	
	return spikes
end

function new_button(x, y)
	local button = new_entity(x, y)
	mset(x\8, y\8, 55)
	
	button.toggle = false
	
	function button:collide_player(other)
		if (button.toggle) return
		
		button.toggle = true
		mset(x\8, y\8, 56)
		
		local x = room_x()
		local y = room_y()
		for i=x*16,x*16+15 do
			for j=y*16,y*16+15 do
				if mget(i, j) == 54 then
					mset_redo(i, j, 53)
				end
				
				if mget(i, j) == 55 then
					mset(i, j, 56)
				end
			end
		end
		
	end
	
	return button
end

function new_fake(x, y, tile)
	local fake = new_entity(x, y)
	
	local mask = find_first_solid_mask(x\8, y\8)
	
	entity_add_draw(fake, mask)
	fake.front = true
	
	if fget(mask, 7) then
		fake.pal = room_pal_sub()
	elseif fget(mask, 6) then
		fake.pal = room_pal_gem()
	else
		fake.pal = room_pal_main()
	end
	
	return fake
end

function new_crumble(x, y, tile)
	local crumble = new_entity(x, y-1, 8, 9)
	crumble.tx = x\8
	crumble.ty = y\8
	
	local mask, ty = find_first_solid_mask(
		crumble.tx, crumble.ty, 38, 39
	)
	if mask then
		mset(crumble.tx, crumble.ty, mask)
		
		if ty == crumble.ty+1 and tile == 38 then
			mset_redo(crumble.tx, ty, 0)
		end
	end
	
	crumble.timer = -1
	
	function crumble:update()
		if self.timer == 56 then
			self:tile(38)
			
		elseif self.timer == 52 then
			self:tile(39)
			
		elseif self.timer == 48 then
			self:tile(0)
			
		elseif self.timer == 4 then
			self:tile(39)
			
		elseif self.timer == 0 then
			self:tile(38)
		end
		
		self.timer -= 1
	end
	
	function crumble:collide_player(other)
		if self.timer < 0 then
			self.timer = 60
		elseif self.timer <= 10 then
			self.timer = 10
			self:tile(0)
		end
	end
	
	function crumble:tile(t)
		mset(self.tx, self.ty, t)
	end
	
	return crumble
end

function new_breakable(x, y)
	local block = new_entity(x, y, 8, 8)
	block.tx = x\8
	block.ty = y\8
	
	local mask = find_first_solid_mask(
		block.tx, block.ty, 47
	)
	if mask then
		mset(block.tx, block.ty, mask)
	end
	
	block.colors = analyze_colors_tile(mask)
	block.enemy = true
	
	function block:damage()
		mset(self.tx, self.ty, 0)
		burst(
			self.x+self.w\2,
			self.y+self.h\2,
			self.colors,
			35
		)
		self:delete()
	end
	
	return block
end

function new_ladder_extension(x, y)
	local i = x \ 8
	local j = y \ 8
	mset(i, j, 58)
	
	local ladder = new_entity(x, y - 8)
	
	entity_add_draw(ladder, 59)
	ladder.back = true
	ladder.is_ladder = true
	
	return ladder
end



