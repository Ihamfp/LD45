local Solid = require("entity.solid")
local anim8 = require("anim8")

local idleImg = love.graphics.newImage("asset/sprite/hyke.png")

return Solid {
	__name = "warp",
	noCollide = true,
	to = "undefined"
}
