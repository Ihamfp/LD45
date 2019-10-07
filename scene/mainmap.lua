local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

--local Map = require("entity.map")
local BgParalax = require("entity.bgparalax")
local ScrollBG = require("entity.scrollworld")

local Solid = require("entity.solid")
local Hyke = require("entity.hyke")
local bars = require("entity.hud.bars")
local armor = require("entity.armor")
local potato = require("entity.potato")

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
                     "asset/audio/5_SufferingPotato.ogg"},968,629)
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
	
	local hyke = Hyke:new(960, 1000)
	local bars = bars:new()
	
	-- collisions
	local architecture = {
		borderL = Solid:new({x=-2, y=0, width=2, height=1080}),
		borderR = Solid:new({x=1920, y=0, width=2, height=1080}),
		borderT = Solid:new({x=0, y=-2, width=1920, height=2}),
		borderB = Solid:new({x=0, y=1080, width=1920, height=2}),
		house1 = Solid:new({x=833, y=83, width=309, height=209}),
		house2 = Solid:new({x=1331, y=330, width=309, height=209}),
		house3 = Solid:new({x=1328, y=744, width=309, height=209}),
		house4 = Solid:new({x=251, y=722, width=309, height=209}),
		house5 = Solid:new({x=289, y=297, width=309, height=209}),
		potoffire = Solid:new({x=904, y=565, width=127, height=125})
	}
	
	for i=1, 3 do
		local armorPart = armor:new(math.random(0, 1920), math.random(0, 1080), i)
	end
	
	local potatoes = {
	  potato1 = potato:new(100,200,1,"YOU COLD ? WE COLD GOOD"),
	  potato2 = potato:new(300,200,2,"SACRIFICE POTATO SOON"),
	  potato2 = potato:new(300,400,2,"POT OF FIRE GOOD !")
	
	}
	
	local testDialog = dialog:new({"POT OF FIRE TASTY AND GOOD"}, font.Potato[54])
	
	bgmap.visible = true
end

return start
