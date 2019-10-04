local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

local Map = require("entity.map")
local Power = require("entity.power")
local BgParalax = require("entity.bgparalax")

local start = scene.new("platlevel")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}

function start:enter(power)
	local bg = BgParalax:new("bg"..power.unlockIn..".png")
	local map = Map:new("asset/map/"..power.unlockIn..".lua")

	power.doingThePlatform = true

	local zik = love.audio.newSource("asset/audio/"..power.unlockZik, "stream")
	zik:setLooping(true)
	zik:play()
	function start:exit()
		power.doingThePlatform = false
		zik:stop()
	end
	function start:suspend()
		zik:stop()
	end
	function start:resume()
		entities.set(start)
		zik:play()
	end

	local found = false
	for _, object in pairs(map.map.objects) do
        if object.name == power.unlockName or object.properties.name == power.unlockName then
			found = true
            Power:new(object.x, object.y, power.icon)
            break
		end
    end
	if not found then
		print("WARNING: Can't find the power object in the map!")
	end

	for i, layer in pairs(map.map.layers) do
		if layer.name == "remove if "..power.unlockName then
			map.map:bump_removeLayer(i, map.world)
			map.map:removeLayer(i)
		end
	end

	local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
		color = {255,255,255,255}
	})
	start.time.tween(800, rect.color, {[4]=0})
end

return start
