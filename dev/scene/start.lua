local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")

local Map = require("entity.map")
local Hyke = require("entity.hyke")

local start = scene.new("splash")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.2,
	opacity = 0.4
}

local map = Map:new("asset/map/start.lua")

local hyke = Hyke:new(100, 100)

return start
