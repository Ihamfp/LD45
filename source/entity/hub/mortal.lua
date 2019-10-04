local Entity = require("entity.entity")
local scene = require("ubiquitousse.scene")

return Entity {
	__name = "hyke",

	belive = false,
	population = {},
	destination = "",
	x = 0, y = 0,
	above = "background",

	new = function(self, population, destination, options)
		Entity.new(self, options)

		self.population = population
		self.x, self.y = population.city[1] + population.city[3]*math.random(), population.city[2] + population.city[4]*math.random()
		self.destination = destination
		self.believe = population.city.population == population.city.believers

		population.city.population = population.city.population -1
		population[destination].population = population[destination].population +1
		if self.believe then
			population[destination].believers = population[destination].believers +1
			population.city.believers = population.city.believers -1
		end

		table.insert(population[destination].mortals, self)

		scene.current.time.tween(3000, self, {
			x = population[destination][1] + population[destination][3]*math.random(),
			y = population[destination][2] + population[destination][4]*math.random()
		})

		self.back = scene.current.time.run(function()
			if self.remove ~= true then
				population.city.population = population.city.population +1
				population[destination].population = population[destination].population -1
				if self.believe then
					population[destination].believers = population[destination].believers -1
				end
			end

			scene.current.time.tween(3000, self, {
				x = population.city[1] + population.city[3]*math.random(),
				y = population.city[2] + population.city[4]*math.random()
			}):onEnd(function()
				if self.remove ~= true then self:remove() end
			end)
		end):after(math.min(5000 + population[destination].popularity*10, 60000))
	end,

	kill = function(self)
		self:remove()
	end,

	convert = function(self)
		self.believe = true
	end,

	unconvert = function(self)
		self.believe = false
	end,

	goBack = function(self)
		self.back:stop()
		if self.remove ~= true then
			local population = self.population
			local destination = self.destination
			population.city.population = population.city.population +1
			population[destination].population = population[destination].population -1
			if self.believe then
				population[destination].believers = population[destination].believers -1
				population.city.believers = population.city.believers +1
			end
			self:remove()
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.circle("line", self.x, self.y, 3)
		if self.believe then
			love.graphics.setColor(20, 200, 20, 255)
		else
			love.graphics.setColor(230, 50, 30, 255)
		end
		love.graphics.circle("fill", self.x, self.y, 2)
	end
}
