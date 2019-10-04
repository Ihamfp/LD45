local Sprite = require("entity.sprite")
local anim8 = require("anim8")

return Sprite {
	__name = "image",

	new = function(self, x, y, image, options)
		Sprite.new(self, x, y, options)

		if type(image) == "string" then
			self.image.image = love.graphics.newImage("asset/sprite/"..image)
		else
			self.image.image = image
		end
		local g = anim8.newGrid(self.image.image:getWidth(), self.image.image:getHeight(), self.image.image:getWidth(), self.image.image:getHeight())
		self.animation.image = anim8.newAnimation(g(1,1), 100)

		self:set("image")
	end
}
