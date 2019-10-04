local Sprite = require("entity.sprite")
local anim8 = require("anim8")
local pointer = require("input").pointer
local interact = require("input").interact
local examine = require("input").examine
local entities = require("entities")
local Interactable = require("entity.interactable")
local dialog = require("dialog")
local s = require("ubiquitousse.scene")

return Sprite {
	__name = "pointer",
	aboveAll = true,

	new = function(self, options)
		Sprite.new(self, 0, 0, options)

		self.image.idle = love.graphics.newImage("asset/sprite/pointeridle.png")
		local g = anim8.newGrid(self.image.idle:getWidth(), self.image.idle:getHeight(), self.image.idle:getWidth(), self.image.idle:getHeight())
		self.animation.idle = anim8.newAnimation(g(1,1), 100)

		self.image.click = love.graphics.newImage("asset/sprite/pointerclick.png")
		local g_ = anim8.newGrid(self.image.click:getWidth(), self.image.click:getHeight(), self.image.click:getWidth(), self.image.click:getHeight())
		self.animation.click = anim8.newAnimation(g_(1,1), 100)

		self:set("idle")
	end,

	update = function(self)
		self.x, self.y = pointer:x()-entities.dxV, pointer:y()-entities.dyV

		self:set("idle")
		for _, e in ipairs(entities.list) do
			if (e.interact and e.examine and e.collide) and e:collide(self.x, self.y, 10, 10) then
				local changeCursor = true

				if interact:pressed() and not dialog.visible then
					local txt = e:interact()
					if txt then dialog.write(txt, "hyke") end
				end
				if not interact:down() and not dialog.visible then
					local txt = e:examine()
					if txt == false then changeCursor = false end
					if txt then dialog.write(txt, "hyke") end
				end

				if changeCursor then self:set("click") end
			end
		end
	end
}
