pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
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




function new_particle(
		x, y,
		deg, spd,
		life, c,
		acc
	)
	
	local p = new_entity(x, y, 1, 1)
	
	p.dx = cos(deg/360)*spd
	p.dy = sin(deg/360)*spd
	p.life = life
	p.acc = acc or 1
	
	function p:update()
		if self.life == 0 then
		self:delete()
			return
		end
		
		self.x += self.dx
		self.y += self.dy
		
		self.dx *= self.acc
		self.dy *= self.acc
		
		self.life -= 1
	end
	
	function p:draw()
		pset(self.x, self.y, c)
	end
	
	return p
end

function burst(x, y, c, num, p)
	for i=1,num do
		local deg = rnd(360)
		local col = rnd(c)
		if p then
			col = p[col]
		end
		
		new_particle(
			x,
			y,
			deg, .75+rnd(1),
			6+flr(rnd(10)),
			rnd(c),
			0.9
		)
	end
end

function dissolve(n, x, y, hflip, vflip, p)
	local nx, ny = spr_xy(n)
	
	debug = (tostr(n) .. " " .. tostr(nx) .. " " .. tostr(ny))
	
	for i=0,7 do
		for j=0,7 do
			local c = sget(nx+i, ny+j)
			if p then
				c = p[c]
			end
			
			local deg = rnd(360)
			
			if hflip then
				i = 7 - i
			end
			
			if vflip then
				j = 7 - j
			end
			
			if c ~= 0 then
				new_particle(
					x+i+0.5,
					y+j+0.5,
					deg, .75+rnd(1),
					6+flr(rnd(10)),
					c, 0.9
				)
			end
		end
	end
end

function dissolve_all()
	if (diss) return
	diss = true
	
	for a in all(entities.all) do
		a:delete()
	end
	
	for i=0,127 do
		for j=0,63 do
			mset(i, j, 0)
		end
	end
	
	for i=0,127 do
		for j=0,127 do
			local c = pget(i, j)
			local deg = rnd(360)
			
			if c ~= 0 and rnd(2) < 1 then
				new_particle(
					room_x()*128+i+0.5,
					room_y()*128+j+0.5,
					deg, .75+rnd(1),
					60+flr(rnd(10)),
					c, 0.9
				)
			end
		end
	end
end




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





pconst = {
	start_hp = 10,
	iframes = 30,
	knockback = .5,
	
	h_speed = 1.5,
	j_speed = -3.5,
	l_speed = 1.5,
	grav = .4,
	coyote = 5,
	ladoff = 4,
	
	pspr = 64,
	
	normal = 0,
	ladder = 1,
	cutscene = 2
}




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
		if debug_mode then
			if mb & 1 ~= 0 then
				self.x = mx-3 + room_x()*128
				self.y = my-4 + room_y()*128
				self.dx = 0
				self.dy = 0
				return
			end
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
		
		if debug_mode then
			--local height = y - self.y
			--debug = tostr(max(tonum(debug), height))
		end
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




repl = {
	[20] = new_heart,
	[26] = new_coin,
	[38] = new_crumble,
	[39] = new_crumble,
	[40] = new_torch,
	[46] = new_fake,
	[47] = new_breakable,
	[55] = new_button,
	[59] = new_ladder_extension,
	[62] = new_spikes,
	[63] = new_spikes,
	[66] = new_secret_ladder,
	
	[72] = function()
		diff_off += 1
	end,
	
	[73] = new_slime,
	[74] = new_slime,
	[75] = new_skeleton,
	[76] = new_skeleton,
}

function init_camera()
	map_repls = {}
	
	cx = room_x()
	cy = room_y()
	
	room_transition(
		-1, -1,
		room_x(), room_y()
	)
end

function room_transition(x0, y0, x1, y1)
	cx = x1
	cy = y1
	
	clear_entities()
	
	if x0 ~= -1 then
		reset_map(x0, y0)
	end
	
	init_map_data(x1, y1)
	init_map_entities(x1, y1)
