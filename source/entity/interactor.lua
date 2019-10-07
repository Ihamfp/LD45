local entities = require("entities")
local Solid = require("entity.solid")
local interact = require("input").interact

return Solid {
	x = 0,
	y = 0,
	width=64,
	height=64,
	noCollision = true,
	target = false,
	
	new = function(self,options)
		Solid.new(self,options)
		self:move(10000, 10000)
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
			self.x = self.x - (self.width-hyke.width)/2
		elseif hyke.direction == "down" then
			self.y = self.y + hyke.height/2 + 4
			self.x = self.x - (self.width-hyke.width)/2
		elseif hyke.direction == "left" then
			self.x = self.x - hyke.width/2 - self.width - 4
			self.y = self.y - (self.height-hyke.height)/2
		elseif hyke.direction == "right" then
			self.x = self.x + hyke.width/2 + 4
			self.y = self.y - (self.height-hyke.height)/2
		end
		
		_, _, self.collisions = self.world:check(self, self.x, self.y)
		self.world:update(self, self.x, self.y)
		
		local otherEntity = false
		for _,c in ipairs(self.collisions) do
			local o = c.other
			
			if o.__name ~= "hyke" and o ~= self then
				print(o.__name)
				otherEntity = o
			end
		end
		if otherEntity then
			self.target = otherEntity
		else
			self.target = false
		end
		
		if self.target and self.target.interact and input.interact:pressed() then
			self.target:interact()
		end
	end,
	
	draw = function(self, dx, dy, ...)
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("fill", self.x+dx, self.y+dy, self.width, self.height)
	end
}
