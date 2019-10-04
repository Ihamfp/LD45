-- ubiquitousse.input
local uqt = require((...):match("^(.-ubiquitousse)%."))

--- Used to store inputs which were updated this frame
-- { Input: true, ... }
-- This table is for internal use and shouldn't be used from an external script.
local updated = {}

--- Input stuff
-- Inspired by Tactile by Andrew Minnich (https://github.com/tesselode/tactile).
-- I don't think I need to include the license since it's just inspiration, but for the sake of information, Tactile is under the MIT license.
-- Ubiquitousse considers two input methods, called buttons (binary input) and axes (analog input).
local input
input = {
	---------------------------------
	--- Detectors (input sources) ---
	---------------------------------

	-- Buttons detectors --
	-- A button detector is a function which returns true (pressed) or false (unpressed).
	-- Any fuction which returns a boolean can be used as a button detector, but you will probably want to get the data from an HID.
	-- Ubiquitousse being platform-agnostic, it doesn't suppose there is a keyboard and mouse available for example, and all HID buttons are identified using
	-- an identifier string, which depends of the backend. Identifier strings should be of the format "source1.source2.[...].button", for example "keyboard.up"
	-- or "gamepad.button.1.a" for the A-button of the first gamepad.
	-- If the button is actually an axis (ie, the button is pressed if the axis value passes a certain threshold), the threshold should be in the end of the
	-- identifier, preceded by a % : for example "gamepad.axis.1.leftx%-0.5" should return true when the left-stick of the first gamepad is moved to the right
	-- by more of 50%. The negative threshold value means that the button will be pressed only when the axis has a negative value (in the example, it won't be
	-- pressed when the axis is moved to the right).

	--- Makes a new button detector(s) from the identifier(s) string.
	-- The function may error if the identifier is incorrect.
	-- @tparam string button identifier, depends on the platform Ubiquitousse is running on (multiple parameters)
	-- @treturn each button detector (multiple-returns)
	-- @impl backend
	buttonDetector = function(...) end,

	-- Axis detectors --
	-- Similar to buttons detectors, but returns a number between -1 and 1.
	-- Threshold value can be used similarly with %.
	-- Axis detectors should support "binary axis", ie an axis defined by two buttons: if the 1rst button is pressed, value will be -1, if the 2nd is pressed it will be 1
	-- and if none or the both are pressed, the value will be 0. This kind of axis identifier should have an identifier like "button1,button2" (comma-separated).
	-- Axis detectors may also optionally return after the number between -1 and 1 the raw value and max value. The raw value is between -max and +max.

	--- Makes a new axis detector(s) from the identifier(s) string.
	-- @tparam string axis identifier, depends on the platform Ubiquitousse is running on (multiple parameters)
	-- @treturn each axis detector (multiple-returns)
	-- @impl backend
	axisDetector = function(...) end,

	------------------------------------------
	--- Inputs (the thing you want to use) ---
	------------------------------------------

	-- Buttons inputs --
	-- Button input is a container for buttons detector. A button will be pressed when one of its detectors returns true.
	-- Inputs also knows if the button was just pressed or released.
	-- @tparam ButtonDetectors ... all the buttons detectors or buttons identifiers
	-- @tretrun ButtonInput the object
	-- @impl ubiquitousse
	button = function(...)
		local r -- object
		local detectors = {} -- detectors list
		local state = "none" -- current state (none, pressed, down, released)
		local function update() -- update button state
			if not updated[r] then
				local down = false
				for _,d in pairs(detectors) do
					if d() then
						down = true
						break
					end
				end
				if down then
					if state == "none" or state == "released" then
						state = "pressed"
					else
						state = "down"
					end
				else
					if state == "down" or state == "pressed" then
						state = "released"
					else
						state = "none"
					end
				end
				updated[r] = true
			end
		end
		-- Object
		r = {
			--- Returns a new ButtonInput with the same properties.
			-- @treturn ButtonInput the cloned object
			clone = function(self)
				local clone = input.button()
				for name, detector in pairs(detectors) do
					if type(name) == "string" then
						clone:bind(name)
					else
						clone:bind(detector)
					end
				end
				return clone
			end,

			--- Bind new ButtonDetector(s) to this input.
			-- @tparam ButtonDetectors ... buttons detectors or buttons identifiers to add
			-- @treturn ButtonInput this ButtonInput object
			bind = function(self, ...)
				for _,d in ipairs({...}) do
					if type(d) == "string" then
						detectors[d] = input.buttonDetector(d)
					elseif type(d) == "function" then
						detectors[d] = d
					else
						error("Not a valid button detector")
					end
				end
				return self
			end,
			--- Unbind ButtonDetector(s).
			-- @tparam ButtonDetectors ... buttons detectors or buttons identifiers to remove
			-- @treturn ButtonInput this ButtonInput object
			unbind = function(self, ...)
				for _,d in ipairs({...}) do
					detectors[d] = nil
				end
				return self
			end,

			--- Returns true if the input was just pressed.
			-- @treturn boolean true if the input was pressed, false otherwise
			pressed = function(self)
				update()
				return state == "pressed"
			end,
			--- Returns true if the input is down.
			-- @treturn boolean true if the input is currently down, false otherwise
			down = function(self)
				update()
				return state == "down" or state == "pressed"
			end,
			--- Returns true if the input was just released.
			-- @treturn boolean true if the input was released, false otherwise
			released = function(self)
				update()
				return state == "released"
			end,
		}
		r:bind(...)
		return r
	end,

	-- Axis inputs --
	-- Axis input is a container for axes detector. An axis input will return the value of the axis detector the most far away from their center (0).
	-- Axis input provide a threshold setting ; every axis which has a distance to the center below th threshold will be ignored.
	-- @tparam AxisDetectors ... all the axis detectors or axis identifiers
	-- @tretrun AxisInput the object
	-- @impl ubiquitousse
	axis = function(...)
		local r -- object
		local detectors = {} -- detectors list
		local value, raw, max = 0, 0, 1 -- current value between -1 and 1, raw value between -max and +max and maximum for raw values
		local threshold = 0.5 -- ie., the deadzone
		local function update() -- update axis state
			if not updated[r] then
				value = 0
				for _,d in pairs(detectors) do
					local v, r, m = d() -- v[-1,1], r[-m,+m]
					if math.abs(v) > math.abs(value) then
						value, raw, max = v, r or v, m or 1
					end
				end
				updated[r] = true
			end
		end
		-- Object
		r = {
			--- Returns a new AxisInput with the same properties.
			-- @treturn AxisInput the cloned object
			clone = function(self)
				local clone = input.axis()
				for name, detector in pairs(detectors) do
					if type(name) == "string" then
						clone:bind(name)
					else
						clone:bind(detector)
					end
				end
				clone:threshold(threshold)
				return clone
			end,

			--- Bind new AxisDetector(s) to this input.
			-- @tparam AxisDetectors ... axis detectors or axis identifiers to add
			-- @treturn AxisInput this AxisInput object
			bind = function(self, ...)
				for _,d in ipairs({...}) do
					if type(d) == "string" then
						detectors[d] = input.axisDetector(d)
					elseif type(d) == "function" then
						detectors[d] = d
					else
						error("Not a valid axis detector")
					end
				end
				return self
			end,
			--- Unbind AxisDetector(s).
			-- @tparam AxisDetectors ... axis detectors or axis identifiers to remove
			-- @treturn AxisInput this AxisInput object
			unbind = function(self, ...)
				for _,d in ipairs({...}) do
					detectors[d] = nil
				end
				return self
			end,

			--- Sets the default detection threshold (deadzone).
			-- @tparam number new the new detection threshold
			-- @treturn AxisInput this AxisInput object
			threshold = function(self, new)
				threshold = tonumber(new)
				return self
			end,

			--- Returns the value of the input (between -1 and 1).
			-- @tparam[opt=default threshold] number threshold value to use
			-- @treturn number the input value
			value = function(self, curThreshold)
				update()
				return math.abs(value) > math.abs(curThreshold or threshold) and value or 0
			end,
			--- Returns the raw value of the input (between -max and +max).
			-- @tparam[opt=default threshold*max] number raw threshold value to use
			-- @treturn number the input raw value
			raw = function(self, rawThreshold)
				update()
				return math.abs(raw) > math.abs(rawThreshold or threshold*max) and raw or 0
			end,
			--- Return the raw max of the input.
			-- @treturn number the input raw max
			max = function(self)
				update()
				return max
			end,

			--- The associated button pressed when the axis reaches a positive value.
			positive = input.button(function() return r:value() > 0 end),
			--- The associated button pressed when the axis reaches a negative value.
			negative = input.button(function() return r:value() < 0 end)
		}
		r:bind(...)
		return r
	end,

	-- Pointer inputs --
	-- Pointer inputs are container for two axes input, in order to represent a two-dimensionnal pointing device, e.g. a mouse or a stick.
	-- Each pointer detector is a table with 3 fields: mode(string), XAxis(axis), YAxis(axis). mode can either be "relative" or "absolute".
	-- In relative mode, the pointer will return the movement since last update (for example to move a mouse pointer with a stick).
	-- In absolute mode, the pointer will return the pointer position directly deduced of the current axes position.
	-- @tparam table{mode,XAxis,YAxis} ... couples of axis detectors, axis identifiers or axis input to add and in which mode
	-- @tretrun PointerInput the object
	-- @impl ubiquitousse
	pointer = function(...)
		local draw = uqt.draw -- requires width and height
		local pointers = {} -- pointers list
		local x, y = 0, 0 -- pointer position
		local width, height = 1, 1 -- half-dimensions of the movement area
		local offsetX, offsetY = 0, 0 -- offsets
		local xSpeed, ySpeed = 1, 1 -- speed (pixels/milisecond); for relative mode
		local r -- object
		local function update()
			if not updated[r] then
				local width, height = width or draw.width/2, height or draw.height/2
				local newX, newY = x, y
				local maxMovX, maxMovY = 0, 0 -- the maxium axis movement in a direction (used to determine which axes have the priority) (absolute value)
				for _, pointer in ipairs(pointers) do
					local mode, xAxis, yAxis = unpack(pointer)
					if mode == "relative" then
						local movX, movY = math.abs(xAxis:value()), math.abs(yAxis:value())
						if movX > maxMovX then
							newX = x + (xSpeed and (xAxis:value() * xSpeed * uqt.time.dt) or xAxis:raw())
							maxMovX = movX
						end
						if movY > maxMovY then
							newY = y + (ySpeed and (yAxis:value() * ySpeed * uqt.time.dt) or yAxis:raw())
							maxMovY = movY
						end
					elseif mode == "absolute" then
						if not pointer.previous then pointer.previous = { x = xAxis:value(), y = yAxis:value() } end -- last frame position (to calculate movement/delta)
						local movX, movY = math.abs(xAxis:value() - pointer.previous.x), math.abs(yAxis:value() - pointer.previous.y)
						pointer.previous = { x = xAxis:value(), y = yAxis:value() }
						if movX > maxMovX then
							newX = xAxis:value() * width
							maxMovX = movX
						end
						if movY > maxMovY then
							newY = yAxis:value() * height
							maxMovY = movY
						end
					end
				end
				x, y = math.min(math.abs(newX), width) * (newX < 0 and -1 or 1), math.min(math.abs(newY), height) * (newY < 0 and -1 or 1)
				updated[r] = true
			end
		end
		r = {
			--- Returns a new PointerInput with the same properties.
			-- @treturn PointerInput the cloned object
			clone = function(self)
				return input.pointer(unpack(pointers))
				       :dimensions(width, height)
				       :offset(offsetX, offsetY)
				       :speed(xSpeed, ySpeed)
			end,

			--- Bind new axis couples to this input.
			-- @tparam table{mode,XAxis,YAxis} ... couples of axis detectors, axis identifiers or axis input to add and in which mode
			-- @treturn PointerInput this PointerInput object
			bind = function(self, ...)
				for _,p in ipairs({...}) do
					if type(p) == "table" then
						if type(p[2]) == "string" then p[2] = input.axis(input.axisDetector(p[2])) end
						if type(p[3]) == "string" then p[3] = input.axis(input.axisDetector(p[3])) end
						table.insert(pointers, p)
					else
						error("Pointer must be a table")
					end
				end
				return self
			end,
			--- Unbind axis couples.
			-- @tparam table{mode,XAxis,YAxis} ... couples of axis detectors, axis identifiers or axis input to remove
			-- @treturn PointerInput this PointerInput object
			unbind = function(self, ...)
				for _,p in ipairs({...}) do
					for i,pointer in ipairs(pointers) do
						if pointer == p then
							table.remove(pointers, i)
							break
						end
					end
				end
				return self
			end,

			--- Set the moving area half-dimensions.
			-- Call without argument to use half the window dimensions.
			-- It's the half dimensions because axes values goes from -1 to 1, so theses dimensions only
			-- covers values from x=0,y=0 to x=1,y=1. The full moving area will be 4*newWidth*newHeight.
			-- @tparam number newWidth new width
			-- @tparam number newHeight new height
			-- @treturn PointerInput this PointerInput object
			dimensions = function(self, newWidth, newHeight)
				width, height = newWidth, newHeight
				return self
			end,
			--- Set the moving area coordinates offset.
			-- The offset is a value automatically added to the x and y values when using the x() and y() methods.
			-- Call without argument to automatically offset so 0,0 <= x(),y() <= width,height, i.e. offset to width,height.
			-- @tparam number newOffX new X offset
			-- @tparam number newOffY new Y offset
			-- @treturn PointerInput this PointerInput object
			offset = function(self, newOffX, newOffY)
				offsetX, offsetY = newOffX, newOffY
				return self
			end,
			--- Set maximal speed (pixels-per-milisecond)
			-- Only used in relative mode.
			-- Calls without argument to use the raw data and don't apply a speed modifier.
			-- @tparam number newXSpeed new X speed
			-- @tparam number newYSpeed new Y speed
			-- @treturn PointerInput this PointerInput object
			speed = function(self, newXSpeed, newYSpeed)
				xSpeed, ySpeed = newXSpeed, newYSpeed or newXSpeed
				return self
			end,

			--- Returns the current X value of the pointer.
			-- @treturn number X value
			x = function()
				update()
				return x + (offsetX or width or draw.width/2)
			end,
			--- Returns the current Y value of the pointer.
			-- @treturn number Y value
			y = function()
				update()
				return y + (offsetY or height or draw.height/2)
			end,

			--- The associated horizontal axis.
			horizontal = input.axis(function()
				local h = r:x()
				return h/width, h, width
			end),
			--- The associated vertical axis.
			vertical = input.axis(function()
				local v = r:y()
				return v/height, v, height
			end),

			--- The associated button pressed when the pointer goes to the right.
			right = nil,
			--- The associated button pressed when the pointer goes to the left.
			left = nil,
			--- The associated button pressed when the pointer points up.
			up = nil,
			--- The associated button pressed when the pointer points down.
			down = nil
		}
		r.right, r.left = r.horizontal.positive, r.horizontal.negative
		r.up, r.down = r.vertical.negative, r.vertical.positive
		r:bind(...)
		return r
	end,

	------------------------------
	--- Input detection helpers --
	------------------------------

	--- Returns a list of the buttons currently in use, identified by their string button identifier.
	-- This may also returns "axis threshold" buttons if an axis passes the threshold.
	-- @treturn table<string> buttons identifiers list
	-- @treturn[opt=0.5] number threshold the threshold to detect axes as button
	-- @impl backend
	buttonsInUse = function(threshold) end,

	--- Returns a list of the axes currently in use, identified by their string axis identifier
	-- @treturn table<string> axes identifiers list
	-- @treturn[opt=0.5] number threshold the threshold to detect axes
	-- @impl backend
	axesInUse = function(threshold) end,

	--- Returns a nice name for the button identifier.
	-- Can be locale-depedant and stuff, it's only for display.
	-- May returns the raw identifier if you're lazy.
	-- @tparam string... button identifier string(s)
	-- @treturn string... the displayable names
	-- @impl backend
	buttonName = function(...) end,

	--- Returns a nice name for the axis identifier.
	-- Can be locale-depedant and stuff, it's only for display.
	-- May returns the raw identifier if you're lazy.
	-- @tparam string... axis identifier string(s)
	-- @treturn string... the displayable names
	-- @impl backend
	axisName = function(...) end,

	-------------------
	--- Other stuff ---
	-------------------

	--- Some default inputs.
	-- The backend should bind detectors to thoses inputs.
	-- These are used to provide some common input default detectors to allow to start a game quickly on
	-- any platform without having to configure the keys.
	-- If some key function in your game match one of theses defaults, using it instead of creating a new
	-- input would be a good idea.
	-- @impl mixed
	default = {
		pointer = nil, -- Pointer: used to move and select. Example binds: arrow keys, WASD, stick.
		confirm = nil, -- Button: used to confirm something. Example binds: Enter, A button.
		cancel = nil -- Button: used to cancel something. Example binds: Escape, B button.
	},

	--- Update all the Inputs.
	-- Supposed to be called in ubiquitousse.event.update.
	-- The backend can hook into this function to to its input-related updates.
	-- @tparam numder dt the delta-time
	-- @impl ubiquitousse
	update = function(dt)
		updated = {}
	end
}

-- Create default inputs
input.default.pointer = input.pointer()
input.default.confirm = input.button()
input.default.cancel = input.button()

-- TODO: some key selection helper? Will be backend-implemented, to account for all the possible input methods.
-- TODO: some way to list all possible input / outputs, or make the *inUse make some separation between inputs indiscutitably in use and those who are incertain.
-- TODO: outputs ! (rumble, lights, I don't know)
-- TODO: other, optional, default/generic inputs, and a way to know if they are binded.
-- TODO: multiplayer input helpers? something like getting the same input for different players, or default inputs for different players

return input
