--- Keep track of loaded entities.

local s = require("ubiquitousse.scene")

local t = 0

local entities
entities = {
	aboveList = {},
	list = {},
	hud = {},

	shake = 0,

	dxV = 0, dyV = 0,

	--- Deletes all entities.
	reset = function(scene)
		entities.shake = 0
		entities.freeze = false
		entities.freezeButHyke = false
		entities.disableHud = false
		entities.noSprites = false
		local hud = {}
		for _, e in ipairs(entities.hud) do
			if e.keepBetweenScenes then
				table.insert(hud, e)
			end
		end
		scene.entities = {}
		scene.aboveEntities = {}
		scene.hud = hud
		entities.list = scene.entities
		entities.aboveList = scene.aboveEntities
		entities.hud = hud
	end,

	set = function(scene)
		entities.list = scene.entities
		entities.aboveList = scene.aboveEntities
		entities.hud = scene.hud
	end,

	--- Find the first entity matching the parameters.
	find = function(entity)
		for i, e in ipairs(entities.list) do
			if e == entity or e.__name == entity then
				return e, i
			end
		end
		for i, e in ipairs(entities.hud) do
			if e == entity or e.__name == entity then
				return e, i
			end
		end
		for i, e in ipairs(entities.aboveList) do
			if e == entity or e.__name == entity then
				return e, i
			end
		end
	end,

	update = function(dt)
		if not entities.freeze then
			for _, v in ipairs(entities.list) do
				if not v.freeze and (not entities.freezeButHyke or v.__name == "hyke") then v:update(dt) end
			end
			if not entities.disableHud and not entities.freezeButHyke then
				for _, v in ipairs(entities.hud) do
					v:update(dt)
				end
			end
		end
		for i=#entities.list, 1, -1 do
			if entities.list[i].remove == true then
				table.remove(entities.list, i)
			end
		end
		for i=#entities.hud, 1, -1 do
			if entities.hud[i].remove == true then
				table.remove(entities.hud, i)
			end
		end
		if not entities.freeze and not entities.freezeButHyke then
			for _, v in ipairs(entities.aboveList) do
				v:update(dt)
			end
		end
		for i=#entities.aboveList, 1, -1 do
			if entities.aboveList[i].remove == true then
				table.remove(entities.aboveList, i)
			end
		end
		t=t+dt

		local hyke = entities.find("hyke")
		local scrollworld = entities.find("scrollworld")

		if not entities.forceD then

			local dx, dy, sx, sy = 0, 0, 1, 1

			local w, h
			if map then
				w = map.map.width * 32
				h = map.map.height * 32
			elseif scrollworld then
				w = scrollworld.width
				h = scrollworld.height
			elseif hyke then
				w = hyke.w
				h = hyke.h
			end

			if hyke and w and h then
				dx = -math.floor(hyke.x - love.graphics.getWidth() / 2)
				if dx > 0 then dx = 0 end
				dy = -math.floor(hyke.y - love.graphics.getHeight() / 2)
				if dy > 0 then dy = 0 end

				if dx < -w + love.graphics.getWidth() then dx = -w + love.graphics.getWidth() end
				if dy < -h + love.graphics.getHeight() then dy = -h + love.graphics.getHeight() end
			end

			if entities.shake > 0 then
				dx = dx + math.sin(t*100)*entities.shake
				dy = dy + math.cos(t*100)*entities.shake
			end

			entities.dx, entities.dy, entities.sx, entities.sy = dx, dy, sx, sy
			entities.dxV, entities.dyV = entities.dxV + (dx - entities.dxV)*.3, entities.dyV + (dy - entities.dyV)*.3
		end
	end,

	draw = function()
		--love.graphics.push()

		--love.graphics.translate(entities.dxV, entities.dyV)

		if not entities.noSprites then
			for _, v in ipairs(entities.list) do
				if v.visible then v:draw(entities.dxV, entities.dyV, entities.sx, entities.sy) end
			end
		end

		for _, v in ipairs(entities.aboveList) do
			if v.visible then v:draw(entities.dxV, entities.dyV, entities.sx, entities.sy) end
			if type(v.visible) == "number" then
				v.visible = v.visible -1
				if v.visible == 0 then
					v.visible = false
				end
			end
		end

		--love.graphics.pop()

		if not entities.disableHud then
			for _, v in ipairs(entities.hud) do
				if v.visible then v:draw(entities.dxV, entities.dyV, entities.sx, entities.sy) end
			end
		end
	end
}

return entities
