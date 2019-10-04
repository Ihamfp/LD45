--- ctrµLua backend 0.0.1 for Ubiquitousse.
-- Provides a partial Ubiquitousse API. Still a lot to implement.
-- Made for some ctrµLua version and Ubiquitousse 0.0.1.
-- See `ubiquitousse` for Ubiquitousse API.

-- General
local version = "0.0.1"

-- Require stuff
local uqt = require((...):match("^(.-ubiquitousse)%."))
local ctr = require("ctr")
local gfx = require("ctr.gfx")
local hid = require("ctr.hid")

-- Version compatibility warning
do
	local function checkCompat(stuffName, expectedVersion, actualVersion)
		if actualVersion ~= expectedVersion then
			local txt = ("Ubiquitousse ctrµLua backend version "..version.." was made for %s %s but %s is used!\nThings may not work as expected.")
			            :format(stuffName, expectedVersion, actualVersion)
			print(txt)
			for _=0,300 do
				gfx.start(gfx.TOP)
					gfx.wrappedText(0, 0, txt, gfx.TOP_WIDTH)
				gfx.stop()
				gfx.render()
			end
		end
	end
	checkCompat("ctrµLua", "v1.0", ctr.version) -- not really a version, just get the latest build
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
uqt.backend = "ctrulua"

-- uqt.event: TODO
if uqt.event then
	error("uqt.event: NYI")
end

-- uqt.draw: TODO
if uqt.draw then
	error("uqt.draw: NYI")
end

-- uqt.audio: TODO
if uqt.audio then
	error("uqt.audio: NYI")
end

-- uqt.time
if uqt.time then
add(uqt.time, {
	get = ctr.time
})
end

