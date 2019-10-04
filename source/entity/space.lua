local Jumpable = require("entity.jumpable")
local anim8 = require("anim8")
local entities = require("entities")

local idleImg = {
	love.graphics.newImage("asset/sprite/space_tier_1_v3.png"),
	love.graphics.newImage("asset/sprite/space_tier_2.png"),
 	love.graphics.newImage("asset/sprite/space_tier_3.png")
}

return Jumpable {
	__name = "space",

	noCollision = true,

	width = 64, height = 64,
	ox = 64/2-48/2, oy = 64/2-48/2,

	lp = 1, -- by default, 1 jump = death
	tier = 1,
	pieces = 0,
	ouchSound = {
		love.audio.newSource("asset/audio/groscarton.ogg", "static")
	},

	funnyText = {
	},

	new = function(self, x, y, options, lp, human)
		Jumpable.new(self, x, y, options)
		self.lp = lp or 1

		idleg = anim8.newGrid(64, 64, idleImg[self.tier]:getWidth(), idleImg[self.tier]:getHeight())

		self.image.up = idleImg[self.tier]

		self.animation.up = anim8.newAnimation(idleg(1,1), { 1 })

		self:set("up")
	end,

	jumpover = function(self)
		if self.lp > 0 then
			local SS = entities.find("spacestack"):add(self.tier)
		end

		Jumpable.jumpover(self)
	end

	-- TODO animation
}