end

function reset_map(x, y)
	for repl in all(map_repls) do
		mset(repl.x, repl.y, repl.n)
	end
	
	map_repls = {}
end

function init_map_data(x, y)
	pal_main = 1
	pal_sub = 2
	pal_gem = 5
	
	local mode = 0
	
	for i=x*16,x*16+15 do
		for j=y*16,y*16+15 do
			local tile = mget(i, j)
			
			if tile == 16 then
				pal_main += 1
				mset_redo(i, j, 0)
			end
			
			if tile == 32 then
				pal_sub += 1
				mset_redo(i, j, 0)
			end
			
			if tile == 48 then
				pal_gem += 1
				mset_redo(i, j, 0)
			end
			
			tile -= 75
		end
	end
	
	while pal_main > 6 do
		pal_main -= 6
	end
	
	while pal_sub > 6 do
		pal_sub -= 6
	end
	
	while pal_gem > 6 do
		pal_gem -= 6
	end
end

function init_map_entities(x, y)
	diff_off = 1
	
	-- for each cell
	for i=x*16,x*16+15 do
		for j=y*16,y*16+15 do
			local n = mget(i, j)
			
			-- specific replacements
			if repl[n] then
				mset_redo(i, j, 0)
				repl[n](i*8, j*8, n)
			end
			
			-- key item replacements
			if fget(n, 5) then
				mset_redo(i, j, 0)
				new_key_item(i*8, j*8, n)
			end
		end
	end
end

function update_camera()
	local nx = room_x()
	local ny = room_y()
	
	if nx ~= cx or ny ~= cy then
		room_transition(cx, cy, nx, ny)
	end
end




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




debug_mode = false

function _init()
	if debug_mode then
		-- enable cursor
		poke(0x5f2d, 0x1)
	end
	
	-- global timer
	t = 0
	
	debug = ""
	
	-- init other modules
	init_palettes()
	init_entities()
	init_player()
	init_camera()
end

function _update()
	mx = stat(32)
	my = stat(33)
	mb = stat(34)
	
	--[[
	if mb ~= 0 then
		dissolve_all()
	end]]
	
	-- entities
	update_entities()
	
	update_camera()
end

function _draw()
	cls(0)
	
	camera(128 * cx, 128 * cy)
	
	-- map
	draw_map()
	
	-- background entities
	draw_entities_back()
	
	-- mid-scene entities
	draw_entities()
	
	-- front entities
	draw_entities_front()
	
	if debug_mode then
		-- debug
		draw_hitboxes()
	end
	
	camera()
	
	-- ui
	if not diss then
		draw_ui()
	end
	
	if player:has(13) then
		pal(palettes.eggplant, 1)
	end
	
	if debug_mode then
		-- draw cursor
		spr(48, mx, my)
		
		--[[print_shadow(
			debug,
			64-2*#debug + room_x()*128,
			4 + room_y()*128,
			7, 5
		)]]
		print(debug, 8, 64, 7)
	end
	
	-- global timer
	t += 1
