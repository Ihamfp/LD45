local input = require("ubiquitousse.input")

return {
	-- mouse pointer
	pointer = input.pointer(
			{ "absolute", input.axis("mouse.position.x"):threshold(0), input.axis("mouse.position.y"):threshold(0) },
			{ "relative", input.axis("gamepad.axis.1.leftx"):threshold(0.1), input.axis("gamepad.axis.1.lefty"):threshold(0.1) }
		):dimensions():offset():speed(1, 1),

	-- hyke moveement
	move = input.pointer(
		{ "absolute", "keyboard.left,keyboard.right", "keyboard.up,keyboard.down" },
		{ "absolute", "keyboard.a,keyboard.d", "keyboard.w,keyboard.s" },
		{ "absolute", "gamepad.button.1.dpleft,gamepad.button.1.dpright", "gamepad.button.1.dpup,gamepad.button.1.dpdown"}
	),

	unicorn = input.button("keyboard.u"),

	-- use object
	interact = input.button(
		"mouse.1", "keyboard.a", "gamepad.button.1.a"
	),

	space = input.button(
		"keyboard.space"
	),

	enter = input.button(
		"keyboard.return"
	),

	-- examine object
	examine = input.button(
		"mouse.2", "keyboard.e", "gamepad.button.1.x"
	),

	-- developper cheat code
	speedup = input.button(
		"keyboard.p"
	),

	-- inventory/QTE
	inventory = {
		input.button("keyboard.0", "keyboard.kp0"),
		input.button("keyboard.1", "keyboard.kp1"),
		input.button("keyboard.2", "keyboard.kp2"),
		input.button("keyboard.3", "keyboard.kp3"),
		input.button("keyboard.4", "keyboard.kp4"),
		input.button("keyboard.5", "keyboard.kp5"),
		input.button("keyboard.6", "keyboard.kp6"),
		input.button("keyboard.7", "keyboard.kp7"),
		input.button("keyboard.8", "keyboard.kp8"),
		input.button("keyboard.9", "keyboard.kp9")
	}
}
