--- Löve backend 0.0.1 for Ubiquitousse.
-- Provides all the Ubiquitousse API on a Löve environment.
-- Made for Löve 0.10.1 and Ubiquitousse 0.0.1.
-- See `ubiquitousse` for Ubiquitousse API.

-- Config
local useScancodes = true -- Use ScanCodes (layout independant input) instead of KeyConstants (layout dependant) for keyboard input
local displayKeyConstant = true -- If using ScanCodes, sets this to true so the backend returns the layout-dependant KeyConstant
                                -- instead of the raw ScanCode when getting the display name. If set to false and using ScanCodes,
                                -- the user will see keys that don't match what's actually written on his keyboard, which is confusing.

-- General
local version = "0.0.1"

-- Require stuff
local uqt = require((...):match("^(.-ubiquitousse)%."))
local m = uqt.module

-- Version compatibility warning
do
	local function checkCompat(stuffName, expectedVersion, actualVersion)
		if actualVersion ~= expectedVersion then
			local txt = ("Ubiquitousse Löve backend version "..version.." was made for %s %s but %s is used!\nThings may not work as expected.")
			            :format(stuffName, expectedVersion, actualVersion)
			print(txt)
			love.window.showMessageBox("Warning", txt, "warning")
		end
	end
	--checkCompat("Löve", "11.2.0", ("%s.%s.%s"):format(love.getVersion()))
	checkCompat("Ubiquitousse", "0.0.1", uqt.version)
end

-- Redefine all functions in tbl which also are in toAdd, so when used they call the old function (in tbl) and then the new (in toAdd).
-- Functions with names prefixed by a exclamation mark will overwrite the old function.
local function add(tbl, toAdd)
	for k,v in pairs(toAdd) do
		local old = tbl[k]
		if k:sub(1,1) == "!" then
			tbl[k] = v
		else
			tbl[k] = function(...)
				old(...)
				return v(...)
			end
		end
	end
end

-- uqt
uqt.backend = "love"

-- uqt.event
if m.event then
local updateDefault = uqt.event.update
uqt.event.update = function() end
function love.update(dt)
	-- Stuff defined in ubiquitousse.lua
	updateDefault(dt*1000)

	-- Callback
	uqt.event.update(dt)
end

local drawDefault = uqt.event.draw
uqt.event.draw = function() end
function love.draw()
	if m.draw then
		love.graphics.push()

		-- Resize type
		local winW, winH = love.graphics.getWidth(), love.graphics.getHeight()
		local gameW, gameH = uqt.draw.params.width, uqt.draw.params.height
		if uqt.draw.params.resizeType == "auto" then
			love.graphics.scale(winW/gameW, winH/gameH)
		elseif uqt.draw.params.resizeType == "center" then
			love.graphics.translate(math.floor(winW/2-gameW/2), math.floor(winH/2-gameH/2))
		end
	end

	-- Stuff defined in ubiquitousse.lua
	drawDefault()

	-- Callback
	uqt.event.draw()

	if m.draw then
		love.graphics.pop()
	end
end
end

-- uqt.draw
if m.draw then
local defaultFont = love.graphics.getFont()
add(uqt.draw, {
	init = function(params)
		local p = uqt.draw.params
		love.window.setTitle(p.title)
		love.window.setMode(p.width, p.height, {
			resizable = p.resizable
		})
	end,
	fps = function()
		return love.timer.getFPS()
	end,
	color = function(r, g, b, a)
		love.graphics.setColor(r, g, b, a)
	end,
	text = function(x, y, text)
		love.graphics.setFont(defaultFont)
		love.graphics.print(text, x, y)
	end,
	point = function(x, y, ...)
		love.graphics.points(x, y, ...)
	end,
	lineWidth = function(width)
		love.graphics.setLineWidth(width)
	end,
	line = function(x1, y1, x2, y2, ...)
		love.graphics.line(x1, y1, x2, y2, ...)
	end,
	polygon = function(...)
		love.graphics.polygon("fill", ...)
	end,
	linedPolygon = function(...)
		love.graphics.polygon("line", ...)
	end,
	["!rectangle"] = function(x, y, width, height)
		love.graphics.rectangle("fill", x, y, width, height)
	end,
	["!linedRectangle"] = function(x, y, width, height)
		love.graphics.rectangle("line", x, y, width, height)
	end,
	circle = function(x, y, radius)
		love.graphics.circle("fill", x, y, radius)
	end,
	linedCircle = function(x, y, radius)
		love.graphics.circle("line", x, y, radius)
	end,
	scissor = function(x, y, width, height)
		love.graphics.setScissor(x, y, width, height)
	end,
	-- TODO: cf draw.lua
	image = function(filename)
		local img = love.graphics.newImage(filename)
		return {
			width = img:getWidth(),
			height = img:getHeight(),
			draw = function(self, x, y, r, sx, sy, ox, oy)
				love.graphics.draw(img, x, y, r, sx, sy, ox, oy)
			end
		}
	end,
	font = function(filename, size)
		local fnt = love.graphics.newFont(filename, size)
		return {
			width = function(self, text)
				return fnt:getWidth(text)
			end,
			draw = function(self, text, x, y, r, sx, sy, ox, oy)
				love.graphics.setFont(fnt)
				love.graphics.print(text, x, y, r, sx, sy, ox, oy)
			end
		}
	end,
})
function love.resize(width, height)
	if uqt.draw.params.resizeType == "none" then
		uqt.draw.width = width
		uqt.draw.height = height
	end
