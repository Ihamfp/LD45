local Jumpable = require("entity.jumpable")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/client_1.png")
local idleImg2 = love.graphics.newImage("asset/sprite/client_2.png")

local scene = require("ubiquitousse").scene


local nMurder = 0

return Jumpable {
	__name = "gen",

	width = 32,
	height = 32,
	ox = 64/2-16, oy = 64/2-16,

	lp = 1, -- by default, 1 jump = death
	pieces = 0,
	ouchSound = {
		love.audio.newSource("asset/audio/humanscream.ogg", "static"),
		love.audio.newSource("asset/audio/humanscream2.ogg", "static"),
		love.audio.newSource("asset/audio/humanscream3.ogg", "static"),
		love.audio.newSource("asset/audio/wilhelmscream.ogg", "static")
	},

	funnyText = {
		"WHY?",
		"Noooooooo...",
		"Heh, I guess",
		"But... I'm not allergic to peanuts!",
		"Thanks!",
		"Your shoes smell nice",
		"I'll never be able to finish my brown chairs collection!",
		"WHY DOES EVERYONE LOOK LIKE ME?",
		"Ah-ah! Now that I'm dead I don't care about you, you lose!",
		"I wish people would be as nice as you",
		"I have nothing to say.",
		"Heh. Not a bad way to go.",
		"I can't die yet! UNICORNS STILL DON'T EXIST",
		"Please take care of my rocks collection, PLEASE",
		"This game is stupid.",
		"This was predictable.",
		"I make a great gaspacho."
	},

	new = function(self, x, y, options, lp, human)
		Jumpable.new(self, x, y, options)
		self.lp = lp or 1

		idleg = anim8.newGrid(64, 64, idleImg:getWidth(), idleImg:getHeight())

		if math.random(1,2) == 1 then
			self.image.up = idleImg
		else
			self.image.up = idleImg2
		end

		self.animation.up = anim8.newAnimation(idleg(1,1), { 1 })

		self:set("up")
	end,

	update = function(self, dt)
		Jumpable.update(self, dt)
		self.oy = 64/2-16 + math.sin(scene.current.time:get()/100)
	end,

	die = function(self, ...)
		Jumpable.die(self, ...)
		if nMurder == 0 then
			require("entity.hud.achievement"):new("Your first murder", love.graphics.newImage("asset/sprite/achievements/sk1.png"))
			nMurder = 1
		elseif nMurder == 1 then
			require("entity.hud.achievement"):new("Your second murder", love.graphics.newImage("asset/sprite/achievements/sk2.png"))
			nMurder = 2
		elseif nMurder == 2 then
			require("entity.hud.achievement"):new("You're now a serial killer according to Wikipedia", love.graphics.newImage("asset/sprite/achievements/sk3.png"))
			nMurder = 3
		end
	end

	-- TODO animation
}
