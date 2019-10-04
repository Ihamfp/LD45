local Entity = require("entity")

local fontCache = {}

return Entity {
	__name = "text",

	-- Options
	font = nil,
	text = "",
	x = 0, y = 0,

	limit = nil,
	alignX = "left", alignY = "top",
	r = 0,
	sx = 1, sy = 1,
	ox = 0, oy = 0,
	kx = 0, ky = 0,

	color = { 255, 255, 255, 255 },
	background = nil,
	shadowColor = nil,

	-- Methods
	new = function(self, font, text, x, y, options)
		-- if not fontCache[font] then fontCache[font] = {} end
		-- if not fontCache[font][size] then fontCache[font][size] = love.graphics.newFont("asset/font/"..font, size) end

		self.font = font--ontCache[font][size]
		self.text = text
		self.x, self.y = x, y

		self.color = {1,1,1,1}

		Entity.new(self, options)

		if self.limit then
			local _, wrapped = self.font:getWrap(self.text, self.limit)
			self.height = #wrapped * self.font:getHeight()* self.sy
		end
	end,

	draw = function(self)
		love.graphics.setFont(self.font)

		if self.limit then
			local _, wrapped = self.font:getWrap(self.text, self.limit)

			local y
			if self.alignY == "top" then
				y = self.y
			elseif self.alignY == "center" then
				y = self.y - #wrapped * self.font:getHeight() * self.sy /2
			elseif self.alignY == "bottom" then
				y = self.y - #wrapped * self.font:getHeight() * self.sy
			end


			if self.shadowColor then
				love.graphics.setColor(self.shadowColor)
				love.graphics.printf(self.text, self.x-1, y, self.limit, self.alignX, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.printf(self.text, self.x+1, y, self.limit, self.alignX, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.printf(self.text, self.x, y-1, self.limit, self.alignX, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.printf(self.text, self.x, y+1, self.limit, self.alignX, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
			end
			love.graphics.setColor(self.color)
			love.graphics.printf(self.text, self.x, y, self.limit, self.alignX, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
		else
			local x
			if self.alignX == "left" then
				x = self.x
			elseif self.alignX == "center" then
				x = self.x - self.font:getWidth(self.text) * self.sx /2
			elseif self.alignX == "right" then
				x = self.x - self.font:getWidth(self.text) * self.sx
			end

			x = math.max(0, x)

			local y
			if self.alignY == "top" then
				y = self.y
			elseif self.alignY == "center" then
				y = self.y - self.font:getHeight() * self.sy /2
			elseif self.alignY == "bottom" then
				y = self.y - self.font:getHeight() * self.sy
			end

			if self.shadowColor then
				love.graphics.setColor(self.shadowColor)
				love.graphics.print(self.text, x-1, y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.print(self.text, x+1, y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.print(self.text, x, y-1, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
				love.graphics.print(self.text, x, y+1, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
			end
			love.graphics.setColor(self.color)
			love.graphics.print(self.text, x, y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
		end
	end
}
