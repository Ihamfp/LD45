local uqt = require("ubiquitousse")
local scene = uqt.scene

local shine = require("shine")
local entities = require("entities")

local hubmap = scene.new("hubmap")
entities.reset(hubmap)
hubmap.effect = shine.vignette{
	radius = 1.3,
	opacity = 0.4
}

local wifi

local Background = require("entity.background")
local Rectangle = require("entity.rectangle")
local Pointer = require("entity.pointer")
local LevelSelect = require("entity.hub.levelSelect")
local PowerIcon = require("entity.hub.powericon")
local Text = require("entity.text")
local Mortal = require("entity.hub.mortal")
local IcoBoss = require("entity.hub.bossicon")

-- ASSETS
local zik = love.audio.newSource("asset/audio/Miracle in progress.ogg", "stream")
zik:setLooping(true)
zik:play()
function hubmap:suspend()
	zik:stop()
end
function hubmap:exit()
	zik:stop()
end
function hubmap:resume()
	entities.set(self)
	entities.shake = 0
	zik:play()
	local rect = Rectangle:new(0, 0, 1280, 720, {
		color = {255,255,255,255}
	})
	hubmap.time.tween(1000, rect.color, {[4]=0})
end
local freewifi = love.audio.newSource("asset/audio/freewifi.wav", "static")

-- DATA

local population = {
	-- totals
	believers = 0,
	total = 25000,
	popularity = 0,

	-- per area
	city = {
		562, 211, 148, 206,
		wifi = true,
		population = 25000,
		believers = 0
	},
	forest = {
		397, 571, 416, 188,
		wifi = false,
		popularity = 1000,
		believers = 0,
		population = 0,
		mortals = {}
	},
	stonehedge = {
		957, 401, 246, 260,
		wifi = false,
		popularity = 0,
		believers = 0,
		population = 0,
		mortals = {}
	},
	volcano = {
		552, 45, 275, 125,
		wifi = false,
		popularity = 0,
		believers = 0,
		population = 0,
		mortals = {}
	},
	desert = {
		974, 0, 305, 210,
		wifi = false,
		popularity = 0,
		believers = 0,
		population = 0,
		mortals = {}
	},
	sea = {
		120, 340, 100, 400,
		wifi = false,
		popularity = 0,
		believers = 0,
		population = 0,
		mortals = {}
	}
}

