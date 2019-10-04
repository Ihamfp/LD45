local uqt = require("ubiquitousse")
local scene = uqt.scene

local shine = require("shine")
local entities = require("entities")

local Diaporama = require("entity.diaporama")
local Text = require("entity.text")
local Rectangle = require("entity.rectangle")

local dramatic = love.audio.newSource("asset/audio/Dramatic.ogg", "static")
local bip = love.audio.newSource("asset/audio/bipbop.wav", "static")
local badum = love.audio.newSource("asset/audio/badumpish.wav", "static")
local zik = love.audio.newSource("asset/audio/Running out of Power.ogg", "stream")

local intro = scene.new("intro")
entities.reset(intro)
local vignette = shine.vignette{
	radius = 1.2,
	opacity = 0.4
}
intro.effect = vignette
local scanlines = shine.vignette{
	radius = 1.2,
	opacity = 0.4
}:chain(shine.scanlines())

function intro:exit()
	zik:stop()
end

--- ENTITIES --
local plan1 = Diaporama:new("intro1.png")
local plan2 = Diaporama:new("intro2.png", {
	visible = false
})
local plan3 = Diaporama:new("intro3.png", {
	visible = false,
}, true)


--- SCRIPT ---
local rect = Rectangle:new(0, 0, 1280, 720, {
	color = {0,0,0,255}
})
intro.time.tween(700, rect.color, {[4]=0})
intro.time.run(function()
	zik:play()
end):after(500)
intro.time.run(function()
	plan1:change(2)
end):after(2700)
:chain(function()
	plan1:change(3)
end):after(2000)
:chain(function()
	plan1:change(4)
end):after(2000)
:chain(function()
	rect = Rectangle:new(0, 0, 1280, 720, {
		color = { 255, 255, 255, 0 }
	})
	local text, text2 = Text:new("PerfectDOS.ttf", 25, "> ", 10, 10, {
		color = { 0, 0, 0, 0 }
	})
	intro.time.tween(500, rect.color, {
		[4] = 255
	})
	intro.effect = scanlines
	intro.time.run(function()
		text.color[4] = 255
	end):after(700)
	:chain(function()
		text.text = "> DIALING CRENDENTIALS\n"
		bip:play()
	end):after(500)
	:chain(function()
		text.text = text.text.."REACHED EARTHNET\n"
		bip:play()
	end):after(1000)
	:chain(function()
		text.text = text.text.."\nYOU HAVE 86 NEW MESSAGES (LAST: Re: Re: Tr: TOP TEN WAYS TO ENLAR...)"
		bip:play()
	end):after(700)
	:chain(function()
		text.text = text.text.."\nWEATHER: CLOUDS ARE STILL BELOW YOU"
		bip:play()
	end):after(200)
	:chain(function()
		text.text = text.text.."\nNEWS: WORLD'S CLASSIEST MAN MYSTERIOUSLY DIE: \"SHITTY WORLD\""
		bip:play()
	end):after(200)
	:chain(function()
		text.text = text.text.."\nCALENDAR: YOU ONLY HAVE 2 HOURS LEFT TO FINISH YOUR LD39 PROJECT\n          (LAST NOTE: LEARN LEVEL DESIGN)\n\n> "
		bip:play()
	end):after(200)
	:chain(function()
		text.text = text.text.."WELCOME BACK, GOD\n"
		bip:play()
	end):after(800)
	:chain(function()
		text.text = text.text.."TODAY STATUS: 0 WORSHIPPERS"
		bip:play()
	end):after(1400)
	:chain(function()
		rect.color[4] = 0
		text.color[4] = 0
		intro.effect = vignette
	end):after(3500)
	:chain(function()
		dramatic:play()
		rect.color[4] = 255
		text.color[4] = 255
		intro.effect = scanlines
	end):after(2000)
	:chain(function()
		text:remove()
		text = Text:new("PerfectDOS.ttf", 150, "0 WORSHIPPERS", 10, love.graphics.getHeight()/2, {
			alignY = "center",
			color = { 0, 0, 0, 255 }
		})
		--boum:play()
		plan1:change(5)
	end):after(900)
	:chain(function()
		rect.color[4] = 0
		text.color[4] = 0
		intro.effect = vignette
	end):after(2600)
	:chain(function()
		rect = Rectangle:new(0, 0, 1280, 720, {
			color = {255,255,255,0}
		})
		intro.time.tween(500, rect.color, {[4]=255})
			:onEnd(function()
				plan1.visible = false
				plan2.visible = true
			end)
			:chain(500, {[4]=0})
	end):after(1500)
	:chain(function()
		plan2:change(2)
	end):after(4000)
	:chain(function()
		plan2:change(3)
	end):after(3000)
	:chain(function()
		plan2:change(4)
	end):after(1000)
	:chain(function()
		rect = Rectangle:new(0, 0, 1280, 720, {
			color = {255,255,255,0}
		})
		intro.time.tween(500, rect.color, {[4]=255})
			:onEnd(function()
				plan2.visible = false
				plan3.visible = true
			end)
			:chain(500, {[4]=0})
	end):after(2000)
	:chain(function()
		plan3:change(2)
	end):after(2500)
	:chain(function()
		plan3:change(3)
	end):after(700)
	:chain(function()
		text = Text:new("Stanberry.ttf", 25, "What have you done? How did you corrupt so many of my followers? And who are you?", 0, love.graphics.getHeight()/2-40, {
			alignX = "center", limit = 1280,
			alignY = "center",
			color = { 20, 200, 20, 255},
			shadowColor = {0,0,0,255}
		})
		plan3:set("hyke")
	end):after(1000)
	:chain(function()
		text.text = "Hohoho... I see you're confused, old man. Don't worry, they're into better hands now. The only thing I had to give them was free WiFi, and they all turned their back on you..."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(3500)
	:chain(function()
		text.text = "What? Are you making fun of me? I'll get them back! And then I'll take my revenge. PFFT!"
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(5500)
	:chain(function()
		text.text = "No really, I only gave them free WiFi."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(3500)
	:chain(function()
		text.text = "..."
		text.color = { 20, 200, 20, 255}
		plan3:set("still")
	end):after(2500)
	:chain(function()
		text.text = "... Anyway, to answer your question:"
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(700)
	:chain(function()
		text.text = "I AM"
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(2500)
	:chain(function()
		entities.shake = 10
		text.text = ""
		text2 = Text:new("LemonMilk.otf", 72, "BAD UMPISH", 0, love.graphics.getHeight()/2, {
			alignX = "center", limit = 1280,
			alignY = "center",
			color = { 230, 50, 30, 255},
			shadowColor = {0,0,0,255}
		})
		badum:play()
		plan3:set("badhyke")
	end):after(2000)
	:chain(function()
		entities.shake = 0
	end):after(200)
	:chain(function()
		text2.visible = false
		plan3:set("still")
	end):after(1500)
	:chain(function()
		text.text = "That was impressive."
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(2000)
	:chain(function()
		text.text = "I know, right? I've been training for three months."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(2000)
	:chain(function()
		text.text = "Nice! Anyway, where were we..."
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(2500)
	:chain(function()
		text.text = "..."
		text.color = { 20, 200, 20, 255}
		plan3:set("still")
	end):after(1500)
	:chain(function()
		text.text = "I got it!"
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(700)
	:chain(function()
		text.text = "I hate you Umpish, and I will do everything I can to make you suffer!"
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(1500)
	:chain(function()
		text.text = "You're pathetic! You don't have any follower anymore! You're POWERLESS! Ah AH AH AH AH AH AH"
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(3500)
	:chain(function()
		text.text = "AH AH... Wait, no. I've just remebered that long laughs are a bad guy cliché."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(3500)
	--[[:chain(function()
		text.text = "AH AH AH. AH. AH AH ah..."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(1000)
	:chain(function()
		text.text = "ah... ah ah... ah... that's tiring."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(900)]]
	:chain(function()
		text.text = "I'll get them all back! And then I'll take my revenge!"
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(3100)--1500)
	:chain(function()
		text.text = "You already said that."
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(2500)
	:chain(function()
		text.text = "This dialogue seems poorly writ-"
		text.color = { 230, 50, 30, 255}
		plan3:set("badhyke")
	end):after(1800)
	:chain(function()
		text.text = "DON'T TRY TO CHANGE THE SUBJECT AGAIN! I'll see you again, Umpish, and this will be the last time you see anyone!"
		text.color = { 20, 200, 20, 255}
		plan3:set("hyke")
	end):after(500)
	:chain(function()
		rect = Rectangle:new(0, 0, 1280, 720, {
			color = {0,0,0,0}
		})
		intro.time.tween(800, rect.color, {[4]=255})
			:onEnd(function()
				plan3.visible = false
				plan1.visible = true
				text.visible = false
				plan1:change(4)
			end)
			:chain(800, {[4]=0})
			:chain(1000, {})
			:chain(10, {0,0,0,0})
			:chain(500,{[4]=255})
			:onEnd(function()
				uqt.scene.switch("instructions")
			end)
	end):after(4000)
end):after(2000)


local esc = uqt.input.button("keyboard.escape")
intro.update = function()
	if esc:pressed() then
		uqt.scene.switch("instructions")
	end
end

return intro
