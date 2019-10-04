local Image = require("entity.image")
local entities = require("entities")

return Image {
	__name = "bgparalax",

	ratio = 0.2,

	new = function(self, image, options)
		Image.new(self, 0, 0, image, options)
	end,

	draw = function(self)
		love.graphics.push()
		love.graphics.translate(-entities.dxV, -entities.dyV)
		self.x = entities.dxV*self.ratio % 1280 -1280
		Image.draw(self)
		self.x = self.x + 1280
		Image.draw(self)
		self.x = self.x - 1280
		love.graphics.pop()
	end
}
