local util = require("util")
local uqt = require("ubiquitousse")

local entities = require("entities")
local pointer = require("input").pointer
local scene = require("ubiquitousse.scene")

local Text = require("entity.text")
local Image = require("entity.image")
local Shockwave = require("entity.shockwave")

local unlocked = love.audio.newSource("asset/audio/miracleunlocked.wav", "static")

local function errorMargin(val, err)
	if math.random() < 0.5 then
		return val + err*val*math.random()
	else
		return val - err*val*math.random()
	end
end

local Sprite = require("entity.sprite")
local anim8 = require("anim8")
local pointer = require("input").pointer
local interact = require("input").interact
local examine = require("input").examine
local entities = require("entities")
local Interactable = require("entity.interactable")
local dialog = require("dialog")
local s = require("ubiquitousse.scene")

local VFX = Sprite {
	__name = "vfx",

	new = function(self, x, y, image, n, t, options)
		Sprite.new(self, x, y, options)

		self.image.def = love.graphics.newImage("asset/sprite/"..image)
		local g = anim8.newGrid(self.image.def:getWidth()/n, self.image.def:getHeight(), self.image.def:getWidth(), self.image.def:getHeight())
		self.animation.def = anim8.newAnimation(g("1-"..n,1), 0.15)

		self:set("def")

		scene.current.time.run(function()
			self:remove()
		end):after(t)
	end
}

