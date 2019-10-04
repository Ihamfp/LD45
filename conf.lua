function love.conf(t)
	t.identity = "S. O. Nic Adventure"             -- The name of the save directory (string)
	t.version = "11.1"                -- The LÖVE version this game was made for (string)

	t.window.title = "S. O. Nic Adventure"         -- The window title (string)
	t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
	t.window.width = 1280               -- The window width (number)
	t.window.height = 720               -- The window height (number)

	t.modules.audio = true              -- Enable the audio module (boolean)
	t.modules.event = true              -- Enable the event module (boolean)
	t.modules.graphics = true           -- Enable the graphics module (boolean)
	t.modules.image = true              -- Enable the image module (boolean)
	t.modules.joystick = true           -- Enable the joystick module (boolean)
	t.modules.keyboard = true           -- Enable the keyboard module (boolean)
	t.modules.math = true               -- Enable the math module (boolean)
	t.modules.mouse = true              -- Enable the mouse module (boolean)
	t.modules.physics = false           -- Enable the physics module (boolean)
	t.modules.sound = true              -- Enable the sound module (boolean)
	t.modules.system = true             -- Enable the system module (boolean)
	t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
	t.modules.touch = false             -- Enable the touch module (boolean)
	t.modules.video = false             -- Enable the video module (boolean)
	t.modules.window = true             -- Enable the window module (boolean)
	t.modules.thread = false            -- Enable the thread module (boolean)

	t.releases = {
		title = "S. O. Nic Adventure",       -- The project title (string)
		package = "sonicadventure-ld42",     -- The project command and package name (string)
		loveVersion = "11.1",   -- The project LÖVE version
		version = "0.1.0",        -- The project version
		author = "Reuh, Ihamfp, Trocentraisin, CelesteGranger",          -- Your name (string)
		email = "fildadut@reuh.eu",-- Your email (string)
		description = "Świętosław Ožbej Nic Adventure",-- The project description (string)
		homepage = "reuh.eu",     -- The project homepage (string)
		identifier = "eu.reuh.ld42",         -- The project Uniform Type Identifier (string)
		excludeFileList = { "%.git", "dev" },-- File patterns to exclude. (string list)
		releaseDirectory = "release", -- Where to store the project releases (string)
	}
end
