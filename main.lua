--- LD45
-- This is the story of potatoes in Greenland.

math.randomseed(os.time())

-- Set path
package.path = "?.lua;?/init.lua;source/?.lua;source/?/init.lua;source/?/?.lua;source/lib/?.lua;source/lib/?/init.lua;source/lib/?/?.lua"
-- love.filesystem.setRequirePath(package.path) -- Someday I'll understand how Löve handle this shit, but today is not that day. "works for me"
dofile = function(path)
	return love.filesystem.load(path)()
end
io.open = function(path, mode)
	return love.filesystem.newFile(path, mode)
end
table.insert(package.loaders, function(mod)
	for p in package.path:gmatch("([^;]+)") do
		local m = mod:gsub("%.", "/")
		local path = p:gsub("%?", m)
		local fileInfo = love.filesystem.getInfo(path)
		if fileInfo and fileInfo.type == "file" then
			return love.filesystem.load(path)
		end
	end
	return "sorry pal"
end)

-- Set filter
love.graphics.setDefaultFilter("nearest", "nearest", 0)

-- debug.sethook(function()
-- 	local t = debug.getinfo(2)
-- 	print(t.currentline, t.source)
-- end, "c")

-- Font
font = {
	LemonMilk = {
		[10] = love.graphics.newFont("asset/font/LemonMilk.otf", 10),
		[14] = love.graphics.newFont("asset/font/LemonMilk.otf", 14),
		[24] = love.graphics.newFont("asset/font/LemonMilk.otf", 24),
		[54] = love.graphics.newFont("asset/font/LemonMilk.otf", 54),
		[94] = love.graphics.newFont("asset/font/LemonMilk.otf", 84),
	},
	Stanberry = {
		[22] = love.graphics.newFont("asset/font/Stanberry.ttf", 22),
		[26] = love.graphics.newFont("asset/font/Stanberry.ttf", 26),
	},
	PerfectDOS = {
		[54] = love.graphics.newFont("asset/font/PerfectDOS.ttf", 54),
		[120] = love.graphics.newFont("asset/font/PerfectDOS.ttf", 120),
	}
}

-- Load libs
local uqt = require("ubiquitousse")
uqt.scene.prefix = "scene."

local entities = require("entities")
uqt.event.update = entities.update
uqt.event.draw = function()
	love.graphics.setColor(1, 1, 1, 1)
	if uqt.scene.current.effect then
		uqt.scene.current.effect(function()
			entities.draw()
		end)
	else
		entities.draw()
	end
	if uqt.scene.current.drawOver then
		uqt.scene.current.drawOver()
	end
end

-- Start
--uqt.scene.switch("splash")
uqt.scene.switch("mainmap")
