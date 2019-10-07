local Music = require("entity.music")
local entities = require("entities")

return Music {
	__name = "talkingpotato",
	sources = {},
	
	new = function(self,sources)
		Music.new(self,sources,1.0,0,0)
	end,
	
	update = function(self)
		local dialog = entities.find("dialog")
		if dialog and not self.isOn then
			self:play()
		elseif not dialog and self.isOn then
			self:stop()
		end
	end
}
