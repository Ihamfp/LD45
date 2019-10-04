local Skynet = require("entity.skynet")
local anim8 = require("anim8")
local theme = require("entity.themeslaughter")
local entities = require("entities")
local scene = require("ubiquitousse").scene

local idleImg = love.graphics.newImage("asset/sprite/bosssprite.png")
local wouuuuish = love.audio.newSource("asset/audio/laser.ogg", "static")
local bang = love.audio.newSource("asset/audio/groscarton.ogg", "static")
local BOUM = love.audio.newSource("asset/audio/bidboum.ogg", "static")

local stepN = 0

-- 96x96,  1152x96
-- 96x640, 1152x640

return Skynet {
	__name = "boss",

	width = 40,
	height = 40,
	ox = 96/2-18, oy = 96/2-16,

	stepDuration = 1200, -- 2 temps
	stepState = 1,

	direction = "down",
	noCollision = true,
	ignoreDamage = true,
	invincible = true,

	state = 1,

	lp = 42, -- by default, 1 jump = death
	pieces = 50,
	damage = 1,

	easifier = 1,

	ouchSound = {
	},

	funnyText = {
	},

	new = function(self, x, y, options, lp, human)
		Skynet.new(self, x, y, options)

		idleg = anim8.newGrid(128, 128, idleImg:getWidth(), idleImg:getHeight())

		self.image.up = idleImg
		self.image.down = idleImg
		self.image.right = idleImg
		self.image.left = idleImg

		self.animation.down = anim8.newAnimation(idleg(1,1), { 0.7})
		self.animation.up = self.animation.down:clone():flipV()
		self.animation.right = anim8.newAnimation(idleg(1,2), { 0.7 })
		self.animation.left = self.animation.right:clone():flipH()

		self:set(self.direction)

		self.nextSlash = { 200, 0, "down" }
	end,

	onStep = function(self)
		theme.noCollision = true

		local hyke = entities.find("hyke")
		local hyke1 = entities.find("hyke1")
		entities.shake = 0

		if hyke.x < 30 or hyke.x > 1220 or hyke.y < 30 or hyke.y > 700 then
			hyke.x, hyke.y = 615, 660
			hyke:updateSize()
		end

		stepN = stepN +1

		if self.state == 1 then
			if stepN % 2*self.easifier == 0 then
				theme:new(self.nextSlash[1], self.nextSlash[2], self.nextSlash[3])
				if stepN <= 5 then
					if math.random(1,2) == 1 then -- horiz
						local x, y = hyke.x, 0
						if hyke1 and math.random(1,2) == 1 then x, y = hyke1.x, 0 end
						self.nextSlash = { x, y, "down" }
					else -- vert
						if math.random(1,2) == 1 then -- left
							local x, y = 0, hyke.y
							if hyke1 and math.random(1,2) == 1 then x, y = 0, hyke1.y end
							self.nextSlash = { x, y, "right" }
						else
							local x, y = love.graphics.getWidth(), hyke.y
							if hyke1 and math.random(1,2) == 1 then x, y = love.graphics.getWidth(), hyke1.y end
							self.nextSlash = { x, y, "left" }
						end
					end
					if self.nextSlash[3] == "down" then
						self:goTo(self.nextSlash[1], 30)
					elseif self.nextSlash[3] == "right" then
						self:goTo(20, self.nextSlash[2])
					else
						self:goTo(love.graphics.getWidth()-70, self.nextSlash[2])
					end
					self:set(self.nextSlash[3])
				else
					self.noStep = true
					scene.current.time.run(function()
						self:goTo(600, 30)
						self:set("down")
					end)
					:chain(function()
						-- NOT HAPPY
						self:go("left")
					end):after(300)
					:chain(function()
						self:goTo(self.x+64*2, self.y, 200, 1.5)
					end):after(500)
					:chain(function()
						self:goTo(self.x-64*2, self.y, 200, 1.5)
					end):after(500)
					:chain(function()
						self:goTo(self.x+64*2, self.y, 200, 1.5)
					end):after(500)
					:chain(function()
						self:goTo(self.x-64*2, self.y, 200, 1.5)
					end):after(500)
					:chain(function()
						self:goTo(self.x, self.y, 150, 1.7)
					end):after(1000)
					:onEnd(function()
						stepN = 0
						self.state = 2
						self.noStep = false
						self.jumpZoom = 1.5
					end)
				end
			end
		elseif self.state == 2 then
			if stepN % 1*self.easifier == 0 then
				theme:new(self.nextSlash[1], self.nextSlash[2], self.nextSlash[3])
				if stepN < 15 then
					if math.random(1,2) == 1 then -- horiz
						local x, y = hyke.x, 0
						if hyke1 and math.random(1,2) == 1 then x, y = hyke1.x, 0 end
						self.nextSlash = { x, y, "down" }
					else -- vert
						if math.random(1,2) == 1 then -- left
							local x, y = 0, hyke.y
							if hyke1 and math.random(1,2) == 1 then x, y = 0, hyke1.y end
							self.nextSlash = { x, y, "right" }
						else
							local x, y = love.graphics.getWidth(), hyke.y
							if hyke1 and math.random(1,2) == 1 then x, y = love.graphics.getWidth(), hyke1.y end
							self.nextSlash = { x, y, "left" }
						end
					end
					if self.nextSlash[3] == "down" then
						self:goTo(self.nextSlash[1], 30)
					elseif self.nextSlash[3] == "right" then
						self:goTo(20, self.nextSlash[2])
					else
						self:goTo(love.graphics.getWidth()-70, self.nextSlash[2])
					end
					self:set(self.nextSlash[3])
				else
					self.noStep = true
					scene.current.time.run(function()
						self:goTo(600, 30)
						self:set("down")
					end)
					:chain(function()
						self:goTo(self.x, self.y, 300, 1.6)
					end):after(300)
					:chain(function()
						self:goTo(self.x, self.y, 500, 1.7)
					end):after(700)
					:chain(function()
						self:goTo(self.x, self.y, 600, 1.8)
					end):after(1100)
					:chain(function()
						stepN = 0
						self.state = 3
						self.noStep = false
					end):after(1800)
				end
			end
		elseif self.state == 3 then
			if stepN == 1 then
				self.noStep = true
				local x, y = 0, 0
				scene.current.time.run(function()
					theme:new(x, y, "down")
					theme:new(1152-x, y, "down")
					x = x + 64
				end)
				:every(self.stepDuration/2)
				:stopWhen(function()
					return x > 1152/2-65
				end)
				:chain(function()
					self:goTo(15, 90, 400, 1.8)
					self:set("right")
				end):after(800)
				:chain(function()
					stepN = 0
					self.state = 4
					self.noStep = false
					rectangoulous = require("entity.rectangle"):new(self.x+20, self.y+16, 5000, 1, {color = {1,.7,.7,1}})
					wouuuuish:play()
				end):after(2000)
			end
		elseif self.state == 4 then
			self:goTo(self.x, self.y)
			rectangoulous.remove = true
			self.noStep = true
			local laser = require("entity.deadlylaser"):new(self.x+5, self.y)
			scene.current.time.run(function()
				laser.y = laser.y + 150*love.timer.getDelta()
				self.y = laser.y
				laser:updateSize()
				self:updateSize()
			end)
			:repeatWhile(function()
				local r= laser.y < 680
				if not r then
					laser.remove = true
					laser.noCollision = true
					laser.ignoreDamage = true
				end
				return r
			end)
			:chain(function()
				self:goTo(625, 345, 800, 2)
			end):after(700)
			:chain(function()
				self.noCollision = false
				self.invincible = false
				self.ignoreDamage = false
				stepN = 0
				self.state = 5
				self.noStep = false
			end):after(1600)
		end
	end,

	jumpover = function(self)
		Skynet.jumpover(self)

		scene.current.time.run(function()
			self.color = { math.random(), math.random(), math.random(), math.random() }
		end):during(300)
		:onEnd(function()
			self.color = { 1, 1, 1, 1 }
		end)

		if self.state == 5 then
			local hyke1 = entities.find("hyke1")
			if not hyke1 then
				local hyke = entities.find("hyke")
				self.noCollision = true
				self.invincible = true
				self.ignoreDamage = true
				entities.shake = 50
				scene.current.time.run(function()
					entities.shake = 0
				end):after(300)
				:chain(function()
					scene.current.zik:stop()
					lolrofl = require("entity.text"):new(font.Stanberry[22], "Gah! This is too easy! I'll pick a REAL theme to make this battle more interesting!", love.graphics.getWidth()/2, love.graphics.getHeight()/2-50, {
						alignX = "center",
						alignY = "center",
						shadowColor = {0,0,0,1},
						__name = "lolrofl"
					})
				end):after(1000)
				scene.current.time.run(function()
					self:goTo(600, 30, 300, 1.4)
					self:set("down")
					lolrofl.remove = true
				end):after(4000)
				:chain(function()
					supertheme = require("entity.text"):new(font.PerfectDOS[120], "Two points of view", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
						alignX = "center",
						alignY = "center",
						shadowColor = {0,1,0,1},
						__name = "supertheme"
					})
					bang:play()
				end)
				:chain(function()
					superthemeRect = require("entity.rectangle"):new(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), {
						color = {0,0,0,1},
						behind = "supertheme",
						__name = "superthemerect"
					})
					hyke.freeze = true
					hyke.direction = "up"
					hyke:set("up")
					hyke.speed = 0
					hyke.x, hyke.y = 250, 500
					require("entity.hyke"):new(1152-(hyke.x-96), hyke.y, {
						freeze = true,
						cloneSymetry = 1,
						behind = "superthemerect"
					})
					theme.noCollision = true
					bang:play()
				end):after(800)
				:chain(function()
					superthemeRect.remove = true
					bang:play()
				end):after(2500)
				:chain(function()
					supertheme.remove = true
					hyke.freeze = false
					hyke.buttering = require("entity.butter"):new(hyke.x, hyke.y)
					local hyke1 = entities.find("hyke1")
					hyke1.freeze = false

					scene.current.zik = love.audio.newSource("asset/audio/Face_the_Genie_of_the_Forgotten_Themes_-_moderate.ogg", "static")
					scene.current.zik:setLooping(true)
					scene.current.zik:play()

					bang:play()
				end):after(700)
				:chain(function()
					stepN = 0
					self.state = 1
					self.easifier = 2
				end):after(5000)

			else
				local hyke = entities.find("hyke")
				self.noCollision = true
				self.invincible = true
				self.ignoreDamage = true
				entities.shake = 60
				scene.current.time.run(function()
					entities.shake = 0
				end):after(300)
				:chain(function()
					scene.current.zik:stop()
					lolrofl = require("entity.text"):new(font.Stanberry[22], "NO! You can't win! Bad themes and ideas shouldn't win!", love.graphics.getWidth()/2, love.graphics.getHeight()/2-50, {
						alignX = "center",
						alignY = "center",
						shadowColor = {0,0,0,1},
						__name = "lolrofl"
					})
				end):after(1000)
				:chain(function()
					lolrofl.text = "I know what I have to do! Take this!"
				end):after(5000)
				:chain(function()
					supertheme = require("entity.text"):new(font.PerfectDOS[120], "Death is useful", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
						alignX = "center",
						alignY = "center",
						shadowColor = {1,0,0,1},
						__name = "supertheme"
					})
					bang:play()
				end):after(3000)
				:chain(function()
					superthemeRect = require("entity.rectangle"):new(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), {
						color = {0,0,0,1},
						behind = "supertheme",
						__name = "superthemerect"
					})

					hyke.freeze = true
					hyke.direction = "up"
					hyke:set("up")
					hyke.speed = 0
					hyke.x, hyke.y = 250, 400
					hyke:updateSize()

					hyke1.freeze = true
					hyke1.direction = "up"
					hyke1:set("up")
					hyke1.speed = 0
					hyke1.x, hyke1.y = love.graphics.getWidth()-250, 400
					hyke1:updateSize()

					theme.noCollision = true
					bang:play()
				end):after(1500)
				:chain(function()
					superthemeRect.remove = true
					lolrofl.text = "Now if you kill me, I win. I think."
					bang:play()
				end):after(2500)
				:chain(function()
					supertheme.remove = true
					hyke.freeze = false
					hyke.buttering = require("entity.butter"):new(hyke.x, hyke.y)
					hyke1.buttering = require("entity.butter"):new(hyke1.x, hyke1.y)
					self.noCollision = false
					self.invincible = false
					self.ignoreDamage = true
					hyke1.freeze = false

					scene.current.zik = love.audio.newSource("asset/audio/Face_the_Genie_of_the_Forgotten_Themes_-_fast.ogg", "static")
					scene.current.zik:setLooping(true)
					scene.current.zik:play()

					bang:play()
				end):after(700)
				:chain(function()
					stepN = 0
					self.state = 6
					lolrofl.remove = true
				end):after(3000)
			end
		elseif self.state == 6 then
			local hyke = entities.find("hyke")
			local hyke1 = entities.find("hyke1")
			self.noCollision = true
			self.invincible = true
			self.ignoreDamage = true
			entities.shake = 80
			scene.current.time.run(function()
				entities.shake = 0
			end):after(300)
			:chain(function()
				lolrofl = require("entity.text"):new(font.Stanberry[22], "I... I'm surprised this didn't work. Well, too bad. Bye!", love.graphics.getWidth()/2, love.graphics.getHeight()/2-50, {
					alignX = "center",
					alignY = "center",
					shadowColor = {0,0,0,1},
					__name = "lolrofl"
				})
			end):after(1000)
			:chain(function()
				BOUM:play()
				self:go("left")
			end):after(5000)
			:chain(function()
				self:go("up")
			end):after(700)
			:chain(function()
				self:go("up")
			end):after(600)
			:chain(function()
				self:go("right")
			end):after(400)
			:chain(function()
				self:go("left")
			end):after(300)
			:chain(function()
				self:go("down")
			end):after(200)
			:chain(function()
				self:go("up")
			end):after(200)
			:chain(function()
				self:go("up")
			end):after(200)
			:chain(function()
				self:go("left")
			end):after(200)
			:chain(function()
				self:go("left")
			end):after(200)
			:chain(function()
				self:go("right")
			end):after(200)
			:chain(function()
				self:go("down")
			end):after(200)
			:chain(function()
				self:goTo(self.x, -50)
			end):after(700)
			:chain(function()
				entities.freeze = true
				local name = scene.current.name
				local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
					hud = true,
					color = {1,1,1,0}
				})
				scene.current.time.tween(500, rect.color, {[4]=1})
				:onEnd(function()
					rect.remove = true
					entities.freeze = false
					scene.switch("inbetweenlevels", scene.current.score, scene.current.name, "ending")
				end)
			end):after(1000)
		end
	end
}
