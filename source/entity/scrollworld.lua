local bump = require("bump")
local Entity = require("entity")
local entities = require("entities")

return Entity {
	__name = "scrollworld",
	noCollisions = true,

	new = function(self, image, options)
		Entity.new(self, options)
		
		self.color = { 1.0, 1.0, 1.0, 1.0 }
		self.image = love.graphics.newImage("asset/sprite/"..image)
		self.x = 0
		self.y = 0
		self.width = self.image:getPixelWidth()
		self.height = self.image:getPixelHeight()
		self.world = bump.newWorld(64)
	end,
	
	update = function(self, dt)
		local hyke = entities.find("hyke")
		if not hyke then return end
		-- I wanted to scroll the map here, but meh
	end,
	
	draw = function(self, dx, dy, sx, sy)
		love.graphics.setColor(self.color)
		love.graphics.draw(self.image, self.x+dx, self.y+dy)
	end
}
