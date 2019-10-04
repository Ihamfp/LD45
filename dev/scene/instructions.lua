local uqt = require("ubiquitousse")
local scene = uqt.scene
local entities = require("entities")
local shine = require("shine")
local Background = require("entity.background")
local Rectangle = require("entity.rectangle")

local input = uqt.input

local start = scene.new("platlevel")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}:chain(shine.scanlines())

Background:new("instructions.png")

local rect = Rectangle:new(0, 0, 1280, 720, {
	color = {0,0,0,255}
})
start.time.tween(800, rect.color, {[4]=0})

local esc = uqt.input.button("keyboard.return")
start.update = function()
	if esc:pressed() then
		rect = Rectangle:new(0, 0, 1280, 720, {
			color = {255,255,255,0}
		})
		start.time.tween(800, rect.color, {[4]=255}):onEnd(function()
			uqt.scene.switch("hubmap")
		end)
	end
end

return start
