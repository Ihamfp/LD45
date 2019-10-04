-- ubiquitousse

--- Ubiquitousse Game Engine.
-- Main module, containing the main things.
-- The API exposed here is the Ubiquitousse API.
-- It is as the name does not imply anymore abstract, and must be implemented in a backend, such as ubiquitousse.love.
-- When required, this file will try to autodetect the engine it is running on, and load a correct backend.
--
-- Ubiquitousse may or may not be used as a full game engine. You can delete the modules files you don't need and Ubiquitousse
-- should adapt accordingly.
--
-- For backend writers:
-- If a function defined here already contains some code, this means this code is mandatory and you must put/call
-- it in your implementation (except if the backend provides a more efficient implementation).
-- Also, a backend file shouldn't redefine the ubiquitousse table itself but only redefine the backend-dependant fields.
-- Lua 5.3: The API doesn't make the difference between numbers and integers, so convert to integers when needed.
--
-- For game writer:
-- Ubiquitousse works with Lua 5.1 to 5.3, including LuaJit, but doesn't provide any version checking or compatibility layer
-- between the different versions, so it's up to you to handle that in your game (or ignore the problem and sticks to your
-- main's backend Lua version).
--
-- Ubiquitousse's goal is to run everywhere with the least porting effort possible.
-- To achieve this, the engine needs to stay simple, and only provide features that are almost sure to be
-- available everywhere, so writing a backend should be straighforward.
--
-- However, a full Ubiquitousse backend still have a few requirement about the destination platform:
-- * The backend needs to have access to some kind of main loop, or at least a function called very often (may or may not be the
--   same as the redraw screen callback).
-- * A 2D matrix graphic output with 32bit RGB color depth.
-- * Inputs which match ubiquitousse.input.default (a pointing/4 direction input, a confirm button, and a cancel button).
-- * Some way of measuring time with millisecond-precision.
-- * Some kind of filesystem.
-- * An available audio output would be preferable but optional.
-- * Lua 5.1, 5.2, 5.3 or LuaJit.
--
-- Regarding data formats, Ubiquitousse implementations expect and recommend:
-- * For images, PNG support is expected.
-- * For audio files, OGG Vorbis support is expected.
-- * For fonts, TTF support is expected.
-- Theses formats are respected for the reference implementations, but Ubiquitousse may provide a script to
-- automatically convert data formats from a project at some point.
--
-- Units used in the API:
-- * All distances are expressed in pixels (px)
-- * All durations are expressed in milliseconds (ms)
--
-- Style:
-- * tabs for indentation, spaces for esthetic whitespace (notably in comments)
-- * no globals
-- * UPPERCASE for constants (or maybe not).
-- * CamelCase for class names.
-- * lowerCamelCase is expected for everything else.
--
-- Implementation levels:
-- * backend: nothing defined in Ubiquitousse, must be implemented in backend
-- * mixed: partly implemented in Ubiquitousse but must be complemeted in backend
-- * ubiquitousse: fully-working version in Ubiquitousse, may or may not be redefined in backend
-- The implementation level is indicated using the "@impl level" annotation.
--
-- Some Ubiquitousse modules require parts of other modules to work. Because every module should work when all the others are
-- disabled, the backend may need to provide defaults values for a few fields in disabled modules required by an enabled one.
-- Thoses fields are indicated with "@requiredby module" annotations.
--
-- Regarding the documentation: Ubiquitousse used LDoc/LuaDoc styled-comments, but since LDoc hates me and my code, the
-- generated result is complete garbage, so please read the documentation directly in the comments here.
-- Stuff you're interested in starts with triple - (e.g., "--- This functions saves the world").
--
-- @usage local ubiquitousse = require("ubiquitousse")

local p = ... -- require path
local ubiquitousse

ubiquitousse = {
	--- Ubiquitousse version.
	-- @impl ubiquitousse
	version = "0.0.1",

	--- Table of enabled modules.
	-- @impl ubiquitousse
	module = {
		time = false,
		draw = false,
		audio = false,
		input = false,
		scene = false,
		event = false
	},

	--- Backend name.
	-- For consistency, only use lowercase letters [a-z] (no special char)
	-- @impl backend
	backend = "unknown"
}

-- We're going to require modules requiring Ubiquitousse, so to avoid stack overflows we already register the ubiquitousse package
package.loaded[p] = ubiquitousse

-- Require external submodules
for m in pairs(ubiquitousse.module) do
	local s, t = pcall(require, p.."."..m)
	if s then
		ubiquitousse[m] = t
		ubiquitousse.module[m] = true
	end
end

-- Backend engine autodetect and load
if love then
	require(p..".backend.love")
elseif package.loaded["ctr"] then
	require(p..".backend.ctrulua")
elseif package.loaded["libretro"] then
	error("NYI")
end

return ubiquitousse
