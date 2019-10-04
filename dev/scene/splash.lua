local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")

local Text = require("entity.text")
local gong = love.audio.newSource("asset/audio/badaboum.ogg", "static")

local splash = scene.new("splash")
entities.reset(splash)

-- ENTITIES

local t1  = Text:new("LemonMilk.otf", 32, "Reuh, Ihamfp, and Trocentraisin", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})
local t2  = Text:new("LemonMilk.otf", 20, "present", love.graphics.getWidth()/2, love.graphics.getHeight()/2+30, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

local t3  = Text:new("LemonMilk.otf", 50, "A\n\ngame", 0, love.graphics.getHeight()/2, {
	limit = 1280,
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})
local t4  = Text:new("LemonMilk.otf", 65, "stupid", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

local t5  = Text:new("LemonMilk.otf", 50, "Made by\n\npeople", 0, love.graphics.getHeight()/2, {
	limit = 1280,
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})
local t6  = Text:new("LemonMilk.otf", 65, "stupid", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

local t7  = Text:new("LemonMilk.otf", 50, "For\n\npeople", 0, love.graphics.getHeight()/2, {
	limit = 1280,
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})
local t8  = Text:new("LemonMilk.otf", 72, "exceptional", love.graphics.getWidth()/2, love.graphics.getHeight()/2, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

local t9  = Text:new("LemonMilk.otf", 85, "ULTIMATE PROSELYTISM & MIRACLES SIMULATOR 2017: THE MOVIE THE GAME", 0, love.graphics.getHeight()/2, {
	limit = 1280,
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

-- SCRIPT

splash.time.tween(1500, t1, {
	color = { 255, 255, 255, 255 }
}, "outExpo"):after(500)
:chain(700, t2, {
	color = { 255, 255, 255, 255 }
}, "outExpo")
:onEnd(function()
	splash.time.tween(500, t1, {
		color = { 255, 255, 255, 0 }
	}, "inExpo")
	splash.time.tween(500, t2, {
		color = { 255, 255, 255, 0 }
	}, "inExpo")
	:chain(1000, t3, {
		color = { 255, 255, 255, 255 }
	}, "outQuad"):after(500)
	:chain(700, t4, {
		color = { 255, 255, 255, 255 }
	})
	:onEnd(function()
		splash.time.tween(500, t3, {
			color = { 255, 255, 255, 0 }
		}, "inQuad")
		splash.time.tween(500, t4, {
			color = { 255, 255, 255, 0 }
		}, "inQuad")
		:chain(1000, t5, {
			color = { 255, 255, 255, 255 }
		}, "outQuad"):after(500)
		:chain(700, t6, {
			color = { 255, 255, 255, 255 }
		}):onEnd(function()
			splash.time.tween(500, t5, {
				color = { 255, 255, 255, 0 }
			}, "inQuad")
			splash.time.tween(500, t6, {
				color = { 255, 255, 255, 0 }
			}, "inQuad")
			:chain(1000, t7, {
				color = { 255, 255, 255, 255 }
			}, "outQuad"):after(500)
			:chain(700, t8, {
				color = { 255, 255, 255, 255 }
			}):onEnd(function()
				splash.time.tween(500, t7, {
					color = { 255, 255, 255, 0 }
				}, "inQuad")
				splash.time.tween(500, t8, {
					color = { 255, 255, 255, 0 }
				}, "inQuad")
				:chain(2000, t9, {
					color = { 255, 255, 255, 255 }
				}, "outExpo"):after(1000)
				:chain(1500, {
					color = { 255, 255, 255, 0 }
				}, "outCirc"):after(1500)
				:chain(800, {})
				:onEnd(function()
					uqt.scene.switch("intro")
				end)
				splash.time.run(function()
					gong:play()
				end):after(1400)
			end)
		end)
	end)
end)

local esc = uqt.input.button("keyboard.escape")
splash.update = function()
	if esc:pressed() then
		uqt.scene.switch("intro")
	end
end

print("WARNING: Someone seems to be reading console output. Be careful.")

return splash
