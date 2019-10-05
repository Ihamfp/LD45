-- THE ONLY, THE REAL, THE HERO MR. HYPINGTON
-- MAY HIS LIFE BE LONG AND HIS POWER ABSOLUTE
--                   - The Book of Hyke, II:3

local SolidSprite = require("entity.solidsprite")
local Solid = require("entity.solid")
local PowerPlat = require("entity.powerplat")
local anim8 = require("anim8")
local move = require("input").move
local space = require("input").space
local enter = require("input").enter
local entities = require("entities")
local entity = require("entity")
local Sprite = require("entity.sprite")
local Pointer = require("entity.pointer")
local uqt = require("ubiquitousse")
local Shockwave = require("entity.shockwave")
local Jumpable = require("entity.jumpable")

local idleImg = love.graphics.newImage("asset/sprite/hyke.png")
local shadow = love.graphics.newImage("asset/sprite/shadowthehedghog.png")

local cursor
local tornadoPlat
local stonehedgePlat
local direction = "up"
local currentlyCollidingButter
local idleg

local blackish, cinema, cinemaEvent

return SolidSprite {
	__name = "hyke",

	directionPressed = 0,

	width = 16,
	height = 16,
	ox = 64/2-8, oy = 64/2-8,

	accel = 10,
	maxspeed = 250,
	speed = 0,
	minspeed = 5,

	vx = 0,
	vy = 0,

	direction = "up",

	cloneSymetry = nil, -- 1, 2, 3 (clockwise)

	new = function(self, x, y, options)
		SolidSprite.new(self, x, y, options)

		self.hykeAttack = hykeAttack:new(x+hykeAttack.dx, y+hykeAttack.dy)

		-- idle
		idleg = anim8.newGrid(64, 64, idleImg:getWidth(), idleImg:getHeight())

		self.image.up = idleImg
		self.image.down = idleImg
		self.image.right = idleImg
		self.image.left = idleImg

		self.animation.up = anim8.newAnimation(idleg(("1-2"),1), { 0.7, 0.7 })
		self.animation.down = self.animation.up:clone():flipV()
		self.animation.right = anim8.newAnimation(idleg("1-2",2), { 0.7, 0.7 })
		self.animation.left = self.animation.right:clone():flipH()

		self:set("up")

		self.lastCheckpoint = {self.x, self.y}

		if self.cloneSymetry then
			self.__name = "hyke"..tostring(self.cloneSymetry)
			local hyke = entities.find("hyke")
			if self.cloneSymetry == 1 then
				self.color = { .5, 1, .5, .7}
				self.x, self.y = love.graphics.getWidth()-hyke.x, hyke.y
			end
		end

		blackish = require("entity.rectangle"):new(0, 0, 1280, 720, {
			hud = true,
			visible = false,
			color = {0,0,0,.5}
		})
	end,

	update = function(self, dt)
		if cinema then
			if cinemaEvent == nil then
				local d
				cinemaEvent, d = cinema()
				if cinemaEvent == "text" then
					cinemaEvent = require("entity.text"):new(font.Stanberry[26], d, 15, 15, {
						hud=true, color={1,1,1,1}, shadowColor={0,0,0,1},
						limit = love.graphics.getWidth()-30
					})
					subtleHint = require("entity.text"):new(font.Stanberry[22], "Press enter to continue.", 15, cinemaEvent.height+30, {
						hud=true, color={0.7,0.7,0.7,1}, shadowColor={0,0,0,1},
						limit = love.graphics.getWidth()-30
					})
				elseif cinemaEvent == "end" then
					blackish.visible = false
					entities.freezeButHyke = false
					cinema = nil
					cinemaEvent = nil
				end
			else
				if enter:pressed() then
					cinemaEvent.remove = true
					if subtleHint then subtleHint.remove = true end
					cinemaEvent = nil
				end
			end

		elseif not self.qteMode then
			SolidSprite.update(self, dt)

			local score = uqt.scene.current.score
			if score then
				score.time = score.time + dt
			end

			self.hykeAttack.x, self.hykeAttack.y = self.x+hykeAttack.dx, self.y+hykeAttack.dy
			self.world:update(self.hykeAttack, self.hykeAttack.x, self.hykeAttack.y, self.hykeAttack.width, self.hykeAttack.height)

			self.speed = math.max(self.speed, self.minspeed)

			if not self.buttering then
				self.buttering = Butter:new(self.x, self.y)
			end

			-- animation & move
			if self.directionPressed > 0 then
				self.directionPressed = self.directionPressed - 1
			else
				if (
					(not self.cloneSymetry and move.right:pressed()) or
					(self.cloneSymetry == 1 and move.left:pressed())
				   ) and self.direction ~= "right" then
					if self.direction == "up" then
						self.buttering.height = math.max(1, self.buttering.height - 16)
						self.buttering.y = self.buttering.y + 16
						self.buttering:updateSize()
					end
					self.direction = "right"
					self.buttering = Butter:new(self.x, self.y)
					self:set("right")
					self.directionPressed = 4
				elseif (
					(not self.cloneSymetry and move.left:pressed()) or
					(self.cloneSymetry == 1 and move.right:pressed())
				) and self.direction ~= "left" then
					if self.direction == "up" then
						self.buttering.y = self.buttering.y + 16
						self.buttering.height = math.max(1, self.buttering.height - 16)
						self.buttering:updateSize()
					end
					self.direction = "left"
					self.buttering = Butter:new(self.x, self.y)
					self:set("left")
					self.directionPressed = 4
				elseif move.up:pressed() and self.direction ~= "up" then
					if self.direction == "left" then
						self.buttering.width = math.max(1, self.buttering.width - 16)
						self.buttering.x = self.buttering.x + 16
						self.buttering:updateSize()
					end
					self.direction = "up"
					self.buttering = Butter:new(self.x, self.y)
					self:set("up")
					self.directionPressed = 4
				elseif move.down:pressed() and self.direction ~= "down" then
					if self.direction == "left" then
						self.buttering.width = math.max(1, self.buttering.width - 16)
						self.buttering.x = self.buttering.x + 16
						self.buttering:updateSize()
					end
					self.direction = "down"
					self.buttering = Butter:new(self.x, self.y)
					self:set("down")
					self.directionPressed = 4
				end
			end

			if space:pressed() and not self.jumping then
				minusOneHealth(press)

				local oY, oX = self.oy, self.ox
				uqt.scene.current.time.tween(200, self, {
					sx = 1.5,
					sy = 1.5,
					ox = oX - (self.width - self.width*1.5)/2,
					oy = oY + 30
				}, "outCubic")
				:stopWhen(space.released)
				:onEnd(function(r, duration)
					uqt.scene.current.time.tween(math.max(100, duration), self, {
						sx = 1,
						sy = 1,
						ox = oX,
						oy = oY
					}, "inQuad")
					:onEnd(function()
						self.buttering = Butter:new(self.x, self.y)
						self.jumping = false
						touchdownA[math.random(1, #touchdownA)]:play()
					end)
				end)
				local dx, dy = 0, 0
				if self.direction == "up" then
					dy = -16
				elseif self.direction == "left" then
					dx = -16
				end
				self.buttering = ButterTray:new(self.x + dx, self.y + dy)
				self.jumping = true
				self.animSpeedUp = self.animSpeedUp*3
				jumpA[math.random(1, #jumpA)]:play()
			end

			-- accel
			self.speed = math.min(self.speed + self.accel*dt, self.maxspeed)

			if score then
				score.maxSpeed = math.max(self.speed, score.maxSpeed)
				if self.speed == self.maxspeed then
					score.maxSpeedDuration = score.maxSpeedDuration + dt
				end
			end

			-- move
			if self.direction == "up" then
				self.vx, self.vy = 0, -self.speed
			elseif self.direction == "down" then
				self.vx, self.vy = 0, self.speed
			elseif self.direction == "right" then
				self.vx, self.vy = self.speed, 0
			elseif self.direction == "left" then
				self.vx, self.vy = -self.speed, 0
			end
			self:move(self.vx * dt, self.vy * dt)
			self.hykeAttack:move(self.vx * dt, self.vy * dt)

			-- butter
			if self.direction == "up" then
				local oY = self.buttering.y
				self.buttering.y = self.y
				self.buttering.height = (oY + self.buttering.height) - self.y
			elseif self.direction == "down" then
				self.buttering.height = self.y - self.buttering.y
			elseif self.direction == "right" then
				self.buttering.width = self.x - self.buttering.x
			elseif self.direction == "left" then
				local oX = self.buttering.x
				self.buttering.x = self.x
				self.buttering.width = (oX + self.buttering.width) - self.x
			end
			self.buttering.width, self.buttering.height = math.max(1, self.buttering.width), math.max(1, self.buttering.height)
			self.buttering:updateSize()

			if not self.jumping then
				self.animSpeedUp = math.log(self.speed / 8)
			end

			if self.vx == 0 and self.vy == 0 then
				if self.speed > 50 then
					entities.shake = self.speed/10
					uqt.scene.current.time.run(function()
						entities.shake = 0
					end):after(100)
				end
				self.speed = 0
			end

			-- local cursored = false
			-- local tornadoPlatted = false
			-- local stonehedgePlatted = false

			-- collide
			local collidingWithSameButter = false
			for _, c in ipairs(self.collisions) do
				local o = c.other
				if not self.jumping and o.__name == "butter" and o ~= self.buttering and not o.ignoreButter then
					if o~= self.currentlyCollidingButter then
						self.speed = self.speed * 0.1
						butter:play()
					end
					self.currentlyCollidingButter = o
					collidingWithSameButter = true
				end
				if o.__name == "warp" then
					entities.freeze = true
					local name = uqt.scene.current.name
					local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
						hud = true,
						color = {1,1,1,0}
					})
					uqt.scene.current.time.tween(500, rect.color, {[4]=1})
					:onEnd(function()
						rect.remove = true
						entities.freeze = false
						uqt.scene.switch(o.direct and o.to or "inbetweenlevels", score, name, o.to)
					end)
				end
				if o.__name == "cinema" and not o.cinemated then
					local ans = dofile("source/lib/anselme/anselme.lua")("asset/film/"..o.to..".ans")
					blackish.visible = true
					entities.freezeButHyke = true
					o.cinemated = true
					local background
					ans:registerFunction("background.", function(path)
						if path then
							background = require("entity.image"):new(0, 0, love.graphics.newImage("asset/sprite/"..path), {hud=true})
						else
							background.remove = true
						end
					end)
					ans:registerFunction("achievement.", function(path)
						require("entity.hud.achievement"):new(path)
					end)
					ans:registerFunction("set.", function(var, val)
						_G[var] = val
					end)
					cinema = ans:new()
				end
				if o.damage and o.damage > 0 and (not o.lastCollision or ((uqt.scene.current.time:get() - o.lastCollision) > 1000)) and not o.ignoreDamage and not self.jumping then
					o.lastCollision = uqt.scene.current.time:get()
					for i=1, o.damage do
						minusOneHealth(ouchp[math.random(1, #ouchp)])
						-- TODO particles
						local particles = love.graphics.newParticleSystem(butterImg)
						particles:setParticleLifetime(0.5, 0.8)
						particles:setEmissionRate(1000)
						particles:setSizes(0.2, 0.2)
						particles:setLinearAcceleration(-100, -100, 100, 100)
						particles:setColors(1,0,0,0.7,0.7,0,0,0)
						particles:start()

						local h = self
						local ent = entity:new{
							draw = function(self) love.graphics.draw(particles, h.x + h.width/2, h.y + h.height/2) end,
							update = function(self, dt) particles:update(dt) end
						}
						uqt.scene.current.time.run(function() particles:setEmissionRate(0) end):after(100)
						uqt.scene.current.time.run(function(...) ent.remove = true end):after(1000)
					end
				end
				if o.properties then
					if o.properties.checkpoint then
						self.lastCheckpoint = {self.x, self.y}
					end
					-- if o.properties.death then
					-- 	ouch:play()
					-- 	self.x, self.y = self.lastCheckpoint[1], self.lastCheckpoint[2]
					-- 	self.world:update(self, self.x, self.y)
					-- end
					-- if o.properties.power then
					-- 	cursored = true
					-- 	if not cursor then
					-- 		cursor = Pointer:new()
					-- 	end
					-- 	if o.properties.power == "tornado" and powerIcons[8].doingThePlatform then
					-- 		tornadoPlatted = true
					-- 		if not tornadoPlat then
					-- 			tornadoPlat = PowerPlat:new(0,0,"powerico4.png", {
					-- 				onPower = function()
					-- 					Shockwave:new(self.x+16, self.y -64+16, powerIcons.data[4].shockwave)
					-- 					if self.map.layers[o.properties.removeOnPower] then
					-- 						self.map:bump_removeLayer(o.properties.removeOnPower, self.world)
					-- 						self.map:removeLayer(o.properties.removeOnPower)
					-- 					end
					-- 				end
					-- 			})
					-- 		end
					-- 		tornadoPlat.x, tornadoPlat.y = self.x, self.y -64
					-- 	end
					-- 	if o.properties.power == "flyingStonehenge" and powerIcons[11].doingThePlatform then
					-- 		stonehedgePlatted = true
					-- 		if not stonehedgePlat then
					-- 			stonehedgePlat = PowerPlat:new(0,0,"powerico9.png", {
					-- 				onPower = function()
					-- 					Shockwave:new(self.x+16, self.y -64+16, powerIcons.data[9].shockwave)
					-- 					self.map.layers["ElevatorUp"].visible = not self.map.layers["ElevatorUp"].visible
					-- 					if self.map.layers["ElevatorUp"].visible then
					-- 						self.x, self.y = 415*16, 118*16
					-- 					else
					-- 						self.x, self.y = 429*16, 240*16
					-- 					end
					-- 					self.world:update(self, self.x, self.y)
					-- 				end
					-- 			})
					-- 		end
					-- 		stonehedgePlat.x, stonehedgePlat.y = self.x, self.y -64
					-- 	end
					-- end
				end
			end

			for _, c in ipairs(self.hykeAttack.collisions) do
				local o = c.other
				if o.jumpover and not o.invincible then
					if self.jumping then
						o:jumpover()
					elseif o.noCollision then
						o:jumpover()
					else
						if score and not o.grazed then
							o.grazed = true
							score.thingsGrazed = score.thingsGrazed + 1
							grazeA[math.random(1, #grazeA)]:play()
						end
					end
				end
			end

			if self.cloneSymetry == 1 then
				local hyke = entities.find("hyke")
				self.x, self.y = love.graphics.getWidth()-hyke.x, hyke.y
			end
		else
			Sprite.update(self, dt)
		end
	end,

	draw = function(self, ...)
		love.graphics.draw(shadow, math.floor(self.x), math.floor(self.y), self.r, 1, 1, 8, 8, self.kx, self.ky)
		SolidSprite.draw(self, ...)
	end
}
