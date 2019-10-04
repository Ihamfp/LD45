local Sprite = require("entity.sprite")
local anim8 = require("anim8")

return Sprite {
	__name = "background",

	new = function(self, image, options)
		Sprite.new(self, 0, 0, options)

		self.color = { 1.0, 1.0, 1.0, 1.0 }

		self.image.background = love.graphics.newImage("asset/sprite/"..image)
		local g = anim8.newGrid(love.graphics.getWidth(), love.graphics.getHeight(), self.image.background:getWidth(), self.image.background:getHeight())
		local nFrames = math.floor(self.image.background:getWidth() / love.graphics.getWidth())
		self.animation.background = anim8.newAnimation(g("1-"..nFrames,1), 0.1)

		self:set("background")
	end
}
