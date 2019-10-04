-- ubiquitousse.scene
local uqt = require((...):match("^(.-ubiquitousse)%."))
local m = uqt.module

--- Scene management.
-- You can use use scenes to seperate the different states of your game: for example, a menu scene and a game scene.
-- This module is fully implemented in Ubiquitousse and is mostly a "recommended way" of organising an Ubiquitousse-based game.
-- However, you don't have to use this if you don't want to. ubiquitousse.scene handles all the differents Ubiquitousse-states and
-- make them scene-independent, for example by creating a scene-specific TimerRegistry (TimedFunctions that are keept accross
-- states are generally a bad idea). Theses scene-specific states should be created and available in the table returned by
-- ubiquitousse.scene.new.
-- Currently, the implementation always execute a scene's file before switching to it or adding it to the stack, but this may change in
-- the future or for some implementations (e.g., on a computer where memory isn't a problem, the scene may be put in a cache). The result
-- of this is that you can load assets, libraries, etc. outside of the enter callback, so they can be cached and not reloaded each time
-- the scene is entered, but all the other scene initialization should be done in the enter callback, since it won't be executed on
-- each enter otherwise.
-- The expected code-organisation is:
-- * each scene is in a file, identified by its module name (same identifier used by Lua's require)
-- * each scene file create a new scene table using ubiquitousse.scene.new and returns it at the end of the file
-- Order of callbacks:
-- * all scene change callbacks are called after setting scene.current to the new scene but before changing scene.stack
-- * all scene exit/suspend callbacks are called before scene enter/resume callbacks
local scene
scene = {
	--- The current scene table.
	-- @impl ubiquitousse
	current = nil,

	--- The scene stack: list of scene, from the farest one to the nearest.
	-- @impl ubiquitousse
	stack = {},

	--- A prefix for scene modules names
	-- @impl ubiquitousse
	prefix = "",

	--- Function which load a scene file
	-- @impl ubiquitousse
	load = function(scenePath)
		for path in package.path:gmatch("[^;]+") do
			path = path:gsub("%?", (scenePath:gsub("%.", "/")))
			local f = io.open(path)
			if f then
				f:close()
				return dofile(path)
			end
		end
		error("can't find scene "..tostring(scenePath))
	end,

	--- Creates and returns a new Scene object.
	-- @tparam[opt="unamed"] string name the new scene name
	-- @impl ubiquitousse
	new = function(name)
		return {
			name = name or "unamed", -- The scene name.

			time = m.time and uqt.time.new(), -- Scene-specific TimerRegistry, if uqt.time is enabled.

			enter = function(self, ...) end, -- Called when entering a scene.
			exit = function(self) end, -- Called when exiting a scene, and not expecting to come back (scene may be unloaded).

			suspend = function(self) end, -- Called when suspending a scene, and expecting to come back (scene won't be unloaded).
			resume = function(self) end, -- Called when resuming a suspended scene (after calling suspend).

			update = function(self, dt, ...) end, -- Called on each ubiquitousse.event.update on the current scene.
			draw = function(self, ...) end -- Called on each ubiquitousse.event.draw on the current scene.
		}
	end,

	--- Switch to a new scene.
	-- The new scene will be loaded and the current scene will be replaced by the new one,
	-- then the previous scene exit function will be called, then the enter callback is called on the new scence.
	-- Then the stack is changed to replace the old scene with the new one.
	-- @tparam string scenePath the new scene module name
	-- @param ... arguments to pass to the scene's enter function
	-- @impl ubiquitousse
	switch = function(scenePath, ...)
		local previous = scene.current
		scene.current = scene.load(scene.prefix..scenePath)
		scene.current.name = scenePath
		if previous then previous:exit() end
		scene.current:enter(...)
		scene.stack[math.max(#scene.stack, 1)] = scene.current
	end,

	--- Push a new scene to the scene stack.
	-- Similar to ubiquitousse.scene.switch, except suspend is called on the current scene instead of exit,
	-- and the current scene is not replaced: when the new scene call ubiquitousse.scene.pop, the old scene
	-- will be reused.
	-- @tparam string scenePath the new scene module name
	-- @param ... arguments to pass to the scene's enter function
	-- @impl ubiquitousse
	push = function(scenePath, ...)
		local previous = scene.current
		scene.current = scene.load(scene.prefix..scenePath)
		scene.current.name = scenePath
		if previous then previous:suspend() end
		scene.current:enter(...)
		table.insert(scene.stack, scene.current)
	end,

	--- Pop the current scene from the scene stack.
	-- The previous scene will be set as the current scene, then the current scene exit function will be called,
	-- then the previous scene resume function will be called, and then the current scene will be removed from the stack.
	-- @impl ubiquitousse
	pop = function()
		local previous = scene.current
		scene.current = scene.stack[#scene.stack-1]
		if previous then previous:exit() end
		if scene.current then scene.current:resume() end
		table.remove(scene.stack)
	end,

	--- Update the current scene.
	-- Should be called in ubiquitousse.event.update.
	-- @tparam number dt the delta-time (milisecond)
	-- @param ... arguments to pass to the scene's update function after dt
	-- @impl ubiquitousse
	update = function(dt, ...)
		if scene.current then
			if m.time then scene.current.time.update(dt) end
			scene.current:update(dt, ...)
		end
	end,

	--- Draw the current scene.
	-- Should be called in ubiquitousse.event.draw.
	-- @param ... arguments to pass to the scene's draw function
	-- @impl ubiquitousse
	draw = function(...)
		if scene.current then scene.current:draw(...) end
	end
}

return scene