end
elseif m.input then -- fields required by uqt.input
	uqt.draw = {
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight()
	}
end

-- uqt.audio
if m.audio then
add(uqt.audio, {
	-- TODO: cf audio.lua
	load = function(filepath)
		local audio = love.audio.newSource(filepath)
		return {
			play = function(self)
				audio:play()
			end
		}
	end
})
end

-- uqt.time
if m.time then
add(uqt.time, {
	get = function()
		return love.timer.getTime() * 1000
	end
})
end

-- uqt.input
if m.input then
local buttonsInUse = {}
local axesInUse = {}
function love.keypressed(key, scancode, isrepeat)
	if useScancodes then key = scancode end
	buttonsInUse["keyboard."..key] = true
end
function love.keyreleased(key, scancode)
	if useScancodes then key = scancode end
	buttonsInUse["keyboard."..key] = nil
end
function love.mousepressed(x, y, button, istouch)
	buttonsInUse["mouse."..button] = true
end
function love.mousereleased(x, y, button, istouch)
	buttonsInUse["mouse."..button] = nil
end
function love.wheelmoved(x, y)
	if y > 0 then
		buttonsInUse["mouse.wheel.up"] = true
	elseif y < 0 then
		buttonsInUse["mouse.wheel.down"] = true
	end
	if x > 0 then
		buttonsInUse["mouse.wheel.right"] = true
	elseif x < 0 then
		buttonsInUse["mouse.wheel.left"] = true
	end
end
function love.mousemoved(x, y, dx, dy)
	if dx ~= 0 then axesInUse["mouse.move.x"] = dx/love.graphics.getWidth() end
	if dy ~= 0 then axesInUse["mouse.move.y"] = dy/love.graphics.getHeight() end
end
function love.gamepadpressed(joystick, button)
	buttonsInUse["gamepad.button."..joystick:getID().."."..button] = true
end
function love.gamepadreleased(joystick, button)
	buttonsInUse["gamepad.button."..joystick:getID().."."..button] = nil
end
function love.gamepadaxis(joystick, axis, value)
	if value ~= 0 then
		axesInUse["gamepad.axis."..joystick:getID().."."..axis] = value
	else
		axesInUse["gamepad.axis."..joystick:getID().."."..axis] = nil
	end
end

love.mouse.setVisible(false)

