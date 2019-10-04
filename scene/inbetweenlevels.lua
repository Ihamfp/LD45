local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local input = require("input")

local Text = require("entity.text")
--local BgParalax = require("entity.bgparalax")

if not totalscoreG then totalscoreG = 0 end

local start = scene.new("inbetweenlevels")
entities.reset(start)

local levelName = {
	spuermarche = "Ground Floor Market",
	reserve = "Level -1: Storage",
	cimetiere = "Level -2: Crypt",
	totheboss = "Level -3: Ludum Dare Theme Storage",
	boss = "Level -3: Forgotten Themes Genie",
}

-- 1 pt
local coins = {
	love.audio.newSource("asset/audio/coin1.ogg", "static"),
	love.audio.newSource("asset/audio/coin2.ogg", "static"),
	love.audio.newSource("asset/audio/coin3.ogg", "static"),
	love.audio.newSource("asset/audio/coin4.ogg", "static"),
	love.audio.newSource("asset/audio/coin5.ogg", "static"),
	love.audio.newSource("asset/audio/coin6.ogg", "static"),
	love.audio.newSource("asset/audio/coin7.ogg", "static")
}

-- 10 pts
local manycoins = {
	love.audio.newSource("asset/audio/manycoins1.ogg", "static"),
	love.audio.newSource("asset/audio/manycoins2.ogg", "static"),
	love.audio.newSource("asset/audio/manycoins3.ogg", "static"),
	love.audio.newSource("asset/audio/manycoins4.ogg", "static")
}

local function sfx(n)
	while n > 0 do
		if n > 10 then
			start.time.run(function() manycoins[math.random(1, #manycoins)]:clone():play() end):after(math.random(0,500))
			n = n -10
		else
			start.time.run(function() coins[math.random(1, #coins)]:clone():play() end):after(math.random(0,500))
			n = n -1
		end
	end
end

entities.disableHud = true

function start:enter(score, level, next)
	love.graphics.setBackgroundColor(0, 0, 0, 1)

	love.audio.newSource("asset/audio/newspace.wav", "static"):play()

	-- Save
	entities.find("spacestack"):save()
	entities.find("spacebar"):save()
	entities.find("inventory"):save()

	-- local zik = love.audio.newSource("asset/audio/"..power.unlockZik, "stream")
	-- zik:setLooping(true)
	-- zik:play()
	function start:exit()
		-- zik:stop()
	end
	function start:suspend()
		-- zik:stop()
	end
	function start:resume()
		entities.set(start)
		-- zik:play()
	end

	Text:new(font.LemonMilk[54], tostring(levelName[level] or level).." complete!", love.graphics.getWidth()/2, 20, {
		alignX = "center",
		color = { 1, 1, 1, 1 }
	})

	local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
		color = {1,1,1,1}
	})
	start.time.tween(500, rect.color, {[4]=0})

	local total = 0
	local maxTotal = 0
	local x = 150
	start.time.run(function()
		local n = math.floor(score.maxSpeed/10)
		total = total + n
		maxTotal = maxTotal +25
		local r = 1-n/25
		Text:new(font.LemonMilk[24], "Maximum speed reached: "..math.floor(score.maxSpeed/2.2).." bananas per second", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local n = math.floor(score.maxSpeedDuration)
		total = total + n
		maxTotal = maxTotal +60
		local r = 1-n/60
		Text:new(font.LemonMilk[24], "Top speed maintened for "..math.floor(score.maxSpeedDuration).." seconds", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local n = math.floor(score.thingsKilled*5)
		total = total + n
		maxTotal = maxTotal +60
		local r = 1-n/75
		Text:new(font.LemonMilk[24], math.floor(score.thingsKilled).." things killed", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local n = math.floor(score.maxTier*10)
		total = total + n
		maxTotal = maxTotal +80
		local r = 1-n/80
		Text:new(font.LemonMilk[24], "Best space bar tier: "..math.floor(score.maxTier), love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, 270, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local n = math.floor(1/score.time * 2000)
		total = total + n
		maxTotal = maxTotal +75
		local r = 1-n/75
		Text:new(font.LemonMilk[24], math.floor(score.time).." seconds total", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local n = math.floor(score.thingsGrazed * 2)
		total = total + n
		maxTotal = maxTotal +75
		local r = 1-n/75
		Text:new(font.LemonMilk[24], math.floor(score.thingsGrazed).." things grazed", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local inv = entities.find("inventory")
		local n = math.floor(#inv.parts * 5)
		total = total + n
		maxTotal = maxTotal +100
		local r = 1-n/100
		Text:new(font.LemonMilk[24], math.floor(#inv.parts).." remaining pieces", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		x = x + 40
		local inv = entities.find("spacestack")
		local n = 0
		for _, s in ipairs(inv.filo) do
			n = n + math.floor(s * 5)
		end
		total = total + n
		maxTotal = maxTotal +50
		local r = 1-n/50
		Text:new(font.LemonMilk[24], "Space bars remaining", love.graphics.getWidth()/2+200, x, {
			alignX = "right",
			color = { 1, 1, 1, 1 }
		})
		Text:new(font.LemonMilk[24], "+"..tostring(n).." points", love.graphics.getWidth()/2+210, x, {
			alignX = "left",
			color = { r, 1-r*.2, 0.4, 1 }
		})
		sfx(n)
	end):after(1000)
	:chain(function()
		local r = 1-total/maxTotal
		local t = Text:new(font.LemonMilk[94], math.floor(total).." points total", love.graphics.getWidth()/2, 520, {
			alignX = "center",
			color = { r, 1, 0, 1 }
		})
		start.time.run(function()
			t.color[1] = r + (0.5-math.random())*.5
			t.color[2] = 1 - math.random()*.5
			t.color[3] = math.random()*.5

			if input.enter:pressed() then
				entities.freeze = true
				local name = scene.current.name
				local rect = require("entity.rectangle"):new(0, 0, 1280, 720, {
					aboveAll = true,
					color = {0,0,0,0}
				})
				scene.current.time.tween(500, rect.color, {[4]=1})
				:onEnd(function()
					rect.remove = true
					entities.freeze = false
					scene.switch(next)
				end)
			end
		end):every(0)
		entities.shake = 80
		start.time.tween(500, entities, { shake = 0 })
		sfx(total)
		totalscoreG = totalscoreG + total
	end):after(1000)
	:chain(function()
		Text:new(font.LemonMilk[24], "Since beginning: "..tostring(totalscoreG)..". Press enter to continue", love.graphics.getWidth()/2, 650, {
			alignX = "center",
			color = { .7, .7, .7, 1 }
		})
	end):after(1000)
end

return start
