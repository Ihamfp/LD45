local uqt = require("ubiquitousse") -- ./reserve.can:1
local scene = uqt["scene"] -- ./reserve.can:2
local entities = require("entities") -- ./reserve.can:4
local shine = require("shine") -- ./reserve.can:5
local Map = require("entity.map") -- ./reserve.can:7
local BgParalax = require("entity.bgparalax") -- ./reserve.can:9
local start = scene["new"]("reserve") -- ./reserve.can:11
entities["reset"](start) -- ./reserve.can:12
start["effect"] = shine["vignette"]({ -- ./reserve.can:13
["radius"] = 1.4, -- ./reserve.can:14
["opacity"] = 0.3 -- ./reserve.can:15
}) -- ./reserve.can:15
start["score"] = { -- ./reserve.can:17
["maxSpeed"] = 0, -- ./reserve.can:18
["maxSpeedDuration"] = 0, -- ./reserve.can:19
["thingsKilled"] = 0, -- ./reserve.can:20
["maxTier"] = 1, -- ./reserve.can:21
["time"] = 0, -- ./reserve.can:22
["thingsGrazed"] = 0 -- ./reserve.can:23
} -- ./reserve.can:23
start["enter"] = function(self, power) -- ./reserve.can:26
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./reserve.can:27
local map = Map:new("asset/map/Reserve1.lua") -- ./reserve.can:30
local zik = love["audio"]["newSource"]("asset/audio/Space_Bar_Stock.ogg", "static") -- ./reserve.can:32
zik:setLooping(true) -- ./reserve.can:33
zik:play() -- ./reserve.can:34
start["exit"] = function(self) -- ./reserve.can:35
zik:stop() -- ./reserve.can:36
end -- ./reserve.can:36
start["suspend"] = function(self) -- ./reserve.can:38
zik:stop() -- ./reserve.can:39
end -- ./reserve.can:39
start["resume"] = function(self) -- ./reserve.can:41
entities["set"](start) -- ./reserve.can:42
zik:play() -- ./reserve.can:43
end -- ./reserve.can:43
local achimg = love["graphics"]["newImage"]("asset/sprite/achievements/level1.png") -- ./reserve.can:51
local achievement = require("entity.hud.achievement"):new("LEVEL -1", achimg) -- ./reserve.can:52
local txt = require("entity.text"):new(font["LemonMilk"][54], "Space Storage", 1280 - 50, 720 - 100, { -- ./reserve.can:54
["hud"] = true, -- ./reserve.can:55
["color"] = { -- ./reserve.can:56
1, -- ./reserve.can:56
1, -- ./reserve.can:56
1, -- ./reserve.can:56
1 -- ./reserve.can:56
}, -- ./reserve.can:56
["shadowColor"] = { -- ./reserve.can:57
0, -- ./reserve.can:57
0, -- ./reserve.can:57
0, -- ./reserve.can:57
1 -- ./reserve.can:57
}, -- ./reserve.can:57
["alignX"] = "right", -- ./reserve.can:58
["alignY"] = "bottom" -- ./reserve.can:58
}) -- ./reserve.can:58
start["time"]["tween"](500, txt["color"], { [4] = 0 }):after(2500) -- ./reserve.can:60
start["time"]["tween"](500, txt["shadowColor"], { [4] = 0 }):after(2500) -- ./reserve.can:61
local rect = require("entity.rectangle"):new(0, 0, 1280, 720, { -- ./reserve.can:63
["hud"] = true, -- ./reserve.can:64
["color"] = { -- ./reserve.can:65
0, -- ./reserve.can:65
0, -- ./reserve.can:65
0, -- ./reserve.can:65
1 -- ./reserve.can:65
} -- ./reserve.can:65
}) -- ./reserve.can:65
start["time"]["tween"](500, rect["color"], { [4] = 0 }) -- ./reserve.can:67
end -- ./reserve.can:67
return start -- ./reserve.can:70