-- luacheck: ignore powerIcons
powerIcons = { data = {} }
powerIcons.data = {
	{
		815, 605,
		cooldown = 2,
		minBelievers = 0,
		believers = 20,
		death = 0,
		error = 0.1,

		unlockIn = "forest",
		unlockName = "power1",
		unlockZik = "In quest of Power.ogg",

		zones = {
			{ "forest", 1 }
		},

		title = "Spark",
		description = "An awesome trick to show your friends! Mostly harmless.",

		shockwave = {
			radius = 10, width = 50,
			duration = 400, finalRadius = 100,
			shake = 2, shakeDuration = 50
		},
		sfx = "fire.wav",
		vfx = "spark.png", vfxX = 560, vfxY = 590
	},
	{
		1215, 490,
		cooldown = 15,
		minBelievers = 10,
		believers = 100,
		death = 1,
		error = 0.05,

		unlockIn = "stonehenge",
		unlockName = "power1",
		unlockZik = "In quest of Power.ogg",

		zones = {
			{ "stonehedge", 1 },
			{ "city", 0.1 },
			{ "desert", 0.1 },
			{ "forest", 0.1 }
		},

		title = "Thunderbolt",
		description = "Perfect way to lit your grill. 100 meters security distance required.",

		shockwave = {
			radius = 10, width = 75,
			duration = 700, finalRadius = 500,
			shake = 10, shakeDuration = 200
		},
		sfx = "lightning.wav",
		vfx = "lightning.png", vfxX = 1055, vfxY = 420
	},
	{
		20, 340,
		cooldown = 30,
		minBelievers = 70,
		believers = 300,
		death = 10,
		error = 0.02,

		unlockIn = "sea",
		unlockName = "power1",
		unlockZik = "In quest of Power.ogg",

		zones = {
			{ "sea", 1 },
			{ "city", 0.1 },
			{ "volcano", 0.1 },
			{ "forest", 0.1 }
		},

		title = "Sea-split",
		description = "An old classic, prevent everyone in a given area from fishing.",

		shockwave = {
			radius = 10, width = 100,
			duration = 1500, finalRadius = 600,
			shake = 5, shakeDuration = 1000
		},
		sfx = "sea.wav",
		vfx = "seasplit.png", vfxX = 0, vfxY = 0
	},
	{
		1100, 275,
		cooldown = 15,
		minBelievers = 200,
		believers = 400,
		death = 32,
		error = 0.1,

		unlockIn = "desert",
		unlockName = "power1",
		unlockZik = "In quest of Power.ogg",

		zones = {
			{ "desert", 1 },
			{ "city", 0.15 },
			{ "volcano", 0.15 },
			{ "stonehedge", 0.15 },
			{ "forest", 0.05 },
			{ "sea", 0.05 }
		},

		title = "Tornado",
		description = "Woooosh... WHOOOOSH ! WOOOOOSH !!!! WOOOOOOOOSH !!!!!!!!",

		shockwave = {
			radius = 10, width = 200,
			duration = 1000, finalRadius = 1000,
			shake = 15, shakeDuration = 700
		},
		sfx = "tornado.wav",
		vfx = "tornado.png", vfxX = 1080, vfxY = 60
	},
	{
		675, 105,
		cooldown = 25,
		minBelievers = 700,
		believers = 700,
		death = 55,
		error = 0.11,

		unlockIn = "volcano1",
		unlockName = "power1",
		unlockZik = "In quest of Power.ogg",

		zones = {
			{ "volcano", 1 },
			{ "city", 0.25 },
			{ "desert", 0.25 },
			{ "stonehedge", 0.25 },
			{ "forest", 0.15 },
			{ "sea", 0.15 }
		},

		title = "Volcanic boom",
		description = "Don't forget your umbrella! And fire extinguisher. And running away.",

		shockwave = {
			radius = 10, width = 250,
			duration = 2000, finalRadius = 800,
			shake = 20, shakeDuration = 1500
		},
		sfx = "volcanicboom.wav",
		vfx = "volcano.png", vfxX = 670, vfxY = 0
	},
	{
		730, 350,
		cooldown = 300,
		minBelievers = 700,
		believers = 10,
		death = 100,
		error = 0.01,

		didThePlatform = true,

		zones = {
			{ "city", 1 }
		},

		condition = function(self)
			return powerIcons[5].unlocked
		end,

		customAction = function(self)
			for zoneName, zone in pairs(population) do
				if type(zone) == "table" then
					zone.wifi = false
					wifi[zoneName].visible = false
				end
			end
		end,

		title = "Godzilla",
		description = "Regular looking antenna eating monster. Also likes to eat people.\nBut mostly antennas.",

		shockwave = {
			radius = 10, width = 100,
			duration = 1500, finalRadius = 700,
			shake = 20, shakeDuration = 600
		},
		sfx = "godzilla.wav",
		vfx = "godzilla.png", singleVfx = true, vfxX = 0, vfxY = 0
	},
	{
		70, 340,
		cooldown = 120,
		minBelievers = 1000,
		believers = 600,
		death = 1,
		error = 0.03,

		unlockIn = "sea",
		unlockName = "power2",
		unlockZik = "In_quest_of_Power_reprise.ogg",

		zones = {
			{ "sea", 1 },
			{ "city", 0.15 },
			{ "volcano", 0.15 },
			{ "forest", 0.15 },
			{ "stonehedge", 0.05 },
			{ "desert", 0.05 }
		},

		title = "Fish Choregraphy",
		description = "Some fishes may lose control and savagely attack the audience. Other than that, it looks nice.",

		shockwave = {
			radius = 10, width = 200,
			duration = 2500, finalRadius = 1000,
			shake = 10, shakeDuration = 500
		},
		sfx = "fish.wav",
		vfx = "fish.png", vfxX = 0, vfxY = 580
	},
	{
		1150, 275,
		cooldown = 20,
		minBelievers = 3000,
		believers = 700,
		death = 15,
		error = 0.05,

		unlockIn = "desert",
		unlockName = "power2",
		unlockZik = "In_quest_of_Power_reprise.ogg",

		zones = {
			{ "desert", 1 },
			{ "city", 0.2 },
			{ "stonehedge", 0.2 },
			{ "volcano", 0.2 },
			{ "forest", 0.1 },
			{ "sea", 0.1 }
		},

		title = "Sandman",
		description = "Like a regular snowman but with sand. And 100 feet tall.",

		shockwave = {
			radius = 10, width = 200,
			duration = 1000, finalRadius = 1150,
			shake = 10, shakeDuration = 700
		},
		sfx = "sandman.wav",
		vfx = "sandman.png", singleVfx = true, vfxX = 1060, vfxY = 5
	},
	{
		1215, 540,
		cooldown = 35,
		minBelievers = 7000,
		believers = 800,
		death = 20,
		error = 0.02,

		unlockIn = "stonehenge",
		unlockName = "power2",
		unlockZik = "In_quest_of_Power_reprise.ogg",

		zones = {
			{ "stonehedge", 1 },
			{ "city", 0.1 },
			{ "desert", 0.1 },
			{ "volcano", 0.1 }
		},

		title = "Flying Stonehenge",
		description = "In a way, you just invented the elevator, without the security measures.",

		shockwave = {
			radius = 10, width = 200,
			duration = 1500, finalRadius = 600,
			shake = 15, shakeDuration = 700
		},
		sfx = "stonehedge.wav",
		vfx = "stonehenge.png", vfxX = 1040, vfxY = 400
	},
	{
		725, 105,
		cooldown = 45,
		minBelievers = 10000,
		believers = 1000,
		death = 50,
		error = 0.01,

		unlockIn = "volcano2",
		unlockName = "power2",
		unlockZik = "In_quest_of_Power_reprise.ogg",

		zones = {
			{ "volcano", 1 },
			{ "city", 0.5 },
			{ "stonehedge", 0.5 },
			{ "desert", 0.5 },
			{ "forest", 0.25 },
			{ "sea", 0.25 }
		},

		title = "Pop-corn boom",
		description = "Like an eruption but 33.33% tastier. No artificial flavoring, gluten-free.",

		shockwave = {
			radius = 10, width = 255,
			duration = 5000, finalRadius = 900,
			shake = 30, shakeDuration = 2000
		},
		sfx = "popcornboom.wav",
		vfx = "popcorn.png", vfxX = 670, vfxY = 0
	},
	{
		815, 655,
		cooldown = 18400,
		minBelievers = 15000,
		believers = 25000,
		death = 200,
		error = 0.5,

		unlockIn = "forest",
		unlockName = "power2",
		unlockZik = "In_quest_of_Power_reprise.ogg",

		zones = {
			{ "desert", 1 },
			{ "city", 1 },
			{ "volcano", 1 },
			{ "stonehedge", 1 },
			{ "forest", 1 },
			{ "sea", 1 }
		},

		title = "Flying Rainbow Laser Unicorn",
		description = "OH MY FUCKING GOD A FLYING RAINBOW UNICORN! WITH LASERS!",

		shockwave = {
			radius = 10, width = 255,
			duration = 16000, finalRadius = 1300,
			shake = 70, shakeDuration = 6000
		},
		sfx = "diabolichorse(by XtreaGF)+unicorn mix.ogg",
		vfx = "UNICORN.png", singleVfx = true, vfxX = 0, vfxY = 0, vfxT = 6000
	}
}

