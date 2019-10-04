-- dessine juste les barres espace en échelle x0.25 / x0.5, empilées
-- en x,y = 10,10 ?

local Sprite = require("entity.sprite")
local Spacebar = require("entity.hud.spacebar")
local scene = require("ubiquitousse").scene

local tierImg = {}
for i=1, 8 do
	tierImg[i] = love.graphics.newImage("asset/sprite/spaceTiers/space_tier"..tostring(i)..".png")
end

local topQuad = love.graphics.newQuad(0, 0, 512, 64, 512, 512)
local dong = love.audio.newSource("asset/audio/newspace.wav", "static")

return Sprite {
	__name = "spacestack",
	hud = true,
	keepBetweenScenes = true,

	maxStack = 10,
	filo = {},

	x = 10,
	y = 6,

	barw = 128, --scaling
	barh = 20,  --scaling
	barsp = 16, --overlap

	new = function(self, options, filo)
		Sprite.new(self, self.x, self.y, options)
		self.filo = filo or {}
	end,

	getNext = function(self)
		local r = self.filo[#self.filo]
		self.filo[#self.filo] = nil
		return r
	end,

	add = function(self, tierToAdd)
		dong:play()

		self.filo[#self.filo+1] = tierToAdd

		local score = require("ubiquitousse").scene.current.score
		if score then
			score.maxTier = math.max(score.maxTier, tierToAdd)
		end

		local t = require("entity.text"):new(font.Stanberry[22], "+tier "..tostring(tierToAdd), 10, 10, {
			hud = true,
			shadowColor = {0, 0, 0, 1},
			color = {0,1,0,1},
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

	draw = function(self)
		-- raw löve because Ihamfp
		local x = self.x + #self.filo * self.barsp
		for i=1, #self.filo do
			local scaleX = self.barw / tierImg[self.filo[i]]:getWidth()
			local scaleY = self.barh / (tierImg[self.filo[i]]:getHeight() / 8)
			love.graphics.draw(tierImg[self.filo[i]], topQuad, x - i*self.barsp, self.y, 0, scaleX, scaleY)
		end
	end,

	save = function(self)
		self.filoSave = {}
		for k,v in pairs(self.filo) do self.filoSave[k] = v end
	end,

	load = function(self)
		self.filo = {}
		for k,v in pairs(self.filoSave) do self.filo[k] = v end
	end
}
