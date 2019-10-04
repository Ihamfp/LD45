local Interactable = require("entity.interactable")
local Shockwave = require("entity.shockwave")
local Image = require("entity.image")
local util = require("util")

return Interactable(Image) {
	__name = "powerplat",

	width = 32, height = 32,

	interact = function(self)
		if self.onPower ~= true then
			self:onPower()
			self.onPower = true
		end
	end,

	examine = function(self)
	end,

	collide = function(self, x, y, w, h)
		if type(x) == "table" then
			x, y, w, h = x.x, x.y, x.width, x.height
		end
		return util.aabb(x, y, w, h, self.x, self.y, 32, 32)
	end,
}