-- ENTITIES

local bg = Background:new("world1.png")
wifi = {
	forest = Background:new("world2.png", {visible = false}),
	sea = Background:new("world3.png", {visible = false}),
	city = Background:new("world4.png"),
	volcano = Background:new("world5.png", {visible = false}),
	desert = Background:new("world6.png", {visible = false}),
	stonehedge = Background:new("world7.png", {visible = false})
}

--local tower = LevelSelect:new(662, 211, 48, 206, "finalboss")
--[[local forest = LevelSelect:new(397, 571, 416, 188, "platLevels.forest")
local stoneh = LevelSelect:new(957, 401, 246, 260, "platLevels.stonehenge")
local desent = LevelSelect:new(974, 0, 305, 210, "platLevels.desert")
local volcano = LevelSelect:new(652, 38, 175, 131, "start")
]]
local power = Text:new("Stanberry.ttf", 25, "Power: unfathomable", 10, 10, {
	color = { 0, 0, 0, 255 },
	shadowColor = { 255, 255, 255, 255 },
	update = function(self, dt)
		self.text = "Power: "..math.exp(population.believers/40)
	end
})
local believerS = Text:new("Stanberry.ttf", 25, "Worshippers: so many I lost count", 10, 42, {
	color = { 0, 0, 0, 255 },
	shadowColor = { 255, 255, 255, 255 },
	update = function(self, dt)
		self.text = "Worshippers: "..math.min(population.believers, population.total).."/"..population.total
	end
})

