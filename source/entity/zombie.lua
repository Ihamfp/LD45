local Skynet = require("entity.skynet")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/zomb.png")

local goBack = {
	up = "down",
	down = "up",
	left = "right",
	right = "left"
}

return Skynet {
	__name = "zombie",

	width = 32,
	height = 32,
	ox = 96/2-16, oy = 96/2-16,

	stepDuration = 1200, -- 2 temps
	stepState = 1,

	direction = "down",

	lp = 1, -- by default, 1 jump = death
	pieces = {1,2},
	damage = 2,

	ouchSound = {
		love.audio.newSource("asset/audio/momie1.ogg", "static"),
		love.audio.newSource("asset/audio/momie2.ogg", "static"),
		love.audio.newSource("asset/audio/momie3.ogg", "static"),
	},

	funnyText = {
		"BRAAAAAAINS",
		"I lost my head, this is John's",
		"My eye is not all butter-y...",
		"Oh comme on, I'm not that rotten",
		"I'm not a zombie, I'm a decomposed living dead body",
		"My throat hurts from all this screaming",
		"My arms are locked in place !",
		"<Insert Crash Zoom reference>"
	},

	new = function(self, x, y, options, lp, human)
		Skynet.new(self, x, y, options)
		self.lp = lp or 1

		idleg = anim8.newGrid(96, 96, idleImg:getWidth(), idleImg:getHeight())

		self.image.up = idleImg
		self.image.down = idleImg
		self.image.right = idleImg
		self.image.left = idleImg

		self.animation.up = anim8.newAnimation(idleg("1-2",1), { 0.7, 0.7 })
		self.animation.down = self.animation.up:clone():flipV()
		self.animation.right = anim8.newAnimation(idleg("1-2",2), { 0.7, 0.7 })
		self.animation.left = self.animation.right:clone():flipH()

		self:set(self.direction)
	end,

	onStep = function(self)
		if self:check(self.direction) then
			self.direction = goBack[self.direction]
		end

		self:go(self.direction)

		self:set(self.direction)
	end
}
