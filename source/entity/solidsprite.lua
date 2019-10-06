-- bcuz constructor inheritance

local Sprite = require("entity.sprite")
local Solid = require("entity.solid")

return Solid(Sprite) {
	__name = "solidsprite",

	-- Methods
	new = function(self, x, y, options)
		Sprite.new(self, x, y, options)
		Solid.new(self)
	end,

	draw = function(self, dx, dy)
		Sprite.draw(self, dx, dy)
		--love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end
}
