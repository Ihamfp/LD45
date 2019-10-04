-- ubiquitousse.event
local uqt = require((...):match("^(.-ubiquitousse)%."))
local m = uqt.module

--- The events: callback functions that will be called when something interesting occurs.
-- Theses are expected to be redefined in the game.
-- For backend writers: if they already contain code, then this code has to be called on each call, even
-- if the user manually redefines them.
-- @usage -- in the game's code
-- ubiquitousse.event.draw = function()
--   ubiquitousse.draw.text(5, 5, "Hello world")
-- end
return {
	--- Called each time the game loop is ran. Don't draw here.
	-- @tparam number dt time since last call, in miliseconds
	-- @impl mixed
	update = function(dt)
		if m.input then uqt.input.update(dt) end
		if m.time then uqt.time.update(dt) end
		if m.scene then uqt.scene.update(dt) end
	end,

	--- Called each time the game expect a new frame to be drawn.
	-- The screen is expected to be cleared since last frame.
	-- @impl backend
	draw = function()
		if m.scene then uqt.scene.draw() end
	end
}
