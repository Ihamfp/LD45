-- It would be waaaay better to use ECS instead of the inheritance garbage, but I didn't really had much time to adapt my code.
-- Well, at least it works ¯\_(ツ)_/¯

local class = require("classtoi")
local entities = require("entities")

local s = require("ubiquitousse.scene")

return class {
	__name = "entity",

	visible = true,

	new = function(self, options)
		if options then
			for k,v in pairs(options) do
				self[k] = v
			end
		end

		local i
		if self.behind then
			_, i = entities.find(self.behind)
		end
		if self.above then
			_, i = entities.find(self.above)
			if i then i = i+1 end
		end
		if not i then
			i = #entities.list +1
			--print("can't find entity to place relative to (in "..tostring(self)..")")
		end

		if self.aboveAll then
			table.insert(entities.aboveList, self)
		elseif self.hud then
			table.insert(entities.hud, self)
		else
			table.insert(entities.list, i, self)
		end
	end,

	remove = function(self)
		self.remove = true
	end,

	update = function(dt) end,
	draw = function() end
}
