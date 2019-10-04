local SolidSprite = require("entity.solidsprite")
local anim8 = require("anim8")
local entities = require("entities")

local idleImg = love.graphics.newImage("asset/sprite/traine_de_beurre_fort.png") --31x64
local idleImg2 = love.graphics.newImage("asset/sprite/traine_de_beurre_fort2.png") --64x31

return SolidSprite {
	__name = "butter",

	soft = true,

	width = 16, height = 16,
	sx = 1, sy = 1,

	behind = "hyke",

	new = function(self, x, y, options)
		SolidSprite.new(self, x, y, options)

		-- idle
		local idleg = anim8.newGrid(31, 64, idleImg:getWidth(), idleImg:getHeight())
		local idleg2 = anim8.newGrid(64, 31, idleImg2:getWidth(), idleImg2:getHeight())
		self.animation.up = anim8.newAnimation(idleg(1,1), { 1 })
		self.image.up = idleImg
		self.animation.down = anim8.newAnimation(idleg(1,1), { 1 })
		self.image.down = idleImg
		self.animation.right = anim8.newAnimation(idleg2(1,1), { 1 })
		self.image.right = idleImg2
		self.animation.left = anim8.newAnimation(idleg2(1,1), { 1 })
		self.image.left = idleImg2

		self:set("up")
	end,

	update = function(self, dt)
		SolidSprite.update(self, dt)
		local laser = entities.find("laser")
		if laser then
			if self.currentAnimation == "right" or self.currentAnimation == "left" then
				if self.y+self.height <= laser.y+laser.height and self.y+self.height >= laser.y then
					self.remove = true
					self.noCollision = true
					self.ignoreButter = true
				end
			else
				if self.y+self.height <= laser.y+laser.height and self.y >= laser.y then
					self.remove = true
					self.noCollision = true
					self.ignoreButter = true
				elseif self.y <= laser.y+laser.height and self.y+self.height >= laser.y then
					self:set("up")
					local oY = self.y
					self.y = laser.y+laser.height
					self.height = math.max(self.height -(self.y - oY), 0)
				end
			end
		end
		local supertheme = entities.find("superthemerect")
		if supertheme then
			self.remove = true
			self.noCollision = true
			self.ignoreButter = true
		end
	end,

	draw = function(self, ...)
		if self.currentAnimation == "down" then
			self.ox = -(self.width-31)/2

			love.graphics.setScissor(self.x+entities.dxV, self.y+entities.dyV, self.width, self.height)
			local oY = self.y
			for y=0, self.height, 64 do
				self.y = oY+y
				SolidSprite.draw(self, ...)
			end
			self.y = oY
			love.graphics.setScissor()
		elseif self.currentAnimation == "up" then
			self.ox = -(self.width-31)/2

			love.graphics.setScissor(self.x+entities.dxV, self.y+entities.dyV, self.width, self.height)
			local oY = self.y
			for y=self.height, -64, -64 do
				self.y = oY+y
				SolidSprite.draw(self, ...)
			end
			self.y = oY
			love.graphics.setScissor()
		elseif self.currentAnimation == "right" then
			self.oy = -(self.height-31)/2

			love.graphics.setScissor(self.x+entities.dxV, self.y+entities.dyV, self.width, self.height)
			local oX = self.x
			for x=0, self.width, 64 do
				self.x = oX+x
				SolidSprite.draw(self, ...)
			end
			self.x = oX
			love.graphics.setScissor()
		elseif self.currentAnimation == "left" then
			self.oy = -(self.height-31)/2

			love.graphics.setScissor(self.x+entities.dxV, self.y+entities.dyV, self.width, self.height)
			local oX = self.x
			for x=self.width, -64, -64 do
				self.x = oX+x
				SolidSprite.draw(self, ...)
			end
			self.x = oX
			love.graphics.setScissor()
		end
	end
}
