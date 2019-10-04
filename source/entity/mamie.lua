local Skynet = require("entity.skynet")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/momie_spr.png")

return Skynet {
	__name = "mamie",

	width = 32,
	height = 32,
	ox = 96/2-16, oy = 96/2-16,

	stepDuration = 1200, -- 2 temps
	stepState = 1,
	damage = 2,

	direction = "down",

	realSteps = {
		"left",
		"left",
		"right",
		"right"
	},

	lp = 1, -- by default, 1 jump = death
	pieces = {1,2},
	ouchSound = {
		love.audio.newSource("asset/audio/momie1.ogg", "static"),
		love.audio.newSource("asset/audio/momie2.ogg", "static"),
		love.audio.newSource("asset/audio/momie3.ogg", "static"),
	},

	funnyText = {
		"WHERE ARE MY EYES ?.. Oh here they are",
		"NOO, I don't wanna die !",
		"The curse is over, I'm finally peanut-butter-covered !",
		"I'm the great Ludum XVI",
		"I'm a cat :3",
		"I forgot to rewind myself today"
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

		if self.direction == "up" or self.direction == "down" then
			self.realSteps = {
				"up", "up", "down", "down"
			}
		end

		self:set(self.direction)
		for i, s in ipairs(self.realSteps) do
			if s == self.direction then
				self.stepState = i
				break
			end
		end
	end,

	onStep = function(self)
		self:go(self.realSteps[self.stepState])
		self:set(self.realSteps[self.stepState])

		self.stepState = self.stepState + 1
		if self.stepState > #self.realSteps then
			self.stepState = 1
		end
	end
}
