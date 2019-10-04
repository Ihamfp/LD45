local Sprite = require("entity.sprite")

local achimg = love.graphics.newImage("asset/sprite/achievement.png")

local width = 256
local height = 65

local firstImg = love.graphics.newImage("asset/sprite/achievements/first.png")
local firstAchievement = true -- set to true on first achievement

return Sprite {
	hud = true,

	x = love.graphics.getWidth() - width,
	y = -height,

	yoffset = 0,
	timer = 0,

	popTime = 3,

	text = "<undefined>",
	pic = nil,

	new = function(self, text, image, options) -- pix are 56x56 px
		Sprite.new(self, self.x, self.y, options)
		self.text = text or "<undefined>"
		self.pic = image
		self.timer = 0
	end,

	update = function(self, dt)
		self.timer = self.timer + dt

		if self.timer < 0.5 then
			self.yoffset = (self.timer/0.5)*height
		elseif self.timer < (self.popTime-0.5) then
			self.yoffset = height
		elseif self.timer < self.popTime then
			self.yoffset = ((self.popTime-self.timer)/0.5)*height
		else
			if firstAchievement then
				firstAchievement = false
				self.text = "First achievement !"
				self.pic = firstImg
				self.timer = 0
			else
				self.remove = true
			end
		end
	end,

	draw = function(self)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(achimg, self.x, self.y + self.yoffset)
		love.graphics.setFont(font.LemonMilk[14])
		love.graphics.printf(self.text, self.x + 63, self.y + self.yoffset + 12, width - 63)
		if self.pic then
			love.graphics.draw(self.pic, self.x+4, self.y + self.yoffset + 4)
		end
		love.graphics.setColor(0.7, 0.7, 0.7, 1)
		love.graphics.setFont(font.LemonMilk[10])
		love.graphics.print("Achievement unlocked !", self.x + 63, self.y + self.yoffset + 2)
	end
}
