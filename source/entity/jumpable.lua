local SolidSprite = require("entity.solidsprite")
local Text = require("entity.text")
local scene = require("ubiquitousse").scene
local entities = require("entities")

return SolidSprite {
	__name = "jumpable",

	jumpable = true,

	width = 32,
	height = 32,

	lp = 1,
	pieces = 0,
	ouchSound = {},
	funnyText = {},

	jumpover = function(self)
		if self.lp > 0 then
			self.lp = self.lp - 1
			if #self.ouchSound > 0 then
				self.ouchSound[math.random(1, #self.ouchSound)]:play()
			end
			if self.lp <= 0 then
				self:die()
			end
		end
	end,

	die = function(self) -- placeholder, called when the entity's lp goes under 0
		local score = require("ubiquitousse").scene.current.score
		if score then
			score.thingsKilled = score.thingsKilled + 1
		end

		self.noCollision = true

		scene.current.time.tween(75, self, {
			color = { 1, 1, 1, 0 }
		}, "outCubic")
		:chain(75, self, {
			color = { 1, 1, 1, 1 }
		})
		:chain(75, self, {
			color = { 1, 1, 1, 0 }
		})
		:onEnd(function()
			self.ignoreDamage = true
			self.noCollision = true
			self.remove = true
		end)

		if self.pieces ~= 0 then
			local pieces = self.pieces
			if type(pieces) == "table" then
				pieces = pieces[math.random(1, #pieces)]
			end
			local inv = entities.find("inventory")
			inv:add(pieces)
		end

		if #self.funnyText > 0 then
			local t = Text:new(font.Stanberry[22], self.funnyText[math.random(1, #self.funnyText)], self.x, self.y, {
				shadowColor = {0, 0, 0, 1},
				alignX = "center",
				alignY = "bottom"
			})
			scene.current.time.tween(3000, t, {
				y = self.y - 50,
				color = { 1, 1, 1, 0 },
				shadowColor = { 0, 0, 0, 0 }
			}, "inCubic")
		end
	end
}
