local Skynet = require("entity.skynet")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/vendeur_en_crise_existentielle.png")

local steps = {
	"down",
	"down",
	"right",
	"right",
	"up",
	"up",
	"left",
	"left"
}

return Skynet {
	__name = "vendeur",

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
		love.audio.newSource("asset/audio/ouch1.ogg", "static"),
		love.audio.newSource("asset/audio/ouch2.ogg", "static"),
		love.audio.newSource("asset/audio/ouch3.ogg", "static"),
		love.audio.newSource("asset/audio/ouch4long.ogg", "static"),
		love.audio.newSource("asset/audio/ouch5.ogg", "static"),
		love.audio.newSource("asset/audio/ouch6.ogg", "static"),
		love.audio.newSource("asset/audio/ouch7.ogg", "static"),
		love.audio.newSource("asset/audio/ouch8.ogg", "static"),
		love.audio.newSource("asset/audio/ouch9.ogg", "static"),
		love.audio.newSource("asset/audio/ouch10.ogg", "static"),
		love.audio.newSource("asset/audio/ouch11.ogg", "static"),
		love.audio.newSource("asset/audio/ouch12.ogg", "static"),
		love.audio.newSource("asset/audio/sellerscream.ogg", "static"),
	},

	funnyText = {
		"So you don't want our loyalty card...",
		"May I help you ? Oh no I'm dead.",
		"You still owe us $120",
		"NOT ON MY WORK SUIT!",
		"I use to be a peanut-butter seller, just like you...",
		"Where did you get this butter ? Did you STEAL it ?",
		"Hey I sell this game ! definitely 5/5 !"
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
		for i, s in ipairs(steps) do
			if s == self.direction then
				self.stepState = i
				break
			end
		end
	end,

	onStep = function(self)
		self:go(steps[self.stepState])
		self:set(steps[self.stepState])

		self.stepState = self.stepState + 1
		if self.stepState > #steps then
			self.stepState = 1
		end
	end
}
