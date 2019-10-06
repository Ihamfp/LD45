local entities = require("entities")

local Entity = require("entity")
local Solid = require("entity.solid")

local armorSprites = {
	love.graphics.newImage("asset/sprite/armor1.png"),
	love.graphics.newImage("asset/sprite/armor2.png"),
	love.graphics.newImage("asset/sprite/armor3.png")
}

return Solid {
	__name = "armor",
	nocollision = true,
	behind = "hyke",
	
	width = 32,
	height = 32,
	
	armorPart = 0, -- no armor available
	
	new = function(self, x, y, part, options)
		self.x = x
		self.y = y
		self.armorPart = part or math.random(1, #armorSprites)
		self.width = armorSprites[self.armorPart]:getPixelWidth()
		self.height = armorSprites[self.armorPart]:getPixelHeight()
		Solid.new(self, options)
	end,
	
	draw = function(self, dx, dy, ...)
		if not armorSprites[self.armorPart] then return end
		love.graphics.draw(armorSprites[self.armorPart], self.x+dx, self.y+dy)
	end,
	
	update = function(self, dt)
		if self.collisions then
			for n,v in pairs(self.collisions) do
				print(n,v)
			end
		end
	end
}
