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
	
	health = 100,
	food = 100,
	notCold = 100,

	new = function(self, x, y, options)
		SolidSprite.new(self, x, y, options)

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
			
			-- animation & move
			local maxspeed = 70
			if move.right:down() then
				self.direction = "right"
				self:set("right")
				self.vx = math.min(self.vx + 2, maxspeed)
			elseif move.left:down() then
				self.direction = "left"
				self:set("left")
				self.vx = math.max(self.vx - 2, -maxspeed)
			else
				self.vx = 0
			end
			if move.up:down() then
				self.direction = "up"
				self:set("up")
				self.vy = math.max(self.vy - 2, -maxspeed)
			elseif move.down:down() then
				self.direction = "down"
				self:set("down")
				self.vy = math.min(self.vy + 2, maxspeed)
			else
				self.vy = 0
			end

			-- move
			self:move(self.vx * dt, self.vy * dt)

			--[[if not self.jumping then
				self.animSpeedUp = math.log(self.speed / 8)
			end]]

			-- collide
			for _, c in ipairs(self.collisions) do
				local o = c.other
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
				end
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
