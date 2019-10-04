local uqt = require("ubiquitousse") -- ./ending.can:1
local scene = uqt["scene"] -- ./ending.can:2
local entities = require("entities") -- ./ending.can:4
local input = require("input") -- ./ending.can:5
local ending = scene["new"]("platlevel") -- ./ending.can:7
entities:reset(ending) -- ./ending.can:8
local soundFiles = { -- ./ending.can:11
"bidboum.ogg", -- ./ending.can:12
"breakbrokebroken.ogg", -- ./ending.can:12
"butter.ogg", -- ./ending.can:12
"carton2.ogg", -- ./ending.can:12
"carton3.ogg", -- ./ending.can:12
"carton4.ogg", -- ./ending.can:13
"carton5.ogg", -- ./ending.can:13
"carton.ogg", -- ./ending.can:13
"chips.ogg", -- ./ending.can:13
"coin1.ogg", -- ./ending.can:13
"coin2.ogg", -- ./ending.can:13
"coin3.ogg", -- ./ending.can:14
"coin4.ogg", -- ./ending.can:14
"coin5.ogg", -- ./ending.can:14
"coin6.ogg", -- ./ending.can:14
"coin7.ogg", -- ./ending.can:14
"gameover1.wav", -- ./ending.can:14
"gameover2.wav", -- ./ending.can:15
"gameover3.wav", -- ./ending.can:15
"gameover4.wav", -- ./ending.can:15
"gameover5.wav", -- ./ending.can:15
"graze1.ogg", -- ./ending.can:15
"graze2.ogg", -- ./ending.can:16
"groscarton.ogg", -- ./ending.can:16
"humanscream2.ogg", -- ./ending.can:16
"humanscream3.ogg", -- ./ending.can:16
"humanscream.ogg", -- ./ending.can:16
"laser.ogg", -- ./ending.can:17
"manycoins1.ogg", -- ./ending.can:17
"manycoins2.ogg", -- ./ending.can:17
"manycoins3.ogg", -- ./ending.can:17
"manycoins4.ogg", -- ./ending.can:17
"modelm2.wav", -- ./ending.can:18
"momie1.ogg", -- ./ending.can:18
"momie2.ogg", -- ./ending.can:18
"momie3.ogg", -- ./ending.can:18
"newspace.wav", -- ./ending.can:18
"normalzombiescream.ogg", -- ./ending.can:19
"ouch10.ogg", -- ./ending.can:19
"ouch11.ogg", -- ./ending.can:19
"ouch12.ogg", -- ./ending.can:19
"ouch1.ogg", -- ./ending.can:19
"ouch2.ogg", -- ./ending.can:20
"ouch3.ogg", -- ./ending.can:20
"ouch4long.ogg", -- ./ending.can:20
"ouch5.ogg", -- ./ending.can:20
"ouch6.ogg", -- ./ending.can:20
"ouch7.ogg", -- ./ending.can:20
"ouch8.ogg", -- ./ending.can:20
"ouch9.ogg", -- ./ending.can:21
"ouchp1.ogg", -- ./ending.can:21
"ouchp2.ogg", -- ./ending.can:21
"ouchp3.ogg", -- ./ending.can:21
"saut1.ogg", -- ./ending.can:22
"saut2.ogg", -- ./ending.can:22
"saut3.ogg", -- ./ending.can:22
"saut4.ogg", -- ./ending.can:22
"saut5.ogg", -- ./ending.can:22
"saut6.ogg", -- ./ending.can:22
"saut7.ogg", -- ./ending.can:22
"sellerscream.ogg", -- ./ending.can:23
"short_placeholder.wav", -- ./ending.can:23
"touchdown1.ogg", -- ./ending.can:23
"touchdown2.ogg", -- ./ending.can:24
"touchdown3.ogg", -- ./ending.can:24
"touchdown4.ogg", -- ./ending.can:24
"toudim.wav", -- ./ending.can:24
"wilhelmscream.ogg", -- ./ending.can:24
"youlost.wav", -- ./ending.can:25
"zombiescream2.ogg", -- ./ending.can:25
"zombiescream.ogg" -- ./ending.can:25
} -- ./ending.can:25
local sounds = {} -- ./ending.can:27
for i = 1, # soundFiles do -- ./ending.can:28
sounds[i] = love["audio"]["newSource"]("asset/audio/" .. soundFiles[i], "static") -- ./ending.can:29
end -- ./ending.can:29
local earth = love["graphics"]["newImage"]("asset/sprite/earth.png") -- ./ending.can:32
local normalQuad = love["graphics"]["newQuad"](0, 0, 1280, 720, 2560, 720) -- ./ending.can:33
local explodedQuad = love["graphics"]["newQuad"](1280, 0, 1280, 720, 2560, 720) -- ./ending.can:34
ending["enter"] = function(self) -- ./ending.can:36
entities["find"]("inventory")["remove"] = true -- ./ending.can:37
entities["find"]("spacebar")["remove"] = true -- ./ending.can:38
entities["find"]("spacestack")["remove"] = true -- ./ending.can:39
local zik = love["audio"]["newSource"]("asset/audio/Hello_new_friend_farewell_Earth.ogg", "static") -- ./ending.can:41
zik:setLooping(true) -- ./ending.can:42
zik:play() -- ./ending.can:43
ending["exit"] = function(self) -- ./ending.can:44
zik:stop() -- ./ending.can:45
end -- ./ending.can:45
ending["suspend"] = function(self) -- ./ending.can:47
zik:stop() -- ./ending.can:48
end -- ./ending.can:48
ending["resume"] = function(self) -- ./ending.can:50
entities["set"](ending) -- ./ending.can:51
zik:play() -- ./ending.can:52
end -- ./ending.can:52
local epilogue = { -- ./ending.can:55
"S. O. Nic and his not-so-evil twin then lived an happy constant-butter-running life.", -- ./ending.can:56
"Nothing bad could ever happen. Not even the Earth exploding some seconds after.", -- ./ending.can:57
"Or could it ?" -- ./ending.can:58
} -- ./ending.can:58
local livedHappy = require("entity")({ -- ./ending.can:61
["hud"] = true, -- ./ending.can:62
["x"] = 0, -- ./ending.can:63
["y"] = math["random"](50, 670), -- ./ending.can:64
["textStep"] = 1, -- ./ending.can:66
["fade"] = 0, -- ./ending.can:67
["fadeIn"] = true, -- ./ending.can:68
["draw"] = function(self) -- ./ending.can:70
local shift = (self["fadeIn"] and self["fade"]) or (10 - self["fade"]) -- ./ending.can:71
shift = shift * (2) -- ./ending.can:72
shift = shift * ((self["textStep"] % 2 == 0) and - 1 or 1) -- ./ending.can:73
love["graphics"]["setFont"](font["LemonMilk"][24]) -- ./ending.can:74
love["graphics"]["setColor"](1, 1, 1, self["fade"]) -- ./ending.can:75
love["graphics"]["print"](epilogue[self["textStep"]], (1280 - font["LemonMilk"][24]:getWidth(epilogue[self["textStep"]])) / 2 + shift, self["y"]) -- ./ending.can:76
end, -- ./ending.can:76
["update"] = function(self, dt) -- ./ending.can:79
if self["fadeIn"] then -- ./ending.can:80
self["fade"] = self["fade"] + (math["abs"](dt) * 2) -- ./ending.can:81
else -- ./ending.can:81
self["fade"] = self["fade"] - (dt * 2) -- ./ending.can:83
end -- ./ending.can:83
if self["fade"] > 5 and self["fadeIn"] then -- ./ending.can:85
self["fadeIn"] = false -- ./ending.can:86
elseif self["fade"] <= 0 and not self["fadeIn"] then -- ./ending.can:87
self["fadeIn"] = true -- ./ending.can:88
self["textStep"] = self["textStep"] + (1) -- ./ending.can:89
self["y"] = math["random"](50, 670) -- ./ending.can:90
end -- ./ending.can:90
if not epilogue[self["textStep"]] then -- ./ending.can:92
self["remove"] = true -- ./ending.can:93
end -- ./ending.can:93
end -- ./ending.can:93
}):new() -- ./ending.can:61
local earthPlode -- ./ending.can:98
uqt["scene"]["current"]["time"]["run"](function() -- ./ending.can:99
earthPlode = require("entity")({ -- ./ending.can:100
["hud"] = true, -- ./ending.can:101
["x"] = 0, -- ./ending.can:102
["y"] = 0, -- ./ending.can:103
["exploded"] = false, -- ./ending.can:104
["draw"] = function(self) -- ./ending.can:106
love["graphics"]["draw"](earth, self["exploded"] and explodedQuad or normalQuad, self["x"], self["y"]) -- ./ending.can:107
end -- ./ending.can:107
}):new() -- ./ending.can:100
end):after(15000) -- ./ending.can:110
uqt["scene"]["current"]["time"]["run"](function() -- ./ending.can:111
earthPlode["exploded"] = true -- ./ending.can:112
for i = 1, # sounds do -- ./ending.can:113
sounds[i]:play() -- ./ending.can:114
end -- ./ending.can:114
end):after(16000) -- ./ending.can:116
uqt["scene"]["current"]["time"]["run"](function() -- ./ending.can:117
earthPlode["remove"] = true -- ./ending.can:118
end):after(17000) -- ./ending.can:119
uqt["scene"]["current"]["time"]["run"](function() -- ./ending.can:121
require("entity.hud.achievement"):new("Everything makes sense now", love["graphics"]["newImage"]("asset/sprite/achievements/theend.png")) -- ./ending.can:122
theend = require("entity")({ ["draw"] = function(self) -- ./ending.can:124
love["graphics"]["setFont"](font["LemonMilk"][94]) -- ./ending.can:125
love["graphics"]["print"]("-- The End --", (1280 - font["LemonMilk"][94]:getWidth("-- The End --")) / 2, (720 - font["LemonMilk"][94]:getHeight("~~ The End ~~")) / 2) -- ./ending.can:126
end }):new() -- ./ending.can:123
end):after(20000) -- ./ending.can:129
end -- ./ending.can:129
return ending -- ./ending.can:132
