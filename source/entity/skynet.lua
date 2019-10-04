local Jumpable = require("entity.jumpable")
local scene = require("ubiquitousse").scene

return Jumpable {
	__name = "skynet",

	stepDuration = 1200,
	grid = 32,
	jumpDuration = 100,
	jumpZoom = 1.3,

	new = function(self, x, y, options, lp, human)
		Jumpable.new(self, x, y, options)

		self.nextStep = scene.current.time:get() + self.stepDuration
	end,

	update = function(self, dt)
		Jumpable.update(self, dt)

		if scene.current.time:get() >= self.nextStep then
			if not self.noStep then self:onStep() end
			self.nextStep = scene.current.time:get() + self.stepDuration
		end
	end,

	onStep = function(self)
	end,

	check = function(self, dir)
		local x, y = self.x, self.y
		if dir == "up" then
			y = self.y - self.grid
		elseif dir == "down" then
			y = self.y + self.grid
		elseif dir == "right" then
			x = self.x + self.grid
		elseif dir == "left" then
			x = self.x - self.grid
		end

		local _, _, cols = self.world:check(self, x, y, self.filter)

		for _, o in ipairs(cols) do
			if o.other.properties then
				return true
			end
		end
		return false
	end,

	go = function(self, dir)
		local x, y = self.x, self.y
		if dir == "up" then
			y = self.y - self.grid
		elseif dir == "down" then
			y = self.y + self.grid
		elseif dir == "right" then
			x = self.x + self.grid
		elseif dir == "left" then
			x = self.x - self.grid
		end

		local oY, oX = self.oy, self.ox
		scene.current.time.tween(self.jumpDuration, self, {
			x = x,
			y = y,

			sx = self.jumpZoom,
			sy = self.jumpZoom,
			ox = oX - (self.width - self.width*1.5)/2,
			oy = oY + 30
		}, "outCubic")
		:onUpdate(function()
			self:updateSize()
		end)
		:chain(self.jumpDuration, self, {
			sx = 1,
			sy = 1,
			ox = oX,
			oy = oY
		}, "inQuad")
	end,

	goTo = function(self, x, y, duration, zoom)
		local oY, oX = self.oy, self.ox
		scene.current.time.tween(duration or self.jumpDuration, self, {
			x = x,
			y = y,

			sx = zoom or self.jumpZoom,
			sy = zoom or self.jumpZoom,
			ox = oX - (self.width - self.width*1.5)/2,
			oy = oY + 30
		}, "outCubic")
		:onUpdate(function()
			self:updateSize()
		end)
		:chain(duration or self.jumpDuration, self, {
			sx = 1,
			sy = 1,
			ox = oX,
			oy = oY
		}, "inQuad")
	end
}
