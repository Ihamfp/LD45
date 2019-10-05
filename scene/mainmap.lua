local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

--local Map = require("entity.map")
local BgParalax = require("entity.bgparalax")
local ScrollBG = require("entity.scrollbackground")

local start = scene.new("main")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}

function start:enter()
	love.graphics.setBackgroundColor(0, 0, 0, 1)

	--[[start.zik = love.audio.newSource("asset/audio/Face_the_Genie_of_the_Forgotten_Themes_-_slow.ogg", "static")
	start.zik:setLooping(true)
	start.zik:play()]]
	function start:exit()
		 --start.zik:stop()
	end
	function start:suspend()
		 --start.zik:stop()
	end
	function start:resume()
		entities.set(start)
		print("resumed")
		--start.zik:play()
	end
	
	local bgmap = ScrollBG:new("mapbg.png")
	bgmap.x = -320
	bgmap.y = -180
	bgmap.visible = true
end

return start
