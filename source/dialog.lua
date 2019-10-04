--- Dialog box manager.

local scene = require("ubiquitousse.scene")
local utf8 = require("utf8")
local entities = require("entities")
local Text = require("entity.text")
local s = require("ubiquitousse.scene")

-- Options
local box = {
	width = 500
}
local color = {
	textInit = { 255, 255, 255, 0 },
	text = { 255, 255, 255, 255 },
	shadowInit = { 255, 255, 255, 0 },
	shadow = { 0, 0, 0, 255 }
}
local waitLetters = {
	40,
	["."] = 800, ["?"] = 900, ["!"] = 700, [","] = 400, [" "] = 5, [">"] = 300,
	["\r"] = 500
}
local hiddenLetters = {
	["\r"] = true -- TODO: set as dialog box change / cadre suivant character
}
local speedMultiplicator = 1

-- Private stuff
local function write(text, txt, bip, timer) -- write stuff to the buffer
	timer = timer or scene.current.time
	return timer.run(function(wait)
		for letter in txt:gmatch(utf8.charpattern) do
			if not hiddenLetters[letter] then
				text.text = text.text .. letter
				if bip then bip:play() end
			end
			wait((waitLetters[letter] or waitLetters[1]) / speedMultiplicator)
		end
	end)
end

-- Public stuff
local dialog = {
	visible = false -- indicate whenever a dialog box is active
}

local shine = require("shine")
local blur = shine.boxblur {
	radius = 3
}

--- Write text over entity.
function dialog.write(text_, entity, bip)
	dialog.visible = true

	local text = Text{
		draw = function(self)
			blur:draw(function()
				Text.draw(self)
			end)
			Text.draw(self)
		end
	}:new("Stanberry.ttf", 24, "", 0, 0, {
		limit = box.width,
		alignX = "center", alignY = "top",
		color = { unpack(color.textInit) },
		shadowColor = { unpack(color.shadowInit) }
	})

	-- place
	local maxWidth, wrapped = text.font:getWrap(text_, box.width)
	text.limit = maxWidth
	local e = entities.find(entity)
	text.x, text.y = e.x - e.ox + (e.width or 0)/2 - maxWidth/2, e.y - e.oy - #wrapped * text.font:getHeight()
	if text.x < 0 then text.x = 0 end
	if text.x + maxWidth > love.graphics.getWidth() then text.x = love.graphics.getWidth() - maxWidth end
	if text.y < 0 then text.y = 0 end

	-- write
	local out = write(text, table.concat(wrapped, "\n"), bip)
		:chain(function()
			dialog.visible = false
			scene.current.time.tween(250, text, {
				color = color.textInit,
				shadowColor = color.shadowInit
			}, "inCubic"):onEnd(function()
				for i, o in ipairs(entities.list) do
					if o == text then
						table.remove(entities.list, i)
						break
					end
				end
			end)
		end):after(2000)

	-- show
	scene.current.time.tween(250, text, {
		color = e.textColor or color.text,
		shadowColor = color.shadow
	}, "outCubic")

	return out
end

--- Script a dialog box using a function.
function dialog.script(func)
	local timer = scene.current.time -- the TimeRegistry of the scene where script was initially called
	local co = coroutine.create(func)
	-- Various functions
	local function resume()
		assert(coroutine.resume(co))
	end
	-- Function environment
	local function say(txt, entity, bip) -- write text
		dialog.write(txt, entity, bip):onEnd(resume)
		coroutine.yield()
	end
	local function wait(time) -- wait some time
		if time then timer.run(resume):after(time) end
		coroutine.yield()
	end
	--- TODO: ask. See NoNameRPG.
	local function go(sceneName) -- change the current scene (and expect to resume the script after)
		scene.push(sceneName)
		wait(1)
	end
	local function run(fn) -- shotcut to scene.current.time.run
		return timer.run(fn)
	end
	-- Start
	assert(coroutine.resume(co, { say = say, wait = wait, go = go, run = run, resume = resume }))
end

return dialog
