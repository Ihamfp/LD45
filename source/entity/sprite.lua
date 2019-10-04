local Entity = require("entity")
local util = require("util")

return Entity {
	__name = "sprite",

	-- Options
	currentAnimation = "",
	animation = {},
	image = {},

	x = 0, y = 0,
	r = 0,
	sx = 1, sy = 1,
	ox = 0, oy = 0,
	kx = 0, ky = 0,

	color = { 1.0, 1.0, 1.0, 1.0 },

	animSpeedUp = 1,

	-- Methods
	new = function(self, x, y, options)
		self.x, self.y = x, y
		self.animation = {}
		self.image = {}

		self.color = { 1.0, 1.0, 1.0, 1.0 }

		Entity.new(self, options)
	end,

	--- Change animation.
	set = function(self, animation)
		if self.currentAnimation ~= animation then
			self.currentAnimation = animation
			self.animation[self.currentAnimation]:gotoFrame(1)
		end
	end,

	--- Returns distance between entities.
	distance = function(self, entity)
		return util.distance(self.x + (self.width or 0)/2, self.y + (self.height or 0)/2, entity.x + (entity.width or 0)/2, entity.y + (entity.height or 0)/2)
	end,

	update = function(self, dt)
		if self.animation[self.currentAnimation] then self.animation[self.currentAnimation]:update(dt * self.animSpeedUp) end
	end,

	draw = function(self)
		if self.animation[self.currentAnimation] then
			if self.effect then
				self.effect(function()
					love.graphics.setColor(self.color)
					self.animation[self.currentAnimation]:draw(self.image[self.currentAnimation], math.floor(self.x), math.floor(self.y), self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				end)
			else
				love.graphics.setColor(self.color)
				self.animation[self.currentAnimation]:draw(self.image[self.currentAnimation], math.floor(self.x), math.floor(self.y), self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
			end
		end
	end
}
