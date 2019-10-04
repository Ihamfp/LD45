local uqt = require("ubiquitousse") -- ./totheboss.can:1
local scene = uqt["scene"] -- ./totheboss.can:2
local entities = require("entities") -- ./totheboss.can:4
local shine = require("shine") -- ./totheboss.can:5
local Map = require("entity.map") -- ./totheboss.can:7
local BgParalax = require("entity.bgparalax") -- ./totheboss.can:9
local start = scene["new"]("totheboss") -- ./totheboss.can:11
entities["reset"](start) -- ./totheboss.can:12
start["effect"] = shine["vignette"]({ -- ./totheboss.can:13
["radius"] = 1.4, -- ./totheboss.can:14
["opacity"] = 0.3 -- ./totheboss.can:15
}) -- ./totheboss.can:15
start["score"] = { -- ./totheboss.can:17
["maxSpeed"] = 0, -- ./totheboss.can:18
["maxSpeedDuration"] = 0, -- ./totheboss.can:19
["thingsKilled"] = 0, -- ./totheboss.can:20
["maxTier"] = 1, -- ./totheboss.can:21
["time"] = 0, -- ./totheboss.can:22
["thingsGrazed"] = 0 -- ./totheboss.can:23
} -- ./totheboss.can:23
start["enter"] = function(self, power) -- ./totheboss.can:26
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./totheboss.can:27
local map = Map:new("asset/map/totheboss.lua") -- ./totheboss.can:30
local zik = love["audio"]["newSource"]("asset/audio/Forgotten_Blues.ogg", "static") -- ./totheboss.can:32
zik:setLooping(true) -- ./totheboss.can:33
zik:play() -- ./totheboss.can:34
start["exit"] = function(self) -- ./totheboss.can:35
zik:stop() -- ./totheboss.can:36
end -- ./totheboss.can:36
start["suspend"] = function(self) -- ./totheboss.can:38
zik:stop() -- ./totheboss.can:39
end -- ./totheboss.can:39
start["resume"] = function(self) -- ./totheboss.can:41
entities["set"](start) -- ./totheboss.can:42
zik:play() -- ./totheboss.can:43
end -- ./totheboss.can:43
local achimg = love["graphics"]["newImage"]("asset/sprite/achievements/level3.png") -- ./totheboss.can:51
local achievement = require("entity.hud.achievement"):new("LEVEL -3", achimg) -- ./totheboss.can:52
local rect = require("entity.rectangle"):new(0, 0, 1280, 720, { -- ./totheboss.can:54
["hud"] = true, -- ./totheboss.can:55
["color"] = { -- ./totheboss.can:56
0, -- ./totheboss.can:56
0, -- ./totheboss.can:56
0, -- ./totheboss.can:56
1 -- ./totheboss.can:56
} -- ./totheboss.can:56
}) -- ./totheboss.can:56
start["time"]["tween"](500, rect["color"], { [4] = 0 }) -- ./totheboss.can:58
start["time"]["run"](function() -- ./totheboss.can:60
 -- ./totheboss.can:60
end):after(500):chain(function() -- ./totheboss.can:60
local txt = require("entity.text"):new(font["LemonMilk"][54], "Ludum Dare\
Old Themes Storage", 1280 - 50, 720 - 150, { -- ./totheboss.can:61
["hud"] = true, -- ./totheboss.can:62
["color"] = { -- ./totheboss.can:63
1, -- ./totheboss.can:63
1, -- ./totheboss.can:63
1, -- ./totheboss.can:63
0 -- ./totheboss.can:63
}, -- ./totheboss.can:63
["shadowColor"] = { -- ./totheboss.can:64
0, -- ./totheboss.can:64
0, -- ./totheboss.can:64
0, -- ./totheboss.can:64
0 -- ./totheboss.can:64
}, -- ./totheboss.can:64
["alignX"] = "right", -- ./totheboss.can:65
["alignY"] = "bottom" -- ./totheboss.can:65
}) -- ./totheboss.can:65
start["time"]["tween"](500, txt["color"], { [4] = 1 }):after(500):chain(500, { [4] = 0 }):after(2500) -- ./totheboss.can:67
start["time"]["tween"](500, txt["shadowColor"], { [4] = 1 }):after(500):chain(500, { [4] = 0 }):after(2500) -- ./totheboss.can:68
end):startWhen(function() -- ./totheboss.can:69
return not entities["freezeButHyke"] -- ./totheboss.can:69
end) -- ./totheboss.can:69
end -- ./totheboss.can:69
return start -- ./totheboss.can:72
