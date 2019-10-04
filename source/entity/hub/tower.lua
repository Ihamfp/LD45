local scene = require("ubiquitousse").scene

local entities = require("entities")

local Interactable = require("entity.interactable")

return Interactable {
	__name = "tower",
	
	x=662, y=211,
	width=48, height=206,
	
	interact = function(self)
		scene.switch("start")
	end
}