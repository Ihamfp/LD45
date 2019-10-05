local bump = require("bump")
local Entity = require("entity")

return Entity {
	__name = "scrollworld",

	new = function(self, image, options)
		Entity.new(self, options)
		
		self.color = { 1.0, 1.0, 1.0, 1.0 }
		self.image = love.graphics.newImage("asset/sprite/"..image)
		self.x = 0
		self.y = 0
		self.world = bump.newWorld()
	end,
	
	--[[update = function(self, dt)
		self.x = self.x + 1
		self.y = self.y + 1
	end,]]
	
	draw = function(self, dx, dy, sx, sy)
		love.graphics.setColor(self.color)
		love.graphics.draw(self.image, self.x+dx, self.y+dy)
	end
}