add(uqt.input, {
	-- love.wheelmoved doesn't trigger when the wheel stop moving, so we need to clear up our stuff at each update
	update = function()
		buttonsInUse["mouse.wheel.up"] = nil
		buttonsInUse["mouse.wheel.down"] = nil
		buttonsInUse["mouse.wheel.right"] = nil
		buttonsInUse["mouse.wheel.left"] = nil
		-- Same for mouse axis
		axesInUse["mouse.move.x"] = nil
		axesInUse["mouse.move.y"] = nil
	end,

	buttonDetector = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Keyboard
			if id:match("^keyboard%.") then
				local key = id:match("^keyboard%.(.+)$")
				table.insert(ret, function()
					return useScancodes and love.keyboard.isScancodeDown(key) or love.keyboard.isDown(key)
				end)
			-- Mouse wheel
			elseif id:match("^mouse%.wheel%.") then
				local key = id:match("^mouse%.wheel%.(.+)$")
				table.insert(ret, function()
					return buttonsInUse["mouse.wheel."..key]
				end)
			-- Mouse
			elseif id:match("^mouse%.") then
				local key = id:match("^mouse%.(.+)$")
				table.insert(ret, function()
					return love.mouse.isDown(key)
				end)
			-- Gamepad button
			elseif id:match("^gamepad%.button%.") then
				local gid, key = id:match("^gamepad%.button%.(.+)%.(.+)$")
				gid = tonumber(gid)
				table.insert(ret, function()
					local gamepad
					for _,j in ipairs(love.joystick.getJoysticks()) do
						if j:getID() == gid then gamepad = j end
					end
					return gamepad and gamepad:isGamepadDown(key)
				end)
			-- Gamepad axis
			elseif id:match("^gamepad%.axis%.") then
				local gid, axis, threshold = id:match("^gamepad%.axis%.(.+)%.(.+)%%(.+)$")
				if not gid then gid, axis = id:match("^gamepad%.axis%.(.+)%.(.+)$") end -- no threshold (=0)
				gid = tonumber(gid)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local gamepad
					for _,j in ipairs(love.joystick.getJoysticks()) do
						if j:getID() == gid then gamepad = j end
					end
					if not gamepad then
						return false
					else
						local val = gamepad:getGamepadAxis(axis)
						return (math.abs(val) > math.abs(threshold)) and ((val < 0) == (threshold < 0))
					end
				end)
			else
				error("Unknown button identifier: "..id)
			end
		end
		return unpack(ret)
	end,

	axisDetector = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Binary axis
			if id:match(".+%,.+") then
				local d1, d2 = uqt.input.buttonDetector(id:match("^(.+)%,(.+)$"))
				table.insert(ret, function()
					local b1, b2 = d1(), d2()
					if b1 and b2 then return 0
					elseif b1 then return -1
					elseif b2 then return 1
					else return 0 end
				end)
			-- Mouse movement
			elseif id:match("^mouse%.move%.") then
				local axis, threshold = id:match("^mouse%.move%.(.+)%%(.+)$")
				if not axis then axis = id:match("^mouse%.move%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local val, raw, max = axesInUse["mouse.move."..axis] or 0, 0, 1
					if axis == "x" then
						raw, max = val * love.graphics.getWidth(), love.graphics.getWidth()
					elseif axis == "y" then
						raw, max = val * love.graphics.getHeight(), love.graphics.getHeight()
					end
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Mouse position
			elseif id:match("^mouse%.position%.") then
				local axis, threshold = id:match("^mouse%.position%.(.+)%%(.+)$")
				if not axis then axis = id:match("^mouse%.position%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local val, raw, max = 0, 0, 1
					if axis == "x" then
						max = love.graphics.getWidth() / 2 -- /2 because x=0,y=0 is the center of the screen (an axis value is in [-1,1])
						raw = love.mouse.getX() - max
					elseif axis == "y" then
						max = love.graphics.getHeight() / 2
						raw = love.mouse.getY() - max
					end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Gamepad axis
			elseif id:match("^gamepad%.axis%.") then
				local gid, axis, threshold = id:match("^gamepad%.axis%.(.+)%.(.+)%%(.+)$")
				if not gid then gid, axis = id:match("^gamepad%.axis%.(.+)%.(.+)$") end -- no threshold (=0)
				gid = tonumber(gid)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local gamepad
					for _,j in ipairs(love.joystick.getJoysticks()) do
						if j:getID() == gid then gamepad = j end
					end
					if not gamepad then
						return 0
					else
						local val = gamepad:getGamepadAxis(axis)
						return math.abs(val) > math.abs(threshold) and val or 0
					end
				end)
			else
				error("Unknown axis identifier: "..id)
			end
		end
		return unpack(ret)
	end,

	buttonsInUse = function(threshold)
		local r = {}
		threshold = threshold or 0.5
		for b in pairs(buttonsInUse) do
			table.insert(r, b)
		end
		for b,v in pairs(axesInUse) do
			if math.abs(v) > threshold then
				table.insert(r, b.."%"..(v < 0 and -threshold or threshold))
			end
		end
		return r
	end,

	axesInUse = function(threshold)
		local r = {}
		threshold = threshold or 0.5
		for b,v in pairs(axesInUse) do
			if math.abs(v) > threshold then
				table.insert(r, b.."%"..threshold)
			end
		end
		return r
	end,

	buttonName = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Keyboard
			if id:match("^keyboard%.") then
				local key = id:match("^keyboard%.(.+)$")
				if useScancodes and displayKeyConstant then key = love.keyboard.getKeyFromScancode(key) end
				table.insert(ret, key:sub(1,1):upper()..key:sub(2).." key")
			-- Mouse wheel
			elseif id:match("^mouse%.wheel%.") then
				local key = id:match("^mouse%.wheel%.(.+)$")
				table.insert(ret, "Mouse wheel "..key)
			-- Mouse
			elseif id:match("^mouse%.") then
				local key = id:match("^mouse%.(.+)$")
				table.insert(ret, "Mouse "..key)
			-- Gamepad button
			elseif id:match("^gamepad%.button%.") then
				local gid, key = id:match("^gamepad%.button%.(.+)%.(.+)$")
				table.insert(ret, "Gamepad "..gid.." button "..key)
			-- Gamepad axis
			elseif id:match("^gamepad%.axis%.") then
				local gid, axis, threshold = id:match("^gamepad%.axis%.(.+)%.(.+)%%(.+)$")
				if not gid then gid, axis = id:match("^gamepad%.axis%.(.+)%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				if axis == "rightx" then
					table.insert(ret, ("Gamepad %s right stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "right" or "left", math.abs(threshold*100)))
				elseif axis == "righty" then
					table.insert(ret, ("Gamepad %s right stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "down" or "up", math.abs(threshold*100)))
				elseif axis == "leftx" then
					table.insert(ret, ("Gamepad %s left stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "right" or "left", math.abs(threshold*100)))
				elseif axis == "lefty" then
					table.insert(ret, ("Gamepad %s left stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "down" or "up", math.abs(threshold*100)))
				else
					table.insert(ret, ("Gamepad %s axis %s (deadzone %s%%)"):format(gid, axis, math.abs(threshold*100)))
				end
			else
				table.insert(ret, id)
			end
		end
		return unpack(ret)
	end,

	axisName = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Binary axis
			if id:match(".+%,.+") then
				local b1, b2 = uqt.input.buttonName(id:match("^(.+)%,(.+)$"))
				table.insert(ret, b1.." / "..b2)
			-- Mouse movement
			elseif id:match("^mouse%.move%.") then
				local axis, threshold = id:match("^mouse%.move%.(.+)%%(.+)$")
				if not axis then axis = id:match("^mouse%.move%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Mouse %s movement (threshold %s%%)"):format(axis, math.abs(threshold*100)))
			-- Mouse position
			elseif id:match("^mouse%.position%.") then
				local axis, threshold = id:match("^mouse%.position%.(.+)%%(.+)$")
				if not axis then axis = id:match("^mouse%.position%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Mouse %s position (threshold %s%%)"):format(axis, math.abs(threshold*100)))
			-- Gamepad axis
			elseif id:match("^gamepad%.axis%.") then
				local gid, axis, threshold = id:match("^gamepad%.axis%.(.+)%.(.+)%%(.+)$")
				if not gid then gid, axis = id:match("^gamepad%.axis%.(.+)%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				if axis == "rightx" then
					table.insert(ret, ("Gamepad %s right stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "right" or "left", math.abs(threshold*100)))
				elseif axis == "righty" then
					table.insert(ret, ("Gamepad %s right stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "down" or "up", math.abs(threshold*100)))
				elseif axis == "leftx" then
					table.insert(ret, ("Gamepad %s left stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "right" or "left", math.abs(threshold*100)))
				elseif axis == "lefty" then
					table.insert(ret, ("Gamepad %s left stick %s (deadzone %s%%)"):format(gid, threshold >= 0 and "down" or "up", math.abs(threshold*100)))
				else
					table.insert(ret, ("Gamepad %s axis %s (deadzone %s%%)"):format(gid, axis, math.abs(threshold*100)))
				end
			else
				table.insert(ret, id)
			end
		end
		return unpack(ret)
	end
})

-- Defaults
uqt.input.default.pointer:bind(
	{ "absolute", "keyboard.left,keyboard.right", "keyboard.up,keyboard.down" },
	{ "absolute", "keyboard.a,keyboard.d", "keyboard.w,keyboard.s" },
	{ "absolute", "gamepad.axis.1.leftx", "gamepad.axis.1.lefty" },
	{ "absolute", "gamepad.button.1.dpleft,gamepad.button.1.dpright", "gamepad.button.1.dpup,gamepad.button.1.dpdown"}
)
uqt.input.default.confirm:bind(
	"keyboard.enter", "keyboard.space", "keyboard.lshift", "keyboard.e",
	"gamepad.button.1.a"
)
uqt.input.default.cancel:bind(
	"keyboard.escape", "keyboard.backspace",
	"gamepad.button.1.b"
)
end