-- uqt.input
if uqt.input then
local keys = {}
local touchX, touchY, dTouchX, dTouchY
add(uqt.input, {
	update = function()
		hid.read()

		keys = hid.keys()

		local nTouchX, nTouchY = hid.touch()
		dTouchX, dTouchY = nTouchX - touchX, nTouchY - touchY
		touchX, touchY = nTouchX, nTouchY
	end,

	buttonDetector = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Keys
			if id:match("^key%.") then
				local key = id:match("^key%.(.+)$")
				table.insert(ret, function()
					return keys.held[key]
				end)
			else
				error("Unknown button identifier: "..id)
			end
		end
		return table.unpack(ret)
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
			-- Touch movement
			elseif id:match("^touch%.move%.") then
				local axis, threshold = id:match("^touch%.move%.(.+)%%(.+)$")
				if not axis then axis = id:match("^touch%.move%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local val, raw, max
					if axis == "x" then
						raw, max = dTouchX, gfx.BOTTOM_WIDTH
					elseif axis == "y" then
						raw, max = dTouchY, gfx.BOTTOM_HEIGHT
					end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Touch position
			elseif id:match("^touch%.position%.") then
				local axis, threshold = id:match("^touch%.position%.(.+)%%(.+)$")
				if not axis then axis = id:match("^touch%.position%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local val, raw, max
					if axis == "x" then
						max = gfx.BOTTOM_WIDTH / 2 -- /2 because x=0,y=0 is the center of the screen (an axis value is in [-1,1])
						raw = touchX - max
					elseif axis == "y" then
						max = gfx.BOTTOM_HEIGHT / 2
						raw = touchY - max
					end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Circle pad axis
			elseif id:match("^circle%.") then
				local axis, threshold = id:match("^circle%.(.+)%%(.+)$")
				if not axis then axis = id:match("^circle%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local x, y = hid.circle()
					local val, raw, max = 0, 0, 156
					if axis == "x" then raw = x
					elseif axis == "y" then raw = y end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- C-Stick axis
			elseif id:match("^cstick%.") then
				local axis, threshold = id:match("^cstick%.(.+)%%(.+)$")
				if not axis then axis = id:match("^cstick%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local x, y = hid.cstick()
					local val, raw, max = 0, 0, 146
					if axis == "x" then raw = x
					elseif axis == "y" then raw = y end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Accelerometer axis
			elseif id:match("^accel%.") then
				local axis, threshold = id:match("^accel%.(.+)%%(.+)$")
				if not axis then axis = id:match("^accel%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local x, y, z = hid.accel()
					local val, raw, max = 0, 0, 32768 -- no idea actually, but it's a s16
					if axis == "x" then raw = x
					elseif axis == "y" then raw = y
					elseif axis == "z" then raw = z end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			-- Gyroscope axis
			elseif id:match("^gyro%.") then
				local axis, threshold = id:match("^gyro%.(.+)%%(.+)$")
				if not axis then axis = id:match("^gyro%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, function()
					local roll, pitch, yaw = hid.gyro()
					local val, raw, max = 0, 0, 32768 -- no idea actually, but it's a s16
					if axis == "roll" then raw = roll
					elseif axis == "pitch" then raw = pitch
					elseif axis == "yaw" then raw = yaw end
					val = raw / max
					return math.abs(val) > math.abs(threshold) and val or 0, raw, max
				end)
			else
				error("Unknown axis identifier: "..id)
			end
		end
		return table.unpack(ret)
	end,

	buttonsInUse = function(threshold)
		local r = {}
		for key, held in pairs(keys.held) do
			if held then table.insert(r, "key."..key) end
		end
		return r
	end,

	axesInUse = function(threshold)
		local r = {}
		threshold = threshold or 0.5

		if math.abs(touchX) / gfx.BOTTOM_WIDTH > threshold then table.insert(r, "touch.position.x%"..threshold) end
		if math.abs(touchY) / gfx.BOTTOM_HEIGHT > threshold then table.insert(r, "touch.position.y%"..threshold) end

		if math.abs(dTouchX) / gfx.BOTTOM_WIDTH > threshold then table.insert(r, "touch.move.x%"..threshold) end
		if math.abs(dTouchY) / gfx.BOTTOM_HEIGHT > threshold then table.insert(r, "touch.move.y%"..threshold) end

		local circleX, circleY = hid.circle()
		if math.abs(circleX) / 156 > threshold then table.insert(r, "circle.x%"..threshold) end
		if math.abs(circleY) / 156 > threshold then table.insert(r, "circle.y%"..threshold) end

		if ctr.apt.isNew3DS() then
			local cstickX, cstickY = hid.cstick()
			if math.abs(cstickY) / 146 > threshold then table.insert(r, "cstick.y%"..threshold) end
			if math.abs(cstickX) / 146 > threshold then table.insert(r, "cstick.x%"..threshold) end
		end

		local accelX, accelY, accelZ = hid.accel()
		if math.abs(accelX) / 32768 > threshold then table.insert(r, "accel.x%"..threshold) end
		if math.abs(accelY) / 32768 > threshold then table.insert(r, "accel.y%"..threshold) end
		if math.abs(accelZ) / 32768 > threshold then table.insert(r, "accel.z%"..threshold) end

		-- no gyro, because it is always in use

		return r
	end,

	buttonName = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Key
			if id:match("^key%.") then
				local key = id:match("^key%.(.+)$")
				table.insert(ret, key:sub(1,1):upper()..key:sub(2).." key")
			else
				table.insert(ret, id)
			end
		end
		return table.unpack(ret)
	end,

	axisName = function(...)
		local ret = {}
		for _,id in ipairs({...}) do
			-- Binary axis
			if id:match(".+%,.+") then
				local b1, b2 = uqt.input.buttonName(id:match("^(.+)%,(.+)$"))
				table.insert(ret, b1.." / "..b2)
			-- Touch movement
			elseif id:match("^touch%.move%.") then
				local axis, threshold = id:match("^touch%.move%.(.+)%%(.+)$")
				if not axis then axis = id:match("^touch%.move%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Touch %s movement (threshold %s%%)"):format(axis, math.abs(threshold*100)))
			-- Touch position
			elseif id:match("^touch%.position%.") then
				local axis, threshold = id:match("^touch%.position%.(.+)%%(.+)$")
				if not axis then axis = id:match("^touch%.position%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Touch %s position (threshold %s%%)"):format(axis, math.abs(threshold*100)))
			-- Circle pad axis
			elseif id:match("^circle%.") then
				local axis, threshold = id:match("^circle%.(.+)%%(.+)$")
				if not axis then axis = id:match("^circle%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				if axis == "x" then
					table.insert(ret, ("Circle pad horizontal axis (deadzone %s%%)"):format(math.abs(threshold*100)))
				elseif axis == "y" then
					table.insert(ret, ("Circle pad vertical axis (deadzone %s%%)"):format(math.abs(threshold*100)))
				else
					table.insert(ret, ("Circle pad %s axis (deadzone %s%%)"):format(axis, math.abs(threshold*100)))
				end
			-- C-Stick axis
			elseif id:match("^cstick%.") then
				local axis, threshold = id:match("^cstick%.(.+)%%(.+)$")
				if not axis then axis = id:match("^cstick%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				if axis == "x" then
					table.insert(ret, ("C-Stick horizontal axis (deadzone %s%%)"):format(math.abs(threshold*100)))
				elseif axis == "y" then
					table.insert(ret, ("C-Stick vertical axis (deadzone %s%%)"):format(math.abs(threshold*100)))
				else
					table.insert(ret, ("C-Stick %s axis (deadzone %s%%)"):format(axis, math.abs(threshold*100)))
				end
			-- Accelerometer axis
			elseif id:match("^accel%.") then
				local axis, threshold = id:match("^accel%.(.+)%%(.+)$")
				if not axis then axis = id:match("^accel%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Accelerometer %s axis (deadzone %s%%)"):format(axis, math.abs(threshold*100)))
			-- Gyroscope axis
			elseif id:match("^gyro%.") then
				local axis, threshold = id:match("^gyro%.(.+)%%(.+)$")
				if not axis then axis = id:match("^gyro%.(.+)$") end -- no threshold (=0)
				threshold = tonumber(threshold) or 0
				table.insert(ret, ("Gyroscope %s axis (deadzone %s%%)"):format(axis, math.abs(threshold*100)))
			else
				table.insert(ret, id)
			end
		end
		return table.unpack(ret)
	end
})

-- Defaults
uqt.input.default.pointer:bind(
	{ "absolute", "key.left,key.right", "key.up,key.down" },
	{ "absolute", "circle.x", "circle.y" }
)
uqt.input.default.confirm:bind("key.a")
uqt.input.default.cancel:bind("key.b")
end
