local uqt = require("ubiquitousse") -- ./cimetiere.can:1
local scene = uqt["scene"] -- ./cimetiere.can:2
local entities = require("entities") -- ./cimetiere.can:4
local shine = require("shine") -- ./cimetiere.can:5
local Map = require("entity.map") -- ./cimetiere.can:7
local BgParalax = require("entity.bgparalax") -- ./cimetiere.can:9
local start = scene["new"]("cimetiere") -- ./cimetiere.can:11
entities["reset"](start) -- ./cimetiere.can:12
start["effect"] = shine["vignette"]({ -- ./cimetiere.can:13
["radius"] = 1.4, -- ./cimetiere.can:14
["opacity"] = 0.3 -- ./cimetiere.can:15
}) -- ./cimetiere.can:15
start["score"] = { -- ./cimetiere.can:17
["maxSpeed"] = 0, -- ./cimetiere.can:18
["maxSpeedDuration"] = 0, -- ./cimetiere.can:19
["thingsKilled"] = 0, -- ./cimetiere.can:20
["maxTier"] = 1, -- ./cimetiere.can:21
["time"] = 0, -- ./cimetiere.can:22
["thingsGrazed"] = 0 -- ./cimetiere.can:23
} -- ./cimetiere.can:23
start["enter"] = function(self, power) -- ./cimetiere.can:26
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./cimetiere.can:27
local map = Map:new("asset/map/Cimetiere1.lua") -- ./cimetiere.can:30
local zik = love["audio"]["newSource"]("asset/audio/Crypt_of_the_Peanut_Butter.ogg", "static") -- ./cimetiere.can:32
zik:setLooping(true) -- ./cimetiere.can:33
zik:play() -- ./cimetiere.can:34
start["exit"] = function(self) -- ./cimetiere.can:35
zik:stop() -- ./cimetiere.can:36
end -- ./cimetiere.can:36
start["suspend"] = function(self) -- ./cimetiere.can:38
zik:stop() -- ./cimetiere.can:39
end -- ./cimetiere.can:39
start["resume"] = function(self) -- ./cimetiere.can:41
entities["set"](start) -- ./cimetiere.can:42
zik:play() -- ./cimetiere.can:43
end -- ./cimetiere.can:43
local achimg = love["graphics"]["newImage"]("asset/sprite/achievements/level2.png") -- ./cimetiere.can:51
local achievement = require("entity.hud.achievement"):new("LEVEL -2", achimg) -- ./cimetiere.can:52
local txt = require("entity.text"):new(font["LemonMilk"][54], "The Store's Crypt", 1280 - 50, 720 - 100, { -- ./cimetiere.can:54
["hud"] = true, -- ./cimetiere.can:55
["color"] = { -- ./cimetiere.can:56
1, -- ./cimetiere.can:56
1, -- ./cimetiere.can:56
1, -- ./cimetiere.can:56
1 -- ./cimetiere.can:56
}, -- ./cimetiere.can:56
["shadowColor"] = { -- ./cimetiere.can:57
0, -- ./cimetiere.can:57
0, -- ./cimetiere.can:57
0, -- ./cimetiere.can:57
1 -- ./cimetiere.can:57
}, -- ./cimetiere.can:57
["alignX"] = "right", -- ./cimetiere.can:58
["alignY"] = "bottom" -- ./cimetiere.can:58
}) -- ./cimetiere.can:58
start["time"]["tween"](500, txt["color"], { [4] = 0 }):after(2500) -- ./cimetiere.can:60
start["time"]["tween"](500, txt["shadowColor"], { [4] = 0 }):after(2500) -- ./cimetiere.can:61
local rect = require("entity.rectangle"):new(0, 0, 1280, 720, { -- ./cimetiere.can:63
["hud"] = true, -- ./cimetiere.can:64
["color"] = { -- ./cimetiere.can:65
0, -- ./cimetiere.can:65
0, -- ./cimetiere.can:65
0, -- ./cimetiere.can:65
1 -- ./cimetiere.can:65
} -- ./cimetiere.can:65
}) -- ./cimetiere.can:65
start["time"]["tween"](500, rect["color"], { [4] = 0 }) -- ./cimetiere.can:67
end -- ./cimetiere.can:67
return start -- ./cimetiere.can:70
