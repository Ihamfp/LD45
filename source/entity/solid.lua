local Entity = require("entity")
local util = require("util")
local entities = require("entities")
local scene = require("ubiquitousse.scene")
local event = require("ubiquitousse")

return Entity {
	__name = "solid",

	x = 0, y = 0,
	width = 0, height = 0,

	--[[filter = function(item, other)
		event.update = entities.update
		local ret = "slide"
		if other.noCollision or item.noCollision then
			return "cross"
		end
		if (other.__name == "hyke" and item.__name == "hyke1") or (other.__name == "hyke1" and item.__name == "hyke") then
			return "cross"
		end
		if other.properties then
			if other.properties.collisionType then return other.properties.collisionType end
			if other.properties.walkable == true and item.y + item.height > other.y then return "cross" end
			if other.properties.ladder == true then
				if item.y + item.height < other.y then
					ret = "slide"
				else
					ret = "cross"
				end
				if util.aabb(item.x, item.y, item.width, item.height, other.x, other.y, other.width, other.height) then
					item.onLadder = true
				end
			end
			if other.properties.collide then
				ret = "slide"
			end
			if other.properties.jumpable then
				if item.jumping then
					ret = "cross"
				else
					ret = "slide"
				end
			end
		end
		if other.soft then
			ret = "cross"
		end
		if other.jumpable then
			if item.jumping then
				ret = "cross"
			else
				ret = "slide"
			end
		end
		return ret
	end,]]

	new = function(self, options)
		Entity.new(self, options)

		local map = entities.find("map")
		if map then -- ENGAGE TILED MODE
			self.world = map.world
			self.world:add(self, self.x, self.y, self.width, self.height)
		else -- ENGAGE IMAGE BG MODE
			local scrollworld = entities.find("scrollworld")
			if scrollworld then
				print("adding "..self.__name.." to the world")
				self.world = scrollworld.world
				self.world:add(self, self.x, self.y, self.width, self.height)
			end
		end
	end,

	collide = function(self, x, y, w, h)
		if type(x) == "table" then
			x, y, w, h = x.x, x.y, x.width, x.height
		end
		return util.aabb(x, y, w, h, self.x, self.y, self.width, self.height)
	end,

	move = function(self, x, y)
		self.onLadder = false
		local nX, nY, cols = self.world:move(self, self.x + x, self.y + y, self.filter)
		if self.vy and nY ~= self.y + y then self.vy = 0 end
		if self.vx and nX ~= self.x + x then
			local collide = true
			if self.vy == 0 then
				local _, nY2 = self.world:move(self, self.x, self.y -16, self.filter)
				if nY2 == self.y -16 then
					local nX3, _ = self.world:move(self, self.x +x, self.y -16, self.filter)
					if nX3 == self.x +x then
						collide = false
					end
				end
			end
			if collide then
				self.vx = 0
			end
		end
		self.x, self.y = nX, nY
		self.collisions = cols
	end,

	updateSize = function(self)
		self.world:update(self, self.x, self.y, self.width, self.height)
	end,

	remove = function(self)
		Entity.remove(self)
		self.world:remove(self)
	end
}
