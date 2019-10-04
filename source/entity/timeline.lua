local Entity = require("entity")

return Entity {
	__name = "timeline",

	x = 0, y = 0,
	width = 100, height = 10,
	color = { 255, 255, 255, 255 },
	scissor = love.graphics.getWidth(),

	new = function(self, x, y, width, height, arrowSize, options)
		self.x, self.y = x, y
		self.width, self.height = width, height
		self.arrowSize = arrowSize

		Entity.new(self, options)
	end,

	draw = function(self)
		love.graphics.setScissor(self.x, 0, self.scissor, 720)
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.polygon("fill", self.x + self.width - self.arrowSize, self.y + self.height/2 - self.arrowSize,
			self.x + self.width + self.arrowSize, self.y + self.height/2, self.x + self.width - self.arrowSize, self.y + self.height/2 + self.arrowSize)
		love.graphics.setScissor()
	end
}