end
__gfx__
76ca77d10000066207242720000720000000220000000042000044200007620000000000008e88200055550009999992000222000000b01b0007620000076200
6db9eccd00006662766666720777772000dddd20000a4442000422420074472022220000000822000d666d504922294200776d2000003bb30074472000744720
d5348db300065620766666720267d2000d77ccd200a9227200115220002672207aa7200000a79200d67777d549999942067666d20002e2b10026722000267220
521221e89a65620076646672007472000d77ccd20992272001dd152000066200a29a22220a724920d22d7225499944420aa6da920227223b00066220007dd620
1f2ff2a922a6200007242720002420000dccc1620422720001d11120007d1620a22aaa770a7249200665d6d0494444420d2a92d22e622210076dd662007d7620
78bca0000429200000042200000420000d111662242720000111112007dd7162a29a299a0a924a200d75262046777722062a92d22222221007dd716200671620
67cd700092092000000920000009200002dd6620447200000211122006d711727aa729270299a20000777d002444444206222262122221000077162000711620
de319000200200000002000000020000002222002220000000222200026667222222220200222000007272000222222000222222011110000026620000266200
ad8c5a6b000000000007200000000000000000000000000000000000000000000000000000000000004444000044220000044000000440000004400000442200
9ce7d9d300007720007e8200000000000e82882000828200000820000008200000082000008282000477aa2004977a200049a20000479200004792000477a920
7776745100006472077e882000878800e6e888820e68882000e68200000e20000086e20008e6882047a99aa2497a9aa204a79a200047920004797a2047a9aa92
6166621200004672eeee8882007ee20086e888820868882000868200000e200000868200088688204a9999a2497999a2049a9a20004a92000479a9204a999a92
000000000004222028882228008ee200086e8820006e82000086820000082000008682000086e2004a9999a249a999a2049a9a20004a920004a9a9204a999a92
8c39d5000642000002882280008222000088820000888200000820000008200000082000008882004aa99a72497a9aa204aa9a20004a920004a9aa204aa9a792
edba660006d20000002828000000000000082000000820000008200000082000000820000008200004aa772004977a200049a200004a9200004a920004a77920
21142d00222200000002800000000000000000000000000000000000000000000000000000000000004422000042220000042000000420000004200000422200
090000000090a606766666676666666d65766666666d666d76d766d60000000009000000d666666dd666666dd666616d00444400d6765d516666666d6666666d
00a66666000807476766667d67777765d166666676d766666ddddddd0d0d0d00a89000006dddddd55dddddd56ddd516504aa9940d6765d5163d3d3d562dddd25
94a555d660a09040667777dd67666665d56dddddd70d776ddd7d65d5007d65d0a98900006dddddd5616dddd56ddd16d54a9769a2d6765d516d3d3d356d2dd2d5
00a6666604400040667777dd676666d551551511ddd00dd07dddddd50ddddd000aa000006dddddd5651dddd56dd516d5499669a2d6765d5163d3d3d56dd22dd5
090000004004066d667777dd676666d5666d576650500d056d65d6dd0065d6d0094000006dddddd56516ddd56d516dd504a99a20d6765d516d3d3d356dd22dd5
0000006700d00060667777dd676666d5666d56660dd5055dddddd5d50dddd500ddd500006dddddd56d5116d56d16ddd50043b200d6765d5163d3d3d56d2dd2d5
000000044466000065dddd6d666dddd5dddd56dd005000506dddddd500d0d0d0042000006dddddd56dd551656516ddd504bb2000d6765d516d3d3d3562dddd25
00000067006006005dddddd6d5555555115515550000d000555d5d550000000004200000d5555551d5111111d5155551004b2000d6765d51d5555555d5555555
010000000ff066600000b300000449900000000011111111767766650777676007776760dd7776d594000094000000000d675d10d6765d510050005000550000
17100000fef06d600000bb300066649904427760100000016dddddd57d5555d77d5555d7d666666194994994000000000d675d10d6765d5105d005d05d660000
17710000f8f065600eeb3882044996494447ee86101111017d7765d1751dd15d7510015d7611516194444494000000005d675d15d6765d5105650565055d0000
17771000f8f065600e6e8882666499994247e786101001017d7dd5d175d6661d7500001d7610056192000024000000007d675d15d6765d515d655d6500050000
177771000ff065600e6e888299964994244788e6101001017d6dd5d565d6671d6500001d765001d194000094940000947dd75115d6765d510000000000550000
177110001c10aaa00ee8888249999942222468e6101111016d7555d17516711d7510011d661511d19449949494499494766dd6d5d6765d51000000005d660000
011710001319040902e888202444442002222660100000016dddddd16d5111d76d5111d7d666ddd1944444949444449476666dd56dd6511500000000055d0000
0000000001100900008228200222220000000000111111115515111107dddd7007dddd705111111192000024920000247dddd555666dd5550000000000050000
111111001111110001000010dddd000000000000000600000000000000000000a87780000000000000b300000770000000000000070000000000000000000000
177711001711110001cccc100006660000000000006670000000d00000f0f0f0bac8600000b300000bbb30008787000007700000770000000000000000000000
1711710017111100011111100000066000000000066777000000dd000f0f0f003912d0000bbb3000bbabb3007777000087870000007000000000000000000000
1711710017111100010000100000076600000000060077000000d60000f0f0f014f15000bbabb3003babb3007760000077770000000770000000000000000000
177711001711110001000010000077700000ddd0d6000700000006000f0f0f00888f80003babb3103bbbbb100076700077667700000700000000000000000000
171111001711110001cccc100077770000666d00d00007000000060000f0f0f07ac8d00013bb333113bbb3330706070000060000000000000000000000000000
1711110017777100011111100000000000000000d0000000000000000f0f0f0069d2500011311113013331100060600000606000000000000000000000000000
1111110011111100010000100000000000000000d000000000000000000000000000000000000000000000000070700007000700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d2000000000000d200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200d3000000000000d300a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200323232323232323200a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200000000000000000000a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d200000000820082000000a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d20000000000d000000000a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d20000a10000c30000a100a3d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d300000000222222000000a3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0020202020202020202020202020202000000000000000000000000000000000000081010181818000010101008108000000000000484140400090908181404000001000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2929292929292929292929292929292929292929292929292929292929292929000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2910202020000000000000000000000010202020202000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000001a00000000002800280000000000000000000028142829000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29002800001a00000000000000000000000000000000000000000000003c0029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29000000000000003f2d3f000023232323230000000000000000000022222229002222220022222200222222002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29002300002d0000002d00000000002929000000000000000000000000003b29000022000022002200002200002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29003b00002d0000003a00001a00002929000000000000000000000000003a29000022000022222200002200002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29003a00002d0000003a00000000002929000000000000000000000000003a29000022000022002200002200002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29003a003f2d3f00003a000000002329290000000000000000001a0000003a29002222000022002200222222002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29003a0000000000003a000000003b2929000000000000000000000000003a29000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29000000002800000000000000003a29290000000000000000003a0000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29000000000000000000000000003a29290000000000001a0000000000000029000000000010202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29000000002600000000000028003a2929000000000000000000000000000029232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29000000002500000000000000003a29290000000000003a00000000000000290a2300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000002323232929000000000000000000000000000029002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000003b0000292900000000000000000000000000002900237f7f7f7f7f7f7f7f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000003a00002929000000000000000000000000000029293b3b3b3b3b3b3b3b3b3b3b3b3b3b290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000003a00002929000000000000000000000000000029293a3a3a3a3a3a3a3a3a3a3a3a3a3a290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000003a00282e2e000000000000000000000000000029290036363600360036003636360000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000000000002e2e002800000000000000000000280029290000362000360036003600420000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000000000002e2e00001a00001a00001a000037000029290000362000363636003636420000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000000000002929000000000000000000000000000029290000362000360036003600420000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900000000000000000000000000232329000023000026000026000023000029290000360000360036003636360000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290000000000000000000000002323232900003b000025000025000000000029290000000000000000000000420000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290000000000000000000000002d002d2900003a0000000000003e3e3e3e3e29290000363636003636000036360000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290000000000000000000000003d003d2900003a0000000000002222222222232323002e0000002e002e002e423600290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290000000000000000000000002323232323233a0000000000003628002800000028002e3600002e002e002e3a3600290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290028002800000000000000002800000000283a0000000000003600010037000000002e0000002e002e002e423600290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
290000400000000000000000000000000000003a00470049000036003c000000000000363636003600360036360000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2900242424000000000000232323232323232323232323232323222222222223232300000000000000000000420000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29002f002f0000000000002d0042002d2d002d002d002d00002d002d002d0029293e3e3e3e3e3e3e3e3e3e3e3e3e3e290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29252d002d2525252525252d0042002d2d002d002d002d00002d002d002d0029292929292929292929292929292929290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

