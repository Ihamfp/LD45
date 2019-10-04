local Entity = require("entity")

return Entity {
	__name = "rectangle",

	x = 0, y = 0,
	width = 100, height = 10,
	color = { 255, 255, 255, 255 },

	new = function(self, x, y, width, height, options)
		self.x, self.y = x, y
		self.width, self.height = width, height

		Entity.new(self, options)
	end,

	draw = function(self)
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end
}
