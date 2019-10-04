local Interactable = require("entity.interactable")
local Shockwave = require("entity.shockwave")
local Image = require("entity.image")
local util = require("util")
local scene = require("ubiquitousse.scene")
local input = require("ubiquitousse.input")

local ding = love.audio.newSource("asset/audio/miracleunlocked.wav", "static")
local ouch = love.audio.newSource("asset/audio/ouch.wav", "static")
local woup = love.audio.newSource("asset/audio/woup.wav", "static")

return Image {
	__name = "qte",

	sx = 3, sy = 3,

	perfect = 0,
	timer = 0,
	countdown = 0,

	new = function(self, hyke, image, key, options, callback)
		Image.new(self, hyke.x-5, hyke.y -64*2, image, options)
		self.input = key
		self.callback = callback
		woup:play()

		if self.timer then
			self.countdown = self.timer
			self.runner = scene.current.time.tween(self.timer, self, { countdown = 0 }, "linear")
				:onEnd(function()
					if not self.ok and self.remove ~= true then
						ouch:play()
						self.fail()
						self:remove()
					end
				end)
		end
	end,

	update = function(self, dt)
		if self.input:pressed() and self.remove ~= true then
			self.ok = true
			ding:play()
			scene.current.time.run(function()
				self.callback()
			end):after(math.max(0, self.perfect-(self.timer-self.countdown)))
			self.runner:stop()
			self:remove()
		end
	end,

	draw = function(self)
		if self.timer then
			love.graphics.setLineWidth(5)
			love.graphics.setColor(20, 200, 20, 255)
			love.graphics.arc("fill", "pie", self.x+32*3/2, self.y+32*3/2, 16*3+15, math.pi/2, math.pi/2+2*math.pi * (self.countdown/self.timer))
			love.graphics.setLineWidth(1)
		end

		Image.draw(self)
	end
}
