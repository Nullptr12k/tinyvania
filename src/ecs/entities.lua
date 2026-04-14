function init_entities()
	entities = {}
	entities.all = {}
	entities.draw = {}
	entities.update = {}
	entities.update_hp = {}
	entities.collide_player = {}
	entities.collide_enemy = {}
	entities.ladders = {}
	entities.enemies = {}
	
	entities.meta = {
		__newindex = function(entity, key, val)
			rawset(entity, key, val)
			
			if key == "draw" then
				add(entities.draw, entity)
			end
			
			if key == "update" then
				add(entities.update, entity)
			end
			
			if key == "update_hp" then
				add(entities.update_hp, entity)
			end
			
			if key == "collide_player" then
				add(entities.collide_player, entity)
			end
			
			if key == "collide_enemy" then
				add(entities.collide_enemy, entity)
			end
			
			if key == "is_ladder" then
				add(entities.ladders, entity)
			end
			
			if key == "enemy" then
				add(entities.enemies, entity)
			end
		end
	}
end

function new_entity(x, y, w, h)
	local entity = {
		x=x, y=y,
		w=w or 8, h=h or 8
	}
	
	add(entities.all, entity)
	setmetatable(entity, entities.meta)
	
	function entity:delete()
		if (self.draw) del(entities.draw, self)
		if (self.update) del(entities.update, self)
		if (self.update_hp) del(entities.update_hp, self)
		if (self.collide_player) del(entities.collide_player, self)
		if (self.collide_enemy) del(entities.collide_enemy, self)
		if (self.is_ladder) del(entities.ladders, self)
		if (self.enemy) del(entities.enemies, self)
		del(entities.all, self)
	end
	
	function entity:collide_solid()
		return solid_at(
			self.x,
			self.y
		) or
		
		solid_at(
			self.x+self.w-1,
			self.y
		) or
		
		solid_at(
			self.x+self.w-1,
			self.y+self.h-1
		) or
		
		solid_at(
			self.x,
			self.y+self.h-1
		)
	end
	
	return entity
end

function entity_add_draw(entity, n)
	entity.n = n
	
	entity.toff = t
	entity.as = entity.as or 0
	entity.af = entity.af or 0
	entity.hflip = false
	entity.vflip = false
	entity.sw = entity.sw or 1
	entity.sh = entity.sh or 1
	if entity.show == nil then
		entity.show = true
	end
	
	function entity:draw()
		if (not entity.show) return
		if (self.pal) pal(self.pal, 0)
		
		spr(
			self:get_spr(),
			self.x, self.y,
			self.sw, self.sh,
			self.hflip, self.vflip
		)
		
		pal(0)
	end
	
	function entity:get_spr()
		return flr(self.n + (
				self.as * (t - self.toff)
			) % self.af)
	end
end

function entity_add_hp(
		entity, hp,
		max_iframes, callback
	)
	
	entity.max_hp = hp
	entity.hp = hp
	entity.max_iframes = max_iframes
	entity.iframes = 0
	entity.damage_callback = callback
	
	function entity:update_hp()
		if self.iframes > 0 then
			self.iframes -= 1
			self.show = self.iframes%2==0
		end
	end
	
	function entity:damage(amount)
		if self.iframes > 0 then
			return
		end
		
		self.hp -= amount
		if self.hp <= 0 then
			self.hp = 0
			
			if self.die then
				self:die()
			end
		end
		
		self.iframes = self.max_iframes
		
		if self.damage_callback then
			self:damage_callback(amount)
		end
	end
end

function update_entities()
	-- handle regular updates
	for entity in all(entities.update) do
		entity:update()
	end
	
	-- handle hp updates
	for entity in all(entities.update_hp) do
		entity:update_hp()
	end
	
	-- handle enemy collision
	collide_enemy_entities()
	
	-- handle player collision
	collide_player_entities()
end

function collide_player_entities()
	for entity in all(entities.collide_player) do
		if arectrect(entity, player) then
			entity:collide_player(player)
		end
	end
end

function collide_enemy_entities()
	for collidor in all(entities.collide_enemy) do
		for enemy in all(entities.enemies) do
			if arectrect(collidor, enemy) then
				collidor:collide_enemy(enemy)
			end
		end
	end
end

function draw_entities_back()
	for entity in all(entities.draw) do
		if (entity.back) entity:draw()
	end
end

function draw_entities()
	for entity in all(entities.draw) do
		if (not entity.back) entity:draw()
	end
end

function draw_entities_front()
	for entity in all(entities.draw) do
		if (entity.front) entity:draw()
	end
end

function clear_entities()
	for entity in all(entities.all) do
		if not entity.constant then
			entity:delete()
		end
	end
end



