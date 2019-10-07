local entities = require("entities")
local Solid = require("entity.solid")

return Solid {
	x = 0,
	y = 0,
	width=32,
	height=32,
	noCollision = true,
	
	new = function(self,options)
		Solid.new(self,options)
	end,
	
	update = function(self,dt)
		Solid.update(self, dt) -- now we can check collisions
		
		local hyke = entities.find("hyke")
		if not hyke then return end
		
		local oldx, oldy = self.x, self.y
		
		self.x = hyke.x
		self.y = hyke.y
		if hyke.direction == "up" then
			self.y = self.y - hyke.height/2 - self.height - 4
		elseif hyke.direction == "down" then
			self.y = self.y + hyke.height/2 + 4
		elseif hyke.direction == "left" then
			self.x = self.x - hyke.width/2 - self.width - 4
		elseif hyke.direction == "right" then
			self.x = self.x + hyke.width/2 + 4
		end
		
		self:move(self.x-oldx, self.y-oldy)
		
		for _,c in ipairs(self.collisions) do
			local o = c.other
			
			if o.__name ~= "hyke" then
				print(o.__name)
			end
		end
	end,
	
	draw = function(self, dx, dy, ...)
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", self.x+dx, self.y+dy, self.width, self.height)
	end
}
