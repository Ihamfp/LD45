-- bcuz constructor inheritance

local Solid = require("entity.solid")
local entities = require("entities")

local font = font.PerfectDOS[54]

local themes = {
	"Night is coming",
	"Decay",
	"Safe in the dark",
	"Fragile",
	"You are the final boss",
	"Evolve",
	"Light is key",
	"Dying planet",
	"It’s spreading",
	"3 rules",
	"One enemy only",
	"One minute",
	"You control the environment, not player",
	"OwO",
	"Giant robots",
	"Symmetry",
	"Power Outage",
	"Answer the Ultimate Question of Life",
	"Cartography",
	"Indirect interaction",
	"Guardian",
	"Construction/destruction (sheep)",
	"Preparation - Set it up, let it go",
	"Infection",
	"Random",
	"Light and darkness",
	"Growth",
	"Swarms",
	"Moon/anti-text",
	"Build the level  you play",
	"Chain reaction",
	"Weird/unexpected/surprise",
	"Minimalist",
	"The tower",
	"Roads",
	"Advancing wall of doom",
	"Caverns",
	"Exploration",
	"Islands",
	"Enemies as weapons",
	"Discovery",
	"It’s dangerous to go alone! Take this!",
	"Escape",
	"Alone (kitten challenge)",
	"Tiny world",
	"Evolution",
	"You are the villain (goat)",
	"Minimalism (potato)",
	"10 seconds",
	"You only get one",
	"Beneath the surface",
	"Connected Worlds",
	"Entire Game on One Screen",
	"An Unconventional Weapon",
	"You are the Monster",
	"Growing/two button controls",
	"Shapeshift",
	"Ancient Technology",
	"One Room",
	"A Small World",
	"Running out of Power",
	"The more you have, the worse it is",
	"Combine two incompatible genres",
}

return Solid {
	__name = "solidsprite",

	direction = "down",
	theme = "undefined",

	speed = 500,
	damage = 2,
	pieces = {1,2},
	lp = 1,

	ox = 0, oy = 0,
	sx = 1, sy = 1,

	jumpable = true,

	behind = "hyke",

	-- Methods
	new = function(self, x, y, direction, options)
		self.x, self.y = x, y
		self.direction = direction
		self.theme = themes[math.random(1, #themes)]

		if self.direction == "down" then
			self.r = -math.pi/2
			self.width = font:getHeight() -26
			self.height = font:getWidth(self.theme) -10
			self.y = self.y - self.height
			self.ox = -13
			self.oy = self.height+5
		elseif self.direction == "right" then
			self.r = math.pi
			self.sy = -1
			self.width = font:getWidth(self.theme) -10
			self.height = font:getHeight() -26
			self.x = self.x - self.width
			self.ox = 5 + self.width
			self.oy = -13
		elseif self.direction == "left" then
			self.r = 0
			self.width = font:getWidth(self.theme) -10
			self.height = font:getHeight() -26
			self.x = self.x
			self.ox = -5
			self.oy = -13
		end

		Solid.new(self)
	end,

	update = function(self, dt)
		Solid.update(self, dt)
		local hyke = entities.find("hyke")
		if not hyke.freeze then
			if self.direction == "down" then
				self.y = self.y + self.speed *dt
			elseif self.direction == "right" then
				self.x = self.x + self.speed *dt
			elseif self.direction == "left" then
				self.x = self.x - self.speed *dt
			end
			self:updateSize()
		end

		if self.x < -5000 or self.x > 5000 or self.y > 5000 or self.y < -5000 then self.remove = true end
	end,

	draw = function(self)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(font)
		love.graphics.print(self.theme, self.x+self.ox, self.y+self.oy, self.r, self.sx, self.sy)

		-- love.graphics.setColor(1, 0, 0, 0.3)
		-- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end
}
