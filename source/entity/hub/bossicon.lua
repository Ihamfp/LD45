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
local Rectangle = require("entity.rectangle")

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
	__name = "bossIcon",

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
		radius = 10, width = 255,
		duration = 3000, finalRadius = 1500,
		shake = 50, shakeDuration = 2000
	},
	sfx = "Gong.wav",

	new = function(self, population, options)
		Image.new(self, 90, 75, "icoboss.png", options)
		self.icon = "icoboss.png"
		self.population = population
		self.hoverText = Text:new("Stanberry.ttf", 20, {
			{255,255,255,255}, "CLICK TO CONFRONT BAD UMPISH",
		}, 0, 0, {
			visible = false,
			limit = 1280,
			shadowColor = { 0, 0, 0, 255 },
			alignY = "center",
			aboveAll = true
		})
		self.sfx = love.audio.newSource("asset/audio/"..self.sfx, "static")
	end,

	interact = function(self)
		if self:condition() then
			self.unlocked = true
			self.cooldownTimer = 0
			self.cooledDown = false

			scene.current.time.run(function()
				local rect = Rectangle:new(0, 0, 1280, 720, {
					color = {255,255,255,0}
				})
				scene.current.time.tween(2000, rect.color, {[4]=255})
					:onEnd(function()
						scene.switch("finalboss")
					end)
			end):after(1000)

			Shockwave:new(self.x +32, self.y +32, self.shockwave)
			self.sfx:play()

			--local zone = self.population[self.zones[1][1]]
			--local vfx = VFX:new(self.vfxX, self.vfxY, self.vfx, self.singleVfx and 1 or 2, self.vfxT or self.shockwave.duration)

			if self.customAction then self:customAction() end
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
		return util.aabb(x, y, w, h, self.x, self.y, 64, 64)
	end,

	draw = function(self)
		if self:condition() then
			if not self.firstDraw then
				unlocked:play()
			end
			self.firstDraw = true
			Image.draw(self)
			if not self.cooledDown then
				--love.graphics.setColor(255, 255, 255, 200)
				--love.graphics.rectangle("fill", self.x, self.y, 32, 32 - self.cooldownTimer/self.cooldown *32)
			end
		end
	end,

	condition = function(self)
		return self.population.believers / self.population.total >= 0.95
	end
}
