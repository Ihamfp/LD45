local Sprite = require("entity.sprite")

local entities = require("entities")

local enter = require("input").enter

return Sprite {
	__name = "bars",
	hud = true,
	
	x = 160,
	dispy = 576,
	y = 720, -- hiden at the bottom of the screen
	width = 960,
	height = 128,
	spacing = 5,
	
	new = function(self, text, font, options)
		Sprite.new(self, self.x, self.y, options)
		self.text = text or {"You shouldn't be able to see this,", "please report to game authors"}
		self.textLine = 1
		self.font = font
	end,
	
	draw = function(self)
		local hyke = entities.find("hyke")
		if not hyke then return end
		
		love.graphics.setColor(1,1,1, 0.7)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(0,0,0, 1)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
		if self.font then
			love.graphics.setFont(self.font)
		end
		love.graphics.printf(self.text[math.min(self.textLine, #self.text)], self.x+self.spacing, self.y+self.spacing, self.width-self.spacing/2)
		love.graphics.setFont(font.Stanberry[22])
		love.graphics.printf("press <Enter> to continue", self.x+self.width-self.spacing-260, self.y+self.height-self.spacing-22, 260)
	end,
	
	update = function(self, dt)
		if self.textLine <= #self.text then
			self.y = math.max(self.y - dt*400, self.dispy)
		else
			self.y = math.min(self.y + dt*400, 720)
			if self.y >= 720 then
				self.remove = true
			end
		end
		
		if enter:pressed() then
			self.textLine = self.textLine+1
		end
	end
}
