local Entity = require("entity")
local sti = require("sti")
local bump = require("bump")
local Hyke = require("entity.hyke")
local Gen = require("entity.gen")
local Carton = require("entity.carton")
local Vendeur = require("entity.vendeur")
local Mamie = require("entity.mamie")
local Zombie = require("entity.zombie")
local Warp = require("entity.warp")
local Space = require("entity.space")
local Boss = require("entity.boss")
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
			elseif object.name == "Gen" then
				Gen:new(object.x-Gen.width/2, object.y-Gen.height/2, {
					map = self.map
				})
			elseif object.name == "Carton" then
				Carton:new(object.x-Carton.width/2, object.y-Carton.height/2, {
					map = self.map
				})
			elseif object.name == "Space" then
				Space:new(object.x-Space.width/2, object.y-Space.height/2, {
					map = self.map,
					tier = tonumber(object.properties.tier) or 1
				})
			elseif object.name == "Vendeur" then
				Vendeur:new(object.x-Vendeur.width/2, object.y-Vendeur.height/2, {
					map = self.map,
					direction = (object.properties.direction or object.properties.facing or "down"):lower()
				})
			elseif object.name == "Momie" then
				Mamie:new(object.x-Mamie.width/2, object.y-Mamie.height/2, {
					map = self.map,
					direction = (object.properties.direction or object.properties.facing or "down"):lower()
				})
			elseif object.name == "Zombie" then
				Zombie:new(object.x-Zombie.width/2, object.y-Zombie.height/2, {
					map = self.map,
					direction = (object.properties.direction or object.properties.facing or "down"):lower()
				})
			elseif object.name == "Boss" then
				Boss:new(object.x-Boss.width/2, object.y-Boss.height/2, {
					map = self.map
				})
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
