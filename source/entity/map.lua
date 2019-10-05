local Entity = require("entity")
local sti = require("sti")
local bump = require("bump")
local Hyke = require("entity.hyke")
local Cinema = require("entity.cinema")

return Entity {
	__name = "map",

	new = function(self, map, options)
		Entity.new(self, options)

		self.world = bump.newWorld()

		self.map = sti(map, { "bump" })
		self.map:bump_init(self.world)

		for _, object in pairs(self.map.objects) do
			if string.lower(object.name) == "start" then
				Hyke:new(object.x, object.y, {
					map = self.map
				})
				object.visible = false
			elseif object.name == "exit" then
				Warp:new({
					x = object.x, y = object.y,
					width = object.width, height = object.height,
					map = self.map,
					to = object.properties.goto
				})
			elseif object.name == "warp" then
				Warp:new({
					x = object.x, y = object.y,
					width = object.width, height = object.height,
					map = self.map,
					to = object.properties.goto,
					direct = true
				})
			elseif object.name == "cinema" then
				Cinema:new({
					x = object.x, y = object.y,
					width = object.width, height = object.height,
					map = self.map,
					to = object.properties.film
				})
			elseif object.properties.collide or object.properties.jumpable then
				self.world:add(object, object.x, object.y, object.width, object.height)
			elseif object.name ~= "" then
				print("unknown object in map "..tostring(object.name))
			end
	    end
	end,

	update = function(self, dt)
		self.map:update(dt)
	end,

	draw = function(self, dx, dy, sx, sy)
		love.graphics.setColor(1, 1, 1)
		self.map:draw(dx, dy, sx, sy)
	end
}
