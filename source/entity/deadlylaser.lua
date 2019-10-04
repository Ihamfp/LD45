-- bcuz constructor inheritance

local Solid = require("entity.solid")
local entities = require("entities")

-- Lasers are fancy rectangles
return Solid {
	__name = "laser",

	damage = 2,
	pieces = {1,2},
	lp = 1,

	ox = 0, oy = 0,
	sx = 1, sy = 1,

	jumpable = true,
	behind = "hyke",
	noCollision = true,

	-- Methods
	new = function(self, x, y, options)
		self.x, self.y = x, y
		self.width = 5000
		self.height = 30
		Solid.new(self)
	end,

	draw = function(self)
		love.graphics.setColor(1, math.random()*.4, math.random()*.2, 1)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end
}
