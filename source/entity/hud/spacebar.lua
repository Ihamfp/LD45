--[[
Tiers: 1 to 8:
	1: Butter
	2: Fresh butter
	3: Plastic
	4: Aluminium
	5: Steel
	6: Butter Steel
	7: Nokia 3310
	8: Adamantium
]]

spaceBarGenied = false

local tiers = {
	"Peanut butter",
	"Fresh peanut butter",
	"Plastic",
	"Aluminium",
	"Steel",
	"Peanut butter steel",
	"Nokia 3310",
	"Adamantium"
}

local tiersLife = {
	3, --3
	8, --6
	15, --10
	23, --14
	32, --18
	42, --22
	54, --27
	67 --32
}

local nameDict = { -- for each tier, custom random names
	{
		"Spacey",
		"Spaaaace",
		"Odyssey",
		"Ok",
		"Basic",
		"Handle",
		"Oh, I see you have a",
		"Barely a",
		"It works",
		"Long",
		"Keyboard thingie",
		"It's not great but I like this",
		"Cheap",
		"Buddy",
		"You know, there's actually 8 tiers"
	},
	{
		"Imma cow",
		"Mhhh fresh milk",
		"Good enough",
		"Mini",
		"Damn, nice",
		"It's a slightly better",
		"Entry-level",
		"Good, but not good enough",
		"Lovely",
		"Mate",
		"Higher tiers are funnier"
	},
	{
		"It's fantastic",
		"Wooden",
		"Mostly solid looking",
		"Cherry MX Red-powered",
		"Tool",
		"The best-your-money-can-buy",
		"I want the same",
		"You will rate this game 5/5",
		"This is a funny joke",
		"This game is a trainwreck"
	},
	{
		"Aluminum (sic)",
		"Shiny",
		"Iso",
		"Fancy",
		"Pretty sturdy looking",
		"Wow, that's a nice looking",
		"This won awards",
		"I lied"
	},
	{
		"I've got spaces of steel",
		"Mystery",
		"Foo",
		"Bar bar",
		"Heavy",
		"The Amazing",
		"You will finish the game"
	},
	{
		"120% Slipery",
		"Peanut butter-infused steel",
		"The Legendary",
		"Hero's",
		"The One True",
		"Mordor-forged",
		"Git gud",
		"I have to admit, you're pretty good"
	},
	{
		"Chuck-Norris"
	},
	{
		"You lost the game"
	}
}

local Sprite = require("entity.sprite")

local entities = require("entities")

local tierImg = {}
for i=1, #tiers do
	tierImg[i] = love.graphics.newImage("asset/sprite/spaceTiers/space_tier"..tostring(i)..".png")
end

local width, height = 512, 64

local breakQuad = {}
for i=1, 8 do -- usage
	breakQuad[i] = love.graphics.newQuad(0, (i-1)*height, width, height, 512, 512)
end
local anim8 = require("anim8")

return Sprite {
	__name = "spacebar",
	hud = true,

	x = love.graphics.getWidth()/2 - width/2,
	y = love.graphics.getHeight() - height - 15,

	tier = 1,
	name = 0, -- 0 for generic "<tier>-bar"
	usage = 0, -- goes up each usage, durability is calculated on-the-go
	keepBetweenScenes = true,

	new = function(self, tier, options)
		Sprite.new(self, self.x, self.y, options)
		self.tier = tier or 1

		--[[local idleg = anim8.newGrid(width, height, tierImg[self.tier]:getWidth(), tierImg[self.tier]:getHeight())
		self.animation.idle = anim8.newAnimation(idleg(1,"1-3"), { 0.5, 0.5, 0.5 })
		self.image.idle = tierImg[self.tier]

		self:set("idle")]]
	end,

	use = function(self)
		if spaceBarGenied then
			self.usage = self.usage + 1
			local spacestack = entities.find("spacestack")
			if self.usage >= tiersLife[self.tier] and #spacestack.filo > 0 then
				local i = tierImg[self.tier]
				local e = require("entity.entity"):new({
					hud = true,
					x = self.x, y = self.y,
					color = {1,1,1,1},
					draw = function(self)
						love.graphics.setColor(self.color)
						love.graphics.draw(i, breakQuad[8], self.x, self.y)
					end
				})
				require("ubiquitousse").scene.current.time.tween(300, e, {
					y = self.y + 80,
					color = {1,1,1,0}
				}, "inQuad")
				:onEnd(function()
					e.remove = true
				end)
			end
		end
	end,

	isBroken = function(self) -- true when need to be replaced/game over
		return self.usage >= tiersLife[self.tier]
	end,

	randomize = function(self)
		self.name = math.random(0, #nameDict[self.tier])
	end,

	draw = function(self)
		if spaceBarGenied then
			local breakLevel = (tiersLife[self.tier] - self.usage) / tiersLife[self.tier]
			breakLevel = (7-math.ceil(breakLevel * 7))+1
			if breakLevel > #breakQuad or self:isBroken() then
				return
			end
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(tierImg[self.tier], breakQuad[breakLevel], self.x, self.y)
			love.graphics.setColor(0,0,0,1)
			love.graphics.setFont(font.LemonMilk[14])
			love.graphics.print("Tier "..tostring(self.tier), self.x+16, self.y+8)
			love.graphics.setFont(font.LemonMilk[24])
			local text
			if not nameDict[self.tier][self.name] then
				text = tiers[self.tier].." bar"
			else
				text = nameDict[self.tier][self.name] .. " bar"
			end
			love.graphics.print(text, self.x+16, self.y+24)
			love.graphics.setColor(1,1,1,1)
		end
	end,

	tierImg = tierImg, -- to avoid re-loading the images

	save = function(self)
		self.usageSave = self.usage
		self.tierSave = self.tier
		self.nameSave = self.name
		self.spaceBarGeniedSave = spaceBarGenied
	end,

	load = function(self)
		self.usage = self.usageSave
		self.tier = self.tierSave
		self.name = self.nameSave
		spaceBarGenied = self.spaceBarGeniedSave
	end
}
