local Sprite = require("entity.sprite")

local entities = require("entities")

return Sprite {
	__name = "bars",
	hud = true,
	
	x = 10,
	y = 10,
	width = 128,
	height = 24,
	spacing = 10,
	
	new = function(self, options)
		Sprite.new(self, self.x, self.y, options)
		self.parts = parts or {}
		
		self.healthMax = 100
		self.foodMax = 100
		self.notColdMax = 100
	end,
	
	draw = function(self)
		local hyke = entities.find("hyke")
		if not hyke then print("Nohyke") return end
		
		local healthRatio = (hyke.health / self.healthMax)
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", self.x, self.y, self.width*healthRatio, self.height)
		
		local foodRatio = (hyke.food / self.foodMax)
		if foodRatio <= 1 then
			love.graphics.setColor(0, 1, 0)
			love.graphics.rectangle("fill", self.x, self.y+self.height+self.spacing, self.width*foodRatio, self.height)
		end
		
		local coldRatio = (hyke.notCold / self.notColdMax)
		if coldRatio <= 1 then
			love.graphics.setColor(coldRatio, 0, 1-coldRatio)
			love.graphics.rectangle("fill", self.x, self.y+2*(self.height+self.spacing), self.width*coldRatio, self.height)
		end
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
		if foodRatio <= 1 then
			love.graphics.rectangle("line", self.x, self.y+self.height+self.spacing, self.width, self.height)
		end
		if coldRatio <= 1 then
			love.graphics.rectangle("line", self.x, self.y+2*(self.height+self.spacing), self.width, self.height)
		end
	end
}
