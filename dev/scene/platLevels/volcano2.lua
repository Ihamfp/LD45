local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")

local Map = require("entity.map")
local BgParalax = require("entity.bgparalax")

local start = scene.new("volcano2")
entities.reset()

--local bg = BgParalax:new("f.png")
local map = Map:new("asset/map/volcano2.lua")

return start
