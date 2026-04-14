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



