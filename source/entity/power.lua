local Image = require("entity.image")
local Solid = require("entity.solid")
local anim8 = require("anim8")
local Shockwave = require("entity.shockwave")
local scene = require("ubiquitousse.scene")
local Rectangle = require("entity.rectangle")
local entities = require("entities")
local util = require("util")

local unlocked = love.audio.newSource("asset/audio/miracleunlocked.wav", "static")

return Image {
	__name = "power",

	width = 32,
	height = 32,

	new = function(self, x, y, image, options)
		Image.new(self, x, y, image, options)
		Solid.new(self)
	end,

	update = function(self, dt)
		local hyke = entities.find("hyke")
		if util.aabb(self.x, self.y, self.width, self.height, hyke.x, hyke.y, hyke.width, hyke.height) and self.remove ~= true then
			self:remove()

			scene.current.time.run(function()
				Shockwave:new(self.x +16, self.y +16, {
					radius = 10, width = 200,
					duration = 1300, finalRadius = 1000,
					shake = 20, shakeDuration = 100
				})
				unlocked:play()
			end):every(150):during(1300)

			local rect = Rectangle:new(0, 0, 1280, 720, {
				color = {255,255,255,0}
			})
			scene.current.time.tween(1000, rect.color, {[4]=255}):after(600)
				:onEnd(function()
					rect.visible = false
					scene.pop()
				end)
		end
	end
}
