local scene = require("ubiquitousse").scene

local entities = require("entities")

local Interactable = require("entity.interactable")

return Interactable {
	__name = "levelSelect",

	level = "start",
	x=0, y=0,
	width=0, height=0,

	new = function(self, x, y, w, h, level)
		Interactable.new(self)
		self.x = x
		self.y = y
		self.width = w
		self.height = h
		self.level = level
	end,

	interact = function(self)
		scene.push(self.level)
	end
}
