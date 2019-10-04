local uqt = require("ubiquitousse") -- ./spuermarche.can:1
local scene = uqt["scene"] -- ./spuermarche.can:2
local entities = require("entities") -- ./spuermarche.can:4
local shine = require("shine") -- ./spuermarche.can:5
local Map = require("entity.map") -- ./spuermarche.can:7
local BgParalax = require("entity.bgparalax") -- ./spuermarche.can:9
local start = scene["new"]("spuermarche") -- ./spuermarche.can:11
entities["reset"](start) -- ./spuermarche.can:12
start["effect"] = shine["vignette"]({ -- ./spuermarche.can:13
["radius"] = 1.4, -- ./spuermarche.can:14
["opacity"] = 0.3 -- ./spuermarche.can:15
}) -- ./spuermarche.can:15
start["score"] = { -- ./spuermarche.can:17
["maxSpeed"] = 0, -- ./spuermarche.can:18
["maxSpeedDuration"] = 0, -- ./spuermarche.can:19
["thingsKilled"] = 0, -- ./spuermarche.can:20
["maxTier"] = 1, -- ./spuermarche.can:21
["time"] = 0, -- ./spuermarche.can:22
["thingsGrazed"] = 0 -- ./spuermarche.can:23
} -- ./spuermarche.can:23
start["enter"] = function(self, power) -- ./spuermarche.can:26
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./spuermarche.can:27
local map = Map:new("asset/map/SuperMarche2-2.lua", { ["aboveAll"] = true }) -- ./spuermarche.can:30
local zik = love["audio"]["newSource"]("asset/audio/Peanut_Butter_Department.ogg", "static") -- ./spuermarche.can:32
zik:setLooping(true) -- ./spuermarche.can:33
zik:play() -- ./spuermarche.can:34
start["exit"] = function(self) -- ./spuermarche.can:35
zik:stop() -- ./spuermarche.can:36
end -- ./spuermarche.can:36
start["suspend"] = function(self) -- ./spuermarche.can:38
zik:stop() -- ./spuermarche.can:39
end -- ./spuermarche.can:39
start["resume"] = function(self) -- ./spuermarche.can:41
entities["set"](start) -- ./spuermarche.can:42
zik:play() -- ./spuermarche.can:43
end -- ./spuermarche.can:43
entities["noSprites"] = true -- ./spuermarche.can:46
local spriteLayer = map["map"]:addCustomLayer("Sprite Layer", 18) -- ./spuermarche.can:47
spriteLayer["draw"] = function() -- ./spuermarche.can:48
for _, v in ipairs(entities["list"]) do -- ./spuermarche.can:49
if v["visible"] then -- ./spuermarche.can:50
v:draw(entities["dxV"], entities["dyV"], entities["sx"], entities["sy"]) -- ./spuermarche.can:50
end -- ./spuermarche.can:50
end -- ./spuermarche.can:50
end -- ./spuermarche.can:50
local achimg = love["graphics"]["newImage"]("asset/sprite/achievements/level0.png") -- ./spuermarche.can:59
local achievement = require("entity.hud.achievement"):new("GAME (JAM) START", achimg) -- ./spuermarche.can:60
local rect = require("entity.rectangle"):new(0, 0, 1280, 720, { -- ./spuermarche.can:62
["hud"] = true, -- ./spuermarche.can:63
["color"] = { -- ./spuermarche.can:64
0, -- ./spuermarche.can:64
0, -- ./spuermarche.can:64
0, -- ./spuermarche.can:64
1 -- ./spuermarche.can:64
} -- ./spuermarche.can:64
}) -- ./spuermarche.can:64
start["time"]["tween"](500, rect["color"], { [4] = 0 }) -- ./spuermarche.can:66
end -- ./spuermarche.can:66
return start -- ./spuermarche.can:69