for i=1, 11 do
	powerIcons[i] = PowerIcon:new(powerIcons.data[i][1], powerIcons.data[i][2], "powerico"..i..".png", population, powerIcons.data[i])
end

local icoBoss = IcoBoss:new(population)

local cursor = Pointer:new()

-- SCRIPT
for zoneName, zone in pairs(population) do
	if type(zone) == "table" and zone.mortals then
		local function go()
			hubmap.time.run(function()
				if scene.current.name == "hubmap" then
					if math.random() <= 1/5 then
						for i=1, 5 do
							if population.city.population > 0 then
								Mortal:new(population, zoneName)
							end
						end
						while zone.population > 500 do
							zone.mortals[1]:goBack()
							table.remove(zone.mortals, 1)
						end
					end
				end
			end):after(math.max(5000 - zone.popularity, 50))
			:onEnd(go)
		end
		go()
	end
	if type(zone) == "table" then
		local function go()
			local inter = 60000
			if not powerIcons[6].unlocked then
				inter = 30000
			end
			hubmap.time.run(function()
				if math.random() <= 1/5 then
					if not zone.wifi and powerIcons[2].unlocked then
						zone.wifi = true
						wifi[zoneName].visible = true
						freewifi:play()
					end
				end
			end):after(inter)
			:onEnd(go)
		end
		go()

		function go()
			hubmap.time.run(function()
				if math.random() <= 1/5 then
					if zone.wifi then
						local newPop = math.max(zone.believers-10, 0)-zone.believers
						if newPop ~= 0 then
							local deaths = Text:new("Stanberry.ttf", 20, "-"..(newPop).." worshippers (free WiFi)", zone[1], zone[2] + zone[4]/2, {
								limit = zone[3], alignX = "center",
								color = { 230, 50, 30, 0 },
								shadowColor = {0, 0, 0, 0}
							})
							scene.current.time.tween(500, deaths, {
								y = zone[2] -30,
							}, "outCubic")
							scene.current.time.tween(500, deaths.color, { 230, 50, 30, 255}, "outCubic")
								:chain(500, {230, 50, 30, 0}):after(1000)
							scene.current.time.tween(500, deaths.shadowColor, {0,0,0,255}, "outCubic")
								:chain(500, {0,0,0,0}):after(1000)

							if zone.mortals then
								local believersToConvert = -newPop
								for _, m in ipairs(zone.mortals) do
									if believersToConvert > 0 and m.believe then
										m:unconvert()
										believersToConvert = believersToConvert -1
									end
								end
							end
						end
						zone.believers = zone.believers + newPop
					end
				end
			end):after(30000)
			:onEnd(go)
		end
		go()
	end
end

local rect = Rectangle:new(0, 0, 1280, 720, {
	color = {255,255,255,255}
})
hubmap.time.tween(700, rect.color, {[4]=0})

return hubmap
