local uqt = require("ubiquitousse") -- ./gameover.can:1
local scene = uqt["scene"] -- ./gameover.can:2
local entities = require("entities") -- ./gameover.can:4
local input = require("input") -- ./gameover.can:5
local gameover = scene["new"]("platlevel") -- ./gameover.can:7
entities:reset(gameover) -- ./gameover.can:8
local spacebar = entities["find"]("spacebar") -- ./gameover.can:10
local restartLevel = "" -- ./gameover.can:12
gameover["enter"] = function(self, lastLevel) -- ./gameover.can:13
restartLevel = lastLevel -- ./gameover.can:14
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./gameover.can:15
spacebar["usage"] = spacebar["usage"] + (2) -- prevents displaying -- ./gameover.can:17
local inventory = entities["find"]("inventory") -- ./gameover.can:19
inventory["parts"] = {} -- ./gameover.can:21
end -- ./gameover.can:21
local drawStatus = 0 -- update using delays/counters/etc. -- ./gameover.can:24
local spaceimg = spacebar["tierImg"][spacebar["tier"]] -- ./gameover.can:25
local soundCrack = love["audio"]["newSource"]("asset/audio/gameover4.wav", "static") -- ./gameover.can:27
local soundPart = love["audio"]["newSource"]("asset/audio/gameover3.wav", "static") -- ./gameover.can:28
local brokenQuad = love["graphics"]["newQuad"](0, 448, 512, 64, 512, 512) -- ./gameover.can:30
local leftQuad = love["graphics"]["newQuad"](0, 448, 256, 64, 512, 512) -- ./gameover.can:31
local rightQuad = love["graphics"]["newQuad"](256, 448, 256, 64, 512, 512) -- ./gameover.can:32
local particles = love["graphics"]["newParticleSystem"](spaceimg, 1000) -- ./gameover.can:34
particles:setParticleLifetime(0.5, 1) -- ./gameover.can:35
particles:setEmissionRate(1000) -- ./gameover.can:36
particles:setEmissionArea("uniform", 128, 32) -- ./gameover.can:37
particles:setSizes(0.01, 0.01) -- ./gameover.can:38
particles:setLinearAcceleration(- 200, - 200, 200, 200) -- ./gameover.can:39
particles:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- ./gameover.can:40
gameover["draw"] = function(self) -- ./gameover.can:42
if drawStatus == 0 then -- ./gameover.can:43
love["graphics"]["setColor"](1, 1, 1, 1) -- ./gameover.can:44
love["graphics"]["draw"](spaceimg, brokenQuad, spacebar["x"], spacebar["y"]) -- ./gameover.can:45
elseif drawStatus == 1 then -- ./gameover.can:46
love["graphics"]["draw"](spaceimg, leftQuad, spacebar["x"] - 16, spacebar["y"], - 0.1) -- ./gameover.can:47
love["graphics"]["draw"](spaceimg, rightQuad, spacebar["x"] + 512 + 16, spacebar["y"], 0.1, 1, 1, 256, 0) -- ./gameover.can:48
elseif drawStatus == 3 then -- ./gameover.can:49
love["graphics"]["setColor"](1, 1, 1, 1) -- ./gameover.can:52
love["graphics"]["setFont"](font["LemonMilk"][94]) -- ./gameover.can:53
love["graphics"]["print"]("GAME OVER", (1280 - font["LemonMilk"][94]:getWidth("GAME OVER")) / 2, 273) -- TODO center -- ./gameover.can:54
love["graphics"]["setColor"](0.5, 0.5, 0.5, 1) -- ./gameover.can:55
love["graphics"]["setFont"](font["LemonMilk"][24]) -- ./gameover.can:56
love["graphics"]["print"]("Press enter to restart level", (1280 - font["LemonMilk"][24]:getWidth("Press space to restart level")) / 2, 383) -- ./gameover.can:57
love["graphics"]["print"]("Too hard? You can restart the game and collect more space bars in previous levels", (1280 - font["LemonMilk"][24]:getWidth("Too hard? You can restart the game and collect more space bars in previous levels")) / 2, 600) -- ./gameover.can:58
end -- ./gameover.can:58
if drawStatus >= 2 then -- ./gameover.can:61
love["graphics"]["draw"](particles, spacebar["x"] - 16 + 256 - 128, spacebar["y"] + 32 - 16, - 0.1) -- ./gameover.can:63
love["graphics"]["draw"](particles, spacebar["x"] + 512 + 16 + 256 - 128, spacebar["y"] + 32, 0.1, 1, 1, 256, 0) -- ./gameover.can:64
end -- ./gameover.can:64
end -- ./gameover.can:64
local timer = 0 -- ./gameover.can:69
gameover["update"] = function(self, dt) -- ./gameover.can:70
timer = timer + (dt) -- ./gameover.can:71
if timer > 1000 and drawStatus < 3 then -- ./gameover.can:72
drawStatus = drawStatus + (1) -- ./gameover.can:73
if drawStatus == 1 then -- ./gameover.can:74
soundCrack:play() -- ./gameover.can:75
elseif drawStatus == 2 then -- ./gameover.can:76
particles:start() -- ./gameover.can:77
soundPart:play() -- ./gameover.can:78
end -- ./gameover.can:78
timer = 0 -- ./gameover.can:80
end -- ./gameover.can:80
if drawStatus >= 2 then -- ./gameover.can:83
particles:update(dt / 1000) -- ./gameover.can:84
end -- ./gameover.can:84
if drawStatus == 3 then -- ./gameover.can:87
particles:setEmissionRate(0) -- ./gameover.can:88
end -- ./gameover.can:88
if drawStatus == 3 and input["enter"]:pressed() then -- ./gameover.can:91
entities["find"]("spacestack"):load() -- ./gameover.can:92
entities["find"]("spacebar"):load() -- ./gameover.can:93
entities["find"]("inventory"):load() -- ./gameover.can:94
entities["freeze"] = true -- ./gameover.can:96
local name = uqt["scene"]["current"]["name"] -- ./gameover.can:97
local rect = require("entity.rectangle"):new(0, 0, 1280, 720, { -- ./gameover.can:98
["hud"] = true, -- ./gameover.can:99
["color"] = { -- ./gameover.can:100
1, -- ./gameover.can:100
1, -- ./gameover.can:100
1, -- ./gameover.can:100
0 -- ./gameover.can:100
} -- ./gameover.can:100
}) -- ./gameover.can:100
uqt["scene"]["current"]["time"]["tween"](500, rect["color"], { [4] = 1 }):onEnd(function() -- ./gameover.can:103
rect["remove"] = true -- ./gameover.can:104
entities["freeze"] = false -- ./gameover.can:105
spacebar["usage"] = 0 -- ./gameover.can:106
uqt["scene"]["switch"](restartLevel) -- ./gameover.can:107
end) -- ./gameover.can:107
end -- ./gameover.can:107
end -- ./gameover.can:107
return gameover -- ./gameover.can:112
