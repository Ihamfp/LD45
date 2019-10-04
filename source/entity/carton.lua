local Jumpable = require("entity.jumpable")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/caisse_sans_barre.png")--82x70

return Jumpable {
	__name = "carton",

	width = 64, height = 64,
	ox = 64/2-48/2, oy = 64/2-48/2-5,

	lp = 1, -- by default, 1 jump = death
	pieces = {1,2},
	ouchSound = {
		love.audio.newSource("asset/audio/carton.ogg", "static"),
		love.audio.newSource("asset/audio/carton2.ogg", "static"),
		love.audio.newSource("asset/audio/carton3.ogg", "static"),
		love.audio.newSource("asset/audio/carton4.ogg", "static"),
		love.audio.newSource("asset/audio/carton5.ogg", "static"),
	},

	funnyText = {
	},

	new = function(self, x, y, options, lp, human)
		Jumpable.new(self, x, y, options)
		self.lp = lp or 1

		idleg = anim8.newGrid(82, 70, idleImg:getWidth(), idleImg:getHeight())

		self.image.up = idleImg
		self.image.down = idleImg
		self.image.right = idleImg
		self.image.left = idleImg

		self.animation.up = anim8.newAnimation(idleg(1,1), { 1 })

		self:set("up")
	end,

	-- TODO animation
}
