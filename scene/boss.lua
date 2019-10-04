local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

local Map = require("entity.map")
-- local Power = require("entity.power")
local BgParalax = require("entity.bgparalax")

local start = scene.new("boss")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}
start.score = {
	maxSpeed = 0,
	maxSpeedDuration = 0,
	thingsKilled = 0,
	maxTier = 1,
	time = 0,
	thingsGrazed = 0
}

function start:enter(power)
	love.graphics.setBackgroundColor(0, 0, 0, 1)

	-- local bg = BgParalax:new("bg"..power.unlockIn..".png")
	local map = Map:new("asset/map/boss.lua")

	start.zik = love.audio.newSource("asset/audio/Face_the_Genie_of_the_Forgotten_Themes_-_slow.ogg", "static")
	 start.zik:setLooping(true)
	 start.zik:play()
	function start:exit()
		 start.zik:stop()
	end
	function start:suspend()
		 start.zik:stop()
	end
	function start:resume()
		entities.set(start)
		 start.zik:play()
	end

	-- kept between scenes
	-- local spacebar = require("entity.hud.spacebar"):new()
	-- local spacestack = require("entity.hud.spacestack"):new()
	-- local inventory = require("entity.hud.inventory"):new()

	--local achievement = require("entity.hud.achievement"):new("Bad Umpish")

	local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
		hud = true,
		color = {0,0,0,1}
	}, "inCubic")
	start.time.tween(1500, rect.color, {[4]=0})
end

return start
