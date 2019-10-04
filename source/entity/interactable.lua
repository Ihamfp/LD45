local Entity = require("entity")
local util = require("util")

return Entity {
	__name = "interactable",

	x = 0, y = 0,
	width = 0, height = 0,

	interact = function(self)
		--return "Pour être honnête, je n'ai aucune idée de comment utiliser ce truc. (PLACEHOLDER, si vous lisez ça le dév est une ouiche)"
	end,

	examine = function(self)
		--return "Alors oui... hm... hm... oui. (PLACEHOLDER, si vous lisez ça le dév est une ouiche)"
	end,

	collide = function(self, x, y, w, h)
		if type(x) == "table" then
			x, y, w, h = x.x, x.y, x.width, x.height
		end
		return util.aabb(x, y, w, h, self.x, self.y, self.width, self.height)
	end
}