return Image {
	__name = "powerIcon",

	-- internal
	cooledDown = true,
	cooldownTimer = 0,
	population = {},
	unlocked = false, -- set to true after first activation
	didThePlatform = false,

	-- data
	cooldown = 1,
	minBelievers = 0,
	believers = 0,
	death = 0,
	error = 0,
	zones = { -- max effect, in % of other properties (order is significant)
		--{ "forest", 1 }
	},
	icon = nil,

	unlockIn = "stonehedge",
	unlockName = "power1",
	unlockZik = "In quest of Power.ogg",

	-- information
	title = "Generic miracle",
	description = "Average",

	-- effects
	shockwave = {
		radius = 10, width = 50,
		duration = 400, finalRadius = 100,
		shake = 2, shakeDuration = 50
	},
	sfx = "NONE",

	new = function(self, x, y, icon, population, options)
		Image.new(self, x, y, icon, options)
		self.icon = icon
		self.population = population
		self.hoverText = Text:new("Stanberry.ttf", 20, {
			{255,255,255,255}, "CLICK TO UNLOCK MIRACLE\n",
			{180,180,180,255}, "on the field, by yourself"
		}, 0, 0, {
			visible = false,
			limit = 1280,
			shadowColor = { 0, 0, 0, 255 },
			alignY = "center",
			aboveAll = true
		})
		if self.didThePlatform then
			self.hoverText.text = {
				{240, 60,  25 }, self.title.."\n",
				{255, 255, 255}, self.description.."\n",
				{180, 180, 180}, "Cooldown: "..self.cooldown.."s\n",
				{180, 180, 180}, "Potential new worshippers: "..self.believers.."\n",
				{180, 180, 180}, "Potential death ratio: "..math.ceil(self.death/self.believers*100).."%\n",
				{180, 180, 180}, "Margin of error: "..math.ceil(self.error*100).."%\n",
			}
		end
		if self.sfx ~= "TODO" then self.sfx = love.audio.newSource("asset/audio/"..self.sfx, "static") end
	end,

	interact = function(self)
		if self:condition() and self.cooledDown and self.didThePlatform then
			self.unlocked = true
			self.cooldownTimer = 0
			self.cooledDown = false

			scene.current.time.run(function()
				self.cooledDown = true
				self.cooldownTimer = 0
			end):after(self.cooldown*1000)
			scene.current.time.run(function()
				self.cooldownTimer = self.cooldownTimer +0.1
			end):during(self.cooldown*1000):every(100)

			Shockwave:new(self.x +16, self.y +16, self.shockwave)
			self.sfx:play()

			local zone = self.population[self.zones[1][1]]
			local vfx = VFX:new(self.vfxX, self.vfxY, self.vfx, self.singleVfx and 1 or 2, self.vfxT or self.shockwave.duration)

			if self.customAction then self:customAction() end

			local remainingBelievers = self.believers
			local remainingDeath = self.death
			for _, zoneEffect in ipairs(self.zones) do
				local zone = self.population[zoneEffect[1]]

				local newPop = math.max(0, math.ceil(zone.population - math.min(errorMargin(self.death * zoneEffect[2], self.error), remainingDeath)))
				if newPop ~= zone.population then
					if newPop < zone.believers then
						local deaths = Text:new("Stanberry.ttf", 20, (zone.population - newPop).." deaths (-"..(zone.believers-newPop).." worshippers)", zone[1], zone[2] + zone[4]/2, {
							limit = zone[3], alignX = "center",
							color = { 230, 50, 30, 0 },
							shadowColor = {0, 0, 0, 0}
						})
						scene.current.time.tween(500, deaths, {
							y = zone[2] -10,
						}, "outCubic")
						scene.current.time.tween(500, deaths.color, { 230, 50, 30, 255}, "outCubic")
							:chain(500, {230, 50, 30, 0}):after(1000)
						scene.current.time.tween(500, deaths.shadowColor, {0,0,0,255}, "outCubic")
							:chain(500, {0,0,0,0}):after(1000)
							:onEnd(function() if deaths.remove ~= true then deaths:remove() end end)

						if zone.mortals then
							local believersToKill = zone.believers-newPop
							local nonBelieversToKill = zone.population - newPop - believersToKill
							for _, m in ipairs(zone.mortals) do
								if believersToKill > 0 and m.believe and m.remove ~= true then
									m:kill()
									believersToKill = believersToKill -1
								end
								if nonBelieversToKill > 0 and not m.believe and m.remove ~= true then
									m:kill()
									nonBelieversToKill = nonBelieversToKill -1
								end
							end
						end

						self.population.believers = self.population.believers - (zone.believers-newPop)
						zone.believers = newPop
					else
						local deaths = Text:new("Stanberry.ttf", 20, "+"..(zone.population - newPop).." deaths", zone[1], zone[2] + zone[4]/2, {
							limit = zone[3], alignX = "center",
							color = { 230, 50, 30, 0 },
							shadowColor = {0, 0, 0, 0}
						})
						scene.current.time.tween(500, deaths, {
							y = zone[2] -10,
						}, "outCubic")
						scene.current.time.tween(500, deaths.color, { 230, 50, 30, 255}, "outCubic")
							:chain(500, {230, 50, 30, 0}):after(1000)
						scene.current.time.tween(500, deaths.shadowColor, {0,0,0,255}, "outCubic")
							:chain(500, {0,0,0,0}):after(1000)
							:onEnd(function() if deaths.remove ~= true then deaths:remove() end end)

						if zone.mortals then
							local nonBelieversToKill = zone.population - newPop
							for _, m in ipairs(zone.mortals) do
								if nonBelieversToKill > 0 and not m.believe and m.remove ~= true then
									m:kill()
									nonBelieversToKill = nonBelieversToKill -1
								end
							end
						end
					end
				end
				remainingDeath = remainingDeath - (zone.population - newPop)
				self.population.total = self.population.total - (zone.population - newPop)
				zone.population = newPop

				local newBelievers = math.min(zone.population - zone.believers, math.ceil(math.min(errorMargin(self.believers * zoneEffect[2], self.error), remainingBelievers)))
				newBelievers = math.max(0, newBelievers)
				if newBelievers ~= 0 then
					local deaths = Text:new("Stanberry.ttf", 20, "+"..(newBelievers).." worshippers", zone[1], zone[2] + zone[4]/2, {
						limit = zone[3], alignX = "center",
						color = { 20, 200, 20, 0 },
						shadowColor = {0, 0, 0, 0}
					})
					scene.current.time.tween(500, deaths, {
						y = zone[2] -30,
					}, "outCubic")
					scene.current.time.tween(500, deaths.color, { 20, 200, 20, 255}, "outCubic")
						:chain(500, {20, 200, 20, 0}):after(1000)
					scene.current.time.tween(500, deaths.shadowColor, {0,0,0,255}, "outCubic")
						:chain(500, {0,0,0,0}):after(1000)
						:onEnd(function() if deaths.remove ~= true then deaths:remove() end end)

					if zone.mortals then
						local nonBelieversToConvert = newBelievers
						for _, m in ipairs(zone.mortals) do
							if nonBelieversToConvert > 0 and not m.believe then
								m:convert()
								nonBelieversToConvert = nonBelieversToConvert -1
							end
						end
					end
				end
				remainingBelievers = remainingBelievers - newBelievers
				self.population.believers = self.population.believers + newBelievers
				zone.believers = zone.believers + newBelievers

				if zone.popularity then
					local newPopu = math.ceil(self.believers * zoneEffect[2])
					if newPopu ~= 0 then
						local deaths = Text:new("Stanberry.ttf", 20, "+"..(newPopu).." popularity", zone[1], zone[2] + zone[4]/2, {
							limit = zone[3], alignX = "center",
							color = { 20, 200, 20, 0 },
							shadowColor = {0, 0, 0, 0}
						})
						scene.current.time.tween(500, deaths, {
							y = zone[2] -50,
						}, "outCubic")
						scene.current.time.tween(500, deaths.color, { 20, 200, 20, 255}, "outCubic")
							:chain(500, {20, 200, 20, 0}):after(1000)
						scene.current.time.tween(500, deaths.shadowColor, {0,0,0,255}, "outCubic")
							:chain(500, {0,0,0,0}):after(1000)
							:onEnd(function() if deaths.remove ~= true then deaths:remove() end end)
					end
					self.population.popularity = self.population.popularity + newPopu
					zone.popularity = zone.popularity + newPopu
				end
			end
		elseif self:condition() and not self.didThePlatform then
			local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
				color = {255,255,255,0}
			})
			scene.current.time.tween(800, rect.color, {[4]=255})
			:onEnd(function()
				rect:remove()
				uqt.scene.push("platlevel", self)
				self.didThePlatform = true
				self.hoverText.text = {
					{240, 60,  25 }, self.title.."\n",
					{255, 255, 255}, self.description.."\n",
					{180, 180, 180}, "Cooldown: "..self.cooldown.."s\n",
					{180, 180, 180}, "Potential new worshippers: "..self.believers.."\n",
					{180, 180, 180}, "Potential death ratio: "..math.ceil(self.death/self.believers*100).."%\n",
					{180, 180, 180}, "Margin of error: "..math.ceil(self.error*100).."%\n",
				}
			end)
		end
	end,

	examine = function(self)
		if self:condition() then
			self.hoverText.visible = 1

			local width = 0
			for i=2, #self.hoverText.text, 2 do
				width = math.max(self.hoverText.font:getWidth(self.hoverText.text[i]), width)
			end

			local x, y = pointer:x()+40, pointer:y()

			if width + x > 1280 then
				x = x - width -40
			end

			self.hoverText.x, self.hoverText.y = x, y
		else
			return false
		end
	end,

	collide = function(self, x, y, w, h)
		if type(x) == "table" then
			x, y, w, h = x.x, x.y, x.width, x.height
		end
		return util.aabb(x, y, w, h, self.x, self.y, 32, 32)
	end,

	draw = function(self)
		if self:condition() then
			if not self.firstDraw then
				unlocked:play()
			end
			self.firstDraw = true
			Image.draw(self)
			if not self.cooledDown then
				love.graphics.setColor(255, 255, 255, 200)
				love.graphics.rectangle("fill", self.x, self.y, 32, 32 - self.cooldownTimer/self.cooldown *32)
			end
		end
	end,

	condition = function(self)
		return self.population.believers >= self.minBelievers
	end
}
