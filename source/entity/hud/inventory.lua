--[[
Parts list:
	* Ryzen 2700X
	* GTX 1070
	* 2x8Go, 3200MHz DDR4

JUST KIDIN'
]]

local Sprite = require("entity.sprite")
local Text = require("entity.text")

local entities = require("entities")
local scene = require("ubiquitousse").scene
local qteInput = require("input").inventory

local imgStorage = love.graphics.newImage("asset/sprite/partStorage.png")
local blankQuad = love.graphics.newQuad(0, 0, 64, 64, 128, 64)
local selectQuad = love.graphics.newQuad(64, 0, 64, 64, 128, 64)

local ding = love.audio.newSource("asset/audio/toudim.wav", "static")
local sad = love.audio.newSource("asset/audio/youlost.wav", "static")

local tiersParts = {
	3,
	6,
	10,
	14,
	18,
	22,
	27,
	32,
}

local craftCount = 0

return Sprite {
	__name = "inventory",
	hud = true,
	keepBetweenScenes = true,

	x = 10,
	y = 30,
	width = 64,
	height = 64,
	space = 10,
	scale = 0.5,

	slots = 64,

	minSpeed = 20,

	parts = {}, -- -1 for empty
	highlight = {},

	qteMaxTime = 2.0, -- 1s max between each press
	qteTimer = 0,
	qteCount = 0, -- parts
	xoffset = 0,

	save = function(self)
		self.partsSave = {}
		for k,v in pairs(self.parts) do self.partsSave[k] = v end
	end,
	load = function(self)
		self.parts = {}
		self.highlight = {}
		for k,v in pairs(self.partsSave) do
			self.parts[k] = v
			self.highlight[k] = false
		end
	end,

	new = function(self, options, parts)
		Sprite.new(self, self.x, self.y, options)
		self.parts = parts or {}
		-- for i=1, self.slots do
		-- 	self.parts[i] = self.parts[i] or math.random(0, 9)
		-- 	self.highlight[i] = false
		-- end
	end,

	add = function(self, n)
		for _=1, n do
			local i = #self.parts+1
			self.parts[i] = math.random(0, 9)
			self.highlight[i] = false
		end

		ding:play()

		local t = Text:new(font.Stanberry[22], "+"..tostring(n), self.xoffset + self.x+ (#self.parts*(self.width + self.space) + 20)*self.scale -10, self.y + 10*self.scale +3, {
			hud = true,
			shadowColor = {0, 0, 0, 1},
			color = {0.3,1,0.5,1},
			alignX = "left",
			alignY = "top"
		})
		scene.current.time.tween(1000, t, {
			y = self.y - 50,
			color = { 1, 1, 1, 0 },
			shadowColor = { 0, 0, 0, 0 }
		}, "inCubic")
		:onEnd(function()
			t.remove = true
		end)
	end,

	update = function(self, dt)
		local hyke = entities.find("hyke")
		if not hyke then return end

		if self.qteCount > 0 then
			self.qteTimer = self.qteTimer + dt
		end
		if self.xoffset > 0 then
			self.xoffset = self.xoffset - 500*dt
			if self.xoffset < 0 then
				self.xoffset = 0
			end
		end

		if self.qteCount < #self.parts then
			local partToPress = self.parts[self.qteCount+1]
			for i=1, 10 do
				if i ~= partToPress+1 and qteInput[i]:pressed() then
					self.qteTimer = self.qteMaxTime+1 -- you lost the chain
				end
			end
			if hyke.speed >= self.minSpeed and qteInput[partToPress+1] and qteInput[partToPress+1]:pressed() then
				self.qteTimer = 0
				self.qteCount = self.qteCount + 1
				self.highlight[self.qteCount] = true
			end
		end

		if self.qteTimer > self.qteMaxTime or self.qteCount >= #self.parts then
			self:addBar()
			self.xoffset = self.qteCount * (self.width + self.space)*self.scale
			for i=1, self.qteCount do
				self.highlight[i] = false
				table.remove(self.parts, 1) -- TODO animation
			end
			self.qteCount = 0
			self.qteTimer = 0
		end
	end,

	addBar = function(self)
		local tierToAdd = 0 -- 0 = nothing
		for i=1, 8 do
			if self.qteCount >= tiersParts[i] then
				tierToAdd = i
			end
		end

		if tierToAdd > 0 and tierToAdd < 9 then
			craftCount = craftCount +1
			if craftCount == 42 then
				require("entity.hud.achievement"):new("42th bar crafted", love.graphics.newImage("asset/sprite/achievements/craft.png"))
			end
			if tierToAdd == 5 and not craftedTier5 then
				craftedTier5 = true
				require("entity.hud.achievement"):new("Tier5: Oh, I see, you can do several things at the same time", love.graphics.newImage("asset/sprite/achievements/tier5.png"))
			end
			if tierToAdd == 6 and not craftedTier6 then
				craftedTier6 = true
				require("entity.hud.achievement"):new("Tier 6: You're steel going, or peanut butter steel if I allow myself", love.graphics.newImage("asset/sprite/achievements/tier6.png"))
			end
			if tierToAdd == 7 and not craftedTier7 then
				craftedTier7 = true
				require("entity.hud.achievement"):new("Tier 7: Better than 6, worse than 8", love.graphics.newImage("asset/sprite/achievements/tier7.png"))
			end
			if tierToAdd == 8 and not craftedTier8 then
				craftedTier8 = true
				require("entity.hud.achievement"):new("Tier 8: I'm sure you used you numpad", love.graphics.newImage("asset/sprite/achievements/tier8.png"))
			end
			entities.find("spacestack"):add(tierToAdd)
		elseif self.qteCount > 0 then
			sad:play()
		end
		-- TODO add more
	end,

	draw = function(self)
		for i=1, #self.parts do
			if self.parts[i] >= 0 then
				local hyke = entities.find("hyke")
				if not hyke then return end
				local a = 1
				if hyke.speed < self.minSpeed then
					a = 0.5
				end

				love.graphics.setColor(1, 1, 1, a)
				love.graphics.draw(imgStorage, self.highlight[i] and selectQuad or blankQuad, self.xoffset + self.x+ (i-1)*(self.width + self.space)*self.scale, self.y, 0, self.scale)
				love.graphics.setColor(0,0,0,a)
				love.graphics.setFont(font.LemonMilk[24])
				love.graphics.print(tostring(self.parts[i]), self.xoffset + self.x+ ((i-1)*(self.width + self.space) + 20)*self.scale -2, self.y + 10*self.scale -5 , 0)

				love.graphics.setFont(font.LemonMilk[14])
				for j, tier in ipairs(tiersParts) do
					if i == tier then
						local str, x, y = "Tier "..tostring(j), self.xoffset + self.x+ ((i-1)*(self.width + self.space) + 20)*self.scale -6, self.y + 10*self.scale +32
						love.graphics.setColor(0, 0, 0, a)
						love.graphics.line(x-3.5, y-30, x-3.5, y+20)
						love.graphics.print(str, x+1, y)
						love.graphics.print(str, x-1, y)
						love.graphics.print(str, x, y+1)
						love.graphics.print(str, x, y-1)
						love.graphics.setColor(1, 1, 1, a)
						love.graphics.print(str, x, y)
					end
				end

				if a < 1 then
					love.graphics.setColor(1, 0, 0, a)
					love.graphics.print("Too slow to craft", self.x, self.y + 80)
				end
			end
		end
		if self.qteCount > 0 then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.arc("fill", "pie", self.x + 18, self.y + 55, 17, -math.pi/2+(self.qteTimer/self.qteMaxTime) * 2*math.pi, 3*math.pi/2)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.arc("line", "pie", self.x + 18, self.y + 55, 17, -math.pi/2+(self.qteTimer/self.qteMaxTime) * 2*math.pi, 3*math.pi/2)
		end
	end
}
