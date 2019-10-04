local uqt = require("ubiquitousse") -- ./game.can:1
local scene = uqt["scene"] -- ./game.can:2
local entities = require("entities") -- ./game.can:4
local shine = require("shine") -- ./game.can:5
local Map = require("entity.map") -- ./game.can:7
local BgParalax = require("entity.bgparalax") -- ./game.can:9
local start = scene["new"]("platlevel") -- ./game.can:11
entities["reset"](start) -- ./game.can:12
start["effect"] = shine["vignette"]({ -- ./game.can:13
["radius"] = 1.4, -- ./game.can:14
["opacity"] = 0.3 -- ./game.can:15
}) -- ./game.can:15
start["enter"] = function(self, power) -- ./game.can:18
love["graphics"]["setBackgroundColor"](0, 0, 0, 1) -- ./game.can:19
start["exit"] = function(self) -- ./game.can:27
 -- ./game.can:29
end -- ./game.can:29
start["suspend"] = function(self) -- ./game.can:30
 -- ./game.can:32
end -- ./game.can:32
start["resume"] = function(self) -- ./game.can:33
entities["set"](start) -- ./game.can:34
end -- ./game.can:34
local spacebar = require("entity.hud.spacebar"):new() -- ./game.can:57
local spacestack = require("entity.hud.spacestack"):new() -- ./game.can:58
local inventory = require("entity.hud.inventory"):new() -- ./game.can:59
entities["find"]("spacestack"):save() -- ./game.can:61
entities["find"]("spacebar"):save() -- ./game.can:62
entities["find"]("inventory"):save() -- ./game.can:63
local t = require("entity.text"):new(font["LemonMilk"][94], "Reuh, Ihampf, Trocentraisin and Céleste Granger\
are relatively proud to show you", 0, love["graphics"]["getHeight"]() / 2, { -- ./game.can:67
["alignX"] = "center", -- ./game.can:68
["alignY"] = "center", -- ./game.can:68
["limit"] = love["graphics"]["getWidth"](), -- ./game.can:69
["color"] = { -- ./game.can:70
1, -- ./game.can:70
1, -- ./game.can:70
1, -- ./game.can:70
1 -- ./game.can:70
} -- ./game.can:70
}) -- ./game.can:70
local t2 = require("entity.text"):new(font["LemonMilk"][94], "Swietoslaw Ozbej Nic Adventure", 0, love["graphics"]["getHeight"]() / 2, { -- ./game.can:72
["alignX"] = "center", -- ./game.can:73
["alignY"] = "center", -- ./game.can:73
["limit"] = love["graphics"]["getWidth"](), -- ./game.can:74
["color"] = { -- ./game.can:75
1, -- ./game.can:75
1, -- ./game.can:75
1, -- ./game.can:75
0 -- ./game.can:75
} -- ./game.can:75
}) -- ./game.can:75
start["time"]["tween"](500, t["color"], { [4] = 0 }):after(3000):onEnd(function() -- ./game.can:81
love["audio"]["newSource"]("asset/audio/horn.wav", "static"):play() -- ./game.can:82
end):chain(500, t2["color"], { [4] = 1 }):chain(10, t2["color"], { [4] = 0 }):after(1800):onEnd(function() -- ./game.can:90
scene["switch"]("spuermarche") -- ./game.can:91
end) -- ./game.can:91
end -- ./game.can:91
return start -- ./game.can:95
