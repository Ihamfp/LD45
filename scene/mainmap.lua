local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

--local Map = require("entity.map")
local BgParalax = require("entity.bgparalax")
local ScrollBG = require("entity.scrollworld")

local Hyke = require("entity.hyke")
local bars = require("entity.hud.bars")
local armor = require("entity.armor")

local Goodhealth = require("entity.goodhealth")
local Randomsources = require("entity.randomsources")
local Potoffire = require("entity.potoffire")
local Talkingpotato = require("entity.talkingpotato")

local dialog = require("entity.hud.dialog")

local start = scene.new("main")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}

function start:enter()
	love.graphics.setBackgroundColor(0, 0, 0, 1)

  local goodhealth = Goodhealth:new({"asset/audio/1_CorrectHealth.ogg"})
  local randomsource1 = Randomsources:new({"asset/audio/2_RandomLayer1.ogg"})
  local randomsource2 = Randomsources:new({"asset/audio/3_RandomLayer2.ogg"})
  local potoffire = Potoffire:new({"asset/audio/6_PotOfFire.ogg",
                     "asset/audio/5_SufferingPotato.ogg"},960,540)
  local talkingpotato = Talkingpotato:new({"asset/audio/4_PotatoDialogue.ogg"})
  
  local tracks = {goodhealth,randomsource1,randomsource2,potoffire,talkingpotato}

	--[[start.zik = love.audio.newSource("asset/audio/Face_the_Genie_of_the_Forgotten_Themes_-_slow.ogg", "static")
	start.zik:setLooping(true)
	start.zik:play()]]
	
	-- Temporairement parce que faut tester la zik
  for i=1, #tracks do
   tracks[i]:start()
  end
	
	function start:exit()
	  for i=1, #tracks do
	   tracks[i]:trueStop()
	  end
		 --start.zik:stop()
  end
	function start:suspend()
	  for i=1, #tracks do
     tracks[i]:stop()
    end
		 --start.zik:stop()
	end
	function start:resume()
		entities.set(start)
		for i=1, tracks do
     tracks[i]:start()
    end
		--start.zik:play()
	end
	
	local bgmap = ScrollBG:new("mapbg.png")
	--bgmap.x = -320
	--bgmap.y = -180
	
	local hyke = Hyke:new(640, 360)
	local bars = bars:new()
	
	for i=1, 3 do
		local armorPart = armor:new(math.random(0, 1920), math.random(0, 1080), i)
	end
	
	local testDialog = dialog:new({"POT OF FIRE TASTY AND GOOD"}, font.Potato[54])
	
	bgmap.visible = true
end

return start
