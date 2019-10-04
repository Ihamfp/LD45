local Entity = require("entity")

local scene = require("ubiquitousse.scene")
local entities = require("entities")

return Entity {
	__name = "shockwave",

	x = 0, y = 0,
	radius = 50, width = 10,
	color = { 1.0, 1.0, 1.0, 1.0 },

	duration = 0,
	finalRadius = 0,

	shake = 0,
	shakeDuration = 0,

	new = function(self, x, y, options)
		Entity.new(self, options)

		self.x, self.y = x, y
		self.color = { unpack(self.color) }

		if self.duration > 0 then
			scene.current.time.tween(self.duration, self, {
				radius = self.finalRadius
			}, "outExpo"):onEnd(function()
				self:remove()
			end)
			scene.current.time.tween(self.duration/2, self.color, { [4] = 0 }, "outExpo"):after(self.duration/2)
		end

		if self.shake > 0 then
			entities.shake = entities.shake + self.shake
			scene.current.time.run(function()
				entities.shake = entities.shake - self.shake
			end):after(self.shakeDuration)
		end
	end,

	draw = function(self)
		local c = { unpack(self.color) }
		for i=self.radius-self.width, self.radius, 1 do
			c[4] = -(self.radius-self.width -i) / self.width * self.color[4]
			love.graphics.setColor(c)
			love.graphics.circle("line", self.x, self.y, i)
		end
	end
}
