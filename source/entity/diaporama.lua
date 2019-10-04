local Sprite = require("entity.sprite")
local anim8 = require("anim8")
local scene = require("ubiquitousse.scene")

return Sprite {
	__name = "diaporama",
	nextOpacity = 0,

	new = function(self, image, options, joker)
		Sprite.new(self, 0, 0, options)

		if type(image) == "string" then
			self.image.image = love.graphics.newImage("asset/sprite/"..image)
		else
			self.image.image = image
		end
		local g = anim8.newGrid(love.graphics.getWidth(), love.graphics.getHeight(), self.image.image:getWidth(), self.image.image:getHeight())
		self.animation.image = anim8.newAnimation(g("1-"..(self.image.image:getWidth()/love.graphics.getWidth()),1), 1)
		self.animation.imageNext = self.animation.image:clone()

		if joker then -- I CAN CODE VERY GOOD
			self.image.still = self.image.image
			self.animation.still = anim8.newAnimation(g(3,1), 0.2)
			self.image.hyke = self.image.image
			self.animation.hyke = anim8.newAnimation(g(3,1, 5,1), 0.2)
			self.image.badhyke = self.image.image
			self.animation.badhyke = anim8.newAnimation(g(3,1, 4,1), 0.2)
		end

		self:set("image")

		self.animation.image:pauseAtStart()
		self.animation.imageNext:pauseAtStart()
	end,

	change = function(self, frame)
		self.animation.imageNext:gotoFrame(frame)
		scene.current.time.tween(500, self, { nextOpacity = 255 })
			:onEnd(function()
				self.animation.image:gotoFrame(frame)
				self.nextOpacity = 0
			end)
	end,

	draw = function(self)
		Sprite.draw(self)
		love.graphics.setColor(255, 255, 255, self.nextOpacity)
		self.animation.imageNext:draw(self.image.image, self.x, self.y)
	end
}
