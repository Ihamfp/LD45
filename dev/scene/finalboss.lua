local uqt = require("ubiquitousse")
local scene = uqt.scene

local entities = require("entities")
local shine = require("shine")
local input = require("input")
local anim8 = require("anim8")

local Image = require("entity.image")
local Text = require("entity.text")
local Rectangle = require("entity.rectangle")
local Qte = require("entity.qte")
local BgParalax = require("entity.bgparalax")
local Shockwave = require("entity.shockwave")
local Hyke = require("entity.hyke")

local start = scene.new("finalbos")
entities.reset(start)
start.effect = shine.vignette{
	radius = 1.4,
	opacity = 0.3
}

local zik = love.audio.newSource("asset/audio/Now face My Wraith.ogg", "stream")
local laser = love.audio.newSource("asset/audio/laser.wav", "static")
local unicorn = love.audio.newSource("asset/audio/diabolichorse(by XtreaGF)+unicorn mix.ogg", "static")
function start:exit()
	zik:stop()
end
function start:suspend()
	zik:stop()
end
function start:resume()
	entities.set(start)
	zik:play()
end

local bg = BgParalax:new("boss2.png", {
	ratio = 1
})
local boss = Image:new(0, 720, "boss1.png")
local hyke = Hyke:new(-75, 475, {
	h = 720, w = 500000,
	sx = 3, sy = 3,
	qteMode = true
})


local checkpoint = -1
local checkpointX, checkpointY = -75, 475
local run
function Qte.fail()
	if checkpoint > 0 then
		zik:seek(checkpoint)
		hyke.x = checkpointX
		hyke.y = checkpointY
		run()
	else
		zik:stop()
		hyke.x = checkpointX
		hyke.y = checkpointY
		run()
	end
end

-- SCRIPT
run = function()
start.time.tween(400, hyke, {
	x = 30
}):onStart(function() hyke:set("walkRight") end)
:onEnd(function()
	hyke:set("idleRight")
	Qte:new(hyke, "qte.png", input.move.right, {
		timer = 5000
	}, function()
		zik:play()
		hyke:set("walkRight")
		start.time.tween(7000, hyke, {
			x = .2*7000
		}):onEnd(function()
			hyke:set("idleRight")
			Qte:new(hyke, "qte.png", input.move.right, {
				timer = 1500,
				perfect = 1500
			}, function()
				hyke:set("walkRight")
				start.time.tween(11500, hyke, {
					x = hyke.x + .2*11500
				}):onEnd(function()
					hyke:set("idleRight")
					Qte:new(hyke, "qte.png", input.move.right, {
						timer = 2200,
						perfect = 2200
					}, function()
						hyke:set("walkRight")
						start.time.tween(9300, hyke, {
							x = hyke.x + .2*9300
						}):onEnd(function() -- 31.5
							hyke:set("idleRight")
							Qte:new(hyke, "qte.png", input.move.right, {
								timer = 1000,
								perfect = 1000
							}, function()
								hyke:set("walkRight")
								start.time.tween(6800, hyke, {
									x = hyke.x + .2*6800
								}):onEnd(function() -- 39.3
									hyke:set("idleRight")
									Qte:new(hyke, "qte.png", input.move.right, {
										timer = 1800,
										perfect = 1800
									}, function() -- 41.1
										hyke:set("walkRight")
										start.time.tween(11100, hyke, {
											x = hyke.x + .2*11100
										}):onEnd(function() -- 52.2
											hyke:set("idleRight")
											Qte:new(hyke, "qte.png", input.move.right, {
												timer = 2600,
												perfect = 2600
											}, function() -- 54.8
												hyke:set("walkRight")
												start.time.tween(9400, hyke, {
													x = hyke.x + .2*9400
												}):onEnd(function() -- 1m04.2
													hyke:set("idleRight")
													Qte:new(hyke, "qte.png", input.move.right, {
														timer = 900,
														perfect = 900
													}, function() -- 1m05.1
														--zik:play()
														--zik:seek(60+5.1)
														boss.y = 0
														boss.x = math.ceil(-entities.dxV / 1280) *1280
														hyke.w, hyke.h = nil, nil
														entities.forceD = true

														checkpoint = 60+8.1
														checkpointX = boss.x + 440
														checkpointY = hyke.y
														run = function()
															entities.dxV = -boss.x
															hyke:set("idleRight")
															local text
															start.time.run(function()
																text = Text:new("Stanberry.ttf", 25,
																"I found you.", boss.x, love.graphics.getHeight()/2-40, {
																	alignX = "center", limit = 1280,
																	alignY = "center",
																	color = { 20, 200, 20, 255},
																	shadowColor = {0,0,0,255}
																})
															end):after(900) -- 1m09
															:chain(function()
																text.text = "Indeed."
																text.color = { 230, 50, 30, 255}
															end):after(1000) -- 1m10
															:chain(function()
																text.text = "But even if you found me, you're still far from defeating me."
																text.color = { 230, 50, 30, 255}
															end):after(1000)
															:chain(function()
																text.text = "I got back each one of my worshippers."
																text.color = { 20, 200, 20, 255}
															end):after(3000)
															:chain(function()
																text.text = "Indeed."
																text.color = { 230, 50, 30, 255}
															end):after(2000) -- 1m16
															:chain(function()
																text.text = "But even if you have all your worshippers, you're still far from defeating me."
																text.color = { 230, 50, 30, 255}
															end):after(1000)
															:chain(function()
																text.text = "I can use my full power."
																text.color = { 20, 200, 20, 255}
															end):after(3000)
															:chain(function()
																text.text = "Indeed."
																text.color = { 230, 50, 30, 255}
															end):after(2000)
															:chain(function()
																text.text = "But even if you have all your power, you're still far from defeating me."
																text.color = { 230, 50, 30, 255}
															end):after(1000) -- 1m23
															:chain(function()
																text.text = "I ate apple pie today."
																text.color = { 20, 200, 20, 255}
															end):after(3000)
															:chain(function()
																text.text = "Indeed."
																text.color = { 230, 50, 30, 255}
															end):after(1300)
															:chain(function()
																text.text = "But even if you have... wait what?"
																text.color = { 230, 50, 30, 255}
															end):after(1000) -- 1m28.5
															:chain(function()
																text.text = "You've been repeating youself."
																text.color = { 20, 200, 20, 255}
															end):after(1900) -- 1m30.5
															:chain(function()
																text.text = "Indeed."
																text.color = { 230, 50, 30, 255}
															end):after(1500) -- 1m32
															:chain(function()
																text.text =
								"You need to understand, I initially planned to kill you but my musician is still searching for a more fitting music. Until then I need to buy some time."
																text.color = { 230, 50, 30, 255}
															end):after(1000) -- 1m33
															:chain(function()
																text.text = "Anyway. I, too, like apple pie."
																text.color = { 230, 50, 30, 255}
															end):after(4000) -- 1m37
															:chain(function()
																text.text = "But it's hard to find a good one around here."
																text.color = { 230, 50, 30, 255}
															end):after(2000) -- 1m39
															:chain(function()
																text.text = "I always end up buying one at-"
																text.color = { 230, 50, 30, 255}
															end):after(2000) -- 1m41
															:chain(function()
																text.text = "Oh! Apples later, it's time to..."
																text.color = { 230, 50, 30, 255}
															end):after(900) -- 1m41.9
															:chain(function()
																text.text = "KILL YOU!"
																text.color = { 230, 50, 30, 255}
															end):after(1200) -- 1m42.8
															:chain(function()
																text.visible = false
															end):after(2000) -- 1m44.8
															:chain(function()
																hyke:set("walkRight")
																start.time.tween(1000, hyke, {
																	x = hyke.x - 1000*.1
																})
															end)
															:chain(function()
																hyke:set("idleRight")
																Qte:new(hyke, "qte2.png", input.move.up, {
																	timer = 3800,
																	perfect = 3800
																}, function() -- 1m49.6
																	hyke:set("jumpRight")
																	start.time.tween(700, hyke, {
																		y = hyke.y - 700*.5
																	}, "outSine")
																	:chain(700, {
																		y = hyke.y
																	}, "inSine"):onEnd(function()
																		hyke:set("idleRight")
																	end)
																	local r
																	start.time.run(function()
																		local dx, dy = entities.dxV, entities.dyV
																		start.time.run(function()
																			entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																		end):during(400)
																		:onEnd(function()
																			entities.dxV, entities.dyV = dx, dy
																		end)
																		r = Rectangle:new(boss.x, hyke.y + 300, 1280, 200, {
																			color = { 255, 0, 0, 255 }
																		})
																		laser:play()
																	end):after(500)
																	:chain(function()
																		entities.shake = 0
																		r:remove()
																	end):after(400) -- 1m50.5
																	:chain(function()
																		Qte:new(hyke, "qte.png", input.move.right, {
																			timer = 2000,
																			perfect = 2000
																		}, function() -- 1m54.5
																			hyke:set("walkRight")
																			start.time.tween(700, hyke, {
																				x = hyke.x + 700*.5
																			}, "outSine")
																			:chain(700, {
																				x = hyke.x
																			}, "inSine"):onEnd(function()
																				hyke:set("idleRight")
																			end)
																			start.time.run(function()
																				local dx, dy = entities.dxV, entities.dyV
																				start.time.run(function()
																					entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																				end):during(400)
																				:onEnd(function()
																					entities.dxV, entities.dyV = dx, dy
																				end)
																				r = Rectangle:new(hyke.x - 300, 0, 200, 720, {
																					color = { 255, 0, 0, 255 }
																				})
																				laser:play()
																			end):after(500)
																			:chain(function()
																				entities.shake = 0
																				r:remove()
																			end):after(500) -- 1m55.5
																			:chain(function()
																				Qte:new(hyke, "qte3.png", input.move.left, {
																					timer = 2000,
																					perfect = 2000
																				}, function() -- 1m59.5
																					hyke:set("walkRight")
																					start.time.tween(700, hyke, {
																						x = hyke.x - 700*.5
																					}, "outSine")
																					:chain(700, {
																						x = hyke.x
																					}, "inSine"):onEnd(function()
																						hyke:set("idleRight")
																					end)
																					start.time.run(function()
																						local dx, dy = entities.dxV, entities.dyV
																						start.time.run(function()
																							entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																						end):during(400)
																						:onEnd(function()
																							entities.dxV, entities.dyV = dx, dy
																						end)
																						r = Rectangle:new(hyke.x + 300, 0, 200, 720, {
																							color = { 255, 0, 0, 255 }
																						})
																						laser:play()
																					end):after(500)
																					:chain(function()
																						entities.shake = 0
																						r:remove()
																					end):after(500) -- 2m00.5
																					:chain(function()
																						Qte:new(hyke, "qte2.png", input.move.up, {
																							timer = 1500,
																							perfect = 1500
																						}, function() -- 2m03.5
																							hyke:set("jumpRight")
																							start.time.tween(700, hyke, {
																								y = hyke.y - 700*.5
																							}, "outSine")
																							:chain(700, {
																								y = hyke.y
																							}, "inSine"):onEnd(function()
																								hyke:set("idleRight")
																							end)
																							start.time.run(function()
																								local dx, dy = entities.dxV, entities.dyV
																								start.time.run(function()
																									entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																								end):during(400)
																								:onEnd(function()
																									entities.dxV, entities.dyV = dx, dy
																								end)
																								r = Rectangle:new(boss.x, hyke.y + 300, 1280, 200, {
																									color = { 255, 0, 0, 255 }
																								})
																								laser:play()
																							end):after(500)
																							:chain(function()
																								entities.shake = 0
																								r:remove()
																							end):after(500) -- 2m04.5
																							:chain(function()
																								Qte:new(hyke, "qte2.png", input.move.up, {
																									timer = 1500,
																									perfect = 1500
																								}, function() -- 2m07.5
																									hyke:set("jumpRight")
																									start.time.tween(700, hyke, {
																										y = hyke.y - 700*.5
																									}, "outSine")
																									:chain(700, {
																										y = hyke.y
																									}, "inSine"):onEnd(function()
																										hyke:set("idleRight")
																									end)
																									start.time.run(function()
																										local dx, dy = entities.dxV, entities.dyV
																										start.time.run(function()
																											entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																										end):during(400)
																										:onEnd(function()
																											entities.dxV, entities.dyV = dx, dy
																										end)
																										r = Rectangle:new(boss.x, hyke.y + 300, 1280, 200, {
																											color = { 255, 0, 0, 255 }
																										})
																										laser:play()
																									end):after(500)
																									:chain(function()
																										entities.shake = 0
																										r:remove()
																									end):after(500) -- 2m08.5
																									:chain(function()
																										Qte:new(hyke, "qte.png", input.move.right, {
																											timer = 1500,
																											perfect = 1500
																										}, function() -- 2m11.5
																											hyke:set("walkRight")
																											start.time.tween(700, hyke, {
																												x = hyke.x + 700*.5
																											}, "outSine")
																											:chain(700, {
																												x = hyke.x
																											}, "inSine"):onEnd(function()
																												hyke:set("idleRight")
																											end)
																											start.time.run(function()
																												local dx, dy = entities.dxV, entities.dyV
																												start.time.run(function()
																													entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																												end):during(400)
																												:onEnd(function()
																													entities.dxV, entities.dyV = dx, dy
																												end)
																												r = Rectangle:new(hyke.x - 300, 0, 200, 720, {
																													color = { 255, 0, 0, 255 }
																												})
																												laser:play()
																											end):after(500)
																											:chain(function()
																												entities.shake = 0
																												r:remove()
																											end):after(500) -- 2m12.5
																											:chain(function()
																												Qte:new(hyke, "qte3.png", input.move.left, {
																													timer = 1000,
																													perfect = 1000
																												}, function() -- 2m14.5
																													hyke:set("walkRight")
																													start.time.tween(700, hyke, {
																														x = hyke.x - 700*.5
																													}, "outSine")
																													:chain(700, {
																														x = hyke.x
																													}, "inSine"):onEnd(function()
																														hyke:set("idleRight")
																													end)
																													start.time.run(function()
																														local dx, dy = entities.dxV, entities.dyV
																														start.time.run(function()
																															entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																														end):during(400)
																														:onEnd(function()
																															entities.dxV, entities.dyV = dx, dy
																														end)
																														r = Rectangle:new(hyke.x + 300, 0, 200, 720, {
																															color = { 255, 0, 0, 255 }
																														})
																														laser:play()
																													end):after(500)
																													:chain(function()
																														entities.shake = 0
																														r:remove()
																													end):after(500) -- 2m15.5
																													:chain(function()
																														Qte:new(hyke, "qte2.png", input.move.up, {
																															timer = 1000,
																															perfect = 1000
																														}, function() -- 2m17.5
																															hyke:set("walkRight")
																															start.time.tween(700, hyke, {
																																y = hyke.y - 700*.5
																															}, "outSine")
																															:chain(700, {
																																y = hyke.y
																															}, "inSine"):onEnd(function()
																																hyke:set("idleRight")
																															end)
																															start.time.run(function()
																																local dx, dy = entities.dxV, entities.dyV
																																start.time.run(function()
																																	entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																																end):during(400)
																																:onEnd(function()
																																	entities.dxV, entities.dyV = dx, dy
																																end)
																																r = Rectangle:new(boss.x, hyke.y + 300, 1280, 200, {
																																	color = { 255, 0, 0, 255 }
																																})
																																laser:play()
																															end):after(500)
																															:chain(function()
																																entities.shake = 0
																																r:remove()
																															end):after(500) -- 2m18.5
																															:chain(function()
																																Qte:new(hyke, "qte3.png", input.move.left, {
																																	timer = 1000,
																																	perfect = 1000
																																}, function() -- 2m20.5
																																	hyke:set("walkRight")
																																	start.time.tween(700, hyke, {
																																		x = hyke.x - 700*.5
																																	}, "outSine")
																																	:chain(700, {
																																		x = hyke.x
																																	}, "inSine"):onEnd(function()
																																		hyke:set("idleRight")
																																	end)
																																	start.time.run(function()
																																		local dx, dy = entities.dxV, entities.dyV
																																		start.time.run(function()
																																			entities.dxV, entities.dyV = dx + math.random(20), dy + math.random(20)
																																		end):during(400)
																																		:onEnd(function()
																																			entities.dxV, entities.dyV = dx, dy
																																		end)
																																		r = Rectangle:new(hyke.x + 300, 0, 200, 720, {
																																			color = { 255, 0, 0, 255 }
																																		})
																																		laser:play()
																																	end):after(500)
																																	:chain(function()
																																		entities.shake = 0
																																		r:remove()
																																	end):after(500) -- 2m21.5
																																	:chain(function()
																																		start.time.run(function()
																																			text.visible = true
																																			text.text = "Is that all you've got?"
																																			text.color = { 20, 200, 20, 255 }
																																		end) -- 1m09
																																		:chain(function()
																																			text.text = "How did you... You got help, didn't you?"
																																			text.color = { 230, 50, 30, 255}
																																		end):after(1500) -- 2m24.5
																																		:chain(function()
																																			text.text = "You're not going anywhere anyway, cheater!"
																																		end):after(2000) -- 2m26.5
																																		:chain(function()
																																			text.text = "Who would want a god such a you?"
																																		end):after(3000) -- 2m29.5
																																		:chain(function()
																																			text.text = "I've been monitoring you, while you were trying to \"regain your power\"."
																																		end):after(3000) -- 2m32.5
																																		:chain(function()
																																			text.text = "All this pain, this death you inflicted upon this world..."
																																		end):after(4000) -- 2m36.5
																																		:chain(function()
																																			text.text = "For what? Being able to order a bunch of fishes to sing?"
																																		end):after(3500) -- 2m40
																																		:chain(function()
																																			text.text = "Influence people? Why?"
																																		end):after(3500) -- 2m43.5
																																		:chain(function()
																																			text.text = "You have everything you need here."
																																		end):after(2500) -- 2m46
																																		:chain(function()
																																			text.text = "Well, unless popcorn, but it's for the best."
																																		end):after(2800) -- 2m48.8
																																		:chain(function()
																																			text.text = "SHUT UP! Now you're goind to suffer..."
																																			text.color = { 20, 200, 20, 255 }
																																		end):after(2500) -- 2m51.3
																																		:chain(function()
																																		end):after(2500)
																																		:onEnd(function()
																																			text.visible = false
																																			Qte:new(hyke, "qte4.png", input.unicorn, {
																																				timer = 5000,
																																				perfect = 5000
																																			}, function() -- 2m54.3
																																				local dx, dy = entities.dxV, entities.dyV
																																				start.time.run(function()
																																					entities.dxV, entities.dyV = dx + math.random(70) * (math.random() >0.5 and 1 or -1), dy + math.random(70) * (math.random() >0.5 and 1 or -1)
																																				end):during(6000)
																																				:onEnd(function()
																																					entities.dxV, entities.dyV = dx, dy
																																				end)
																																				Shockwave:new(hyke.x+64, hyke.y+64, powerIcons.data[11])
																																				unicorn:play()
																																				local rect = Rectangle:new(boss.x, 0, 1280, 720, {
																																					color = {255,255,255,0}
																																				})
																																				scene.current.time.tween(2000, rect.color, {[4]=255}):after(4000)
																																				:onEnd(function()
																																					scene.current.time.tween(500, rect.color, {0,0,0,255})
																																					local Sprite = require("entity.sprite")
																																					local VFX = Sprite {
																																						__name = "vfx",

																																						new = function(self, x, y, image, n, t, options)
																																							Sprite.new(self, x, y, options)

																																							self.image.def = love.graphics.newImage("asset/sprite/"..image)
																																							local g = anim8.newGrid(self.image.def:getWidth()/n, self.image.def:getHeight(), self.image.def:getWidth(), self.image.def:getHeight())
																																							self.animation.def = anim8.newAnimation(g("1-"..n,1), 2)

																																							self:set("def")

																																							scene.current.time.run(function()
																																								self.visible = false
																																							end):after(t)
																																						end
																																					}
																																					VFX:new(boss.x,0,"earth.png",2,3500)
																																					scene.current.time.run(function()
																																						local t1  = Text:new("LemonMilk.otf", 72, "Thank you for playing.", boss.x, love.graphics.getHeight()/2, {
																																							limit = 1270,
																																							alignX = "center", alignY = "center",
																																							color = { 255, 255, 255, 255 }
																																						})
																																					end):after(4000)
																																				end)
																																			end)
																																		end)
																																	end):after(1500) -- 2m23
																																end)
																															end):after(1000) -- 2m19.5
																														end)
																													end):after(1000) -- 2m16.5
																												end)
																											end):after(1000) -- 2m13.5
																										end)
																									end):after(1500) -- 2m10
																								end)
																							end):after(1500) -- 2m06
																						end)
																					end):after(1500) -- 2m02
																				end)
																			end):after(2000) -- 1m57.5
																		end)
																	end):after(2000) -- 1m52.5
																end)
															end):after(1000) -- 1m45.8
														end

														hyke:set("walkRight")
														start.time.tween(3000, hyke, {
															x = boss.x + 440
														})
														start.time.tween(3000, entities, {
															dxV = -boss.x
														}):onEnd(function() -- 1m08.1
															run()
														end)
													end)
												end)
											end)
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end)
end

local rect = Rectangle:new(0, 0, 1280, 720, {
	color = {255,255,255,255}
})
start.time.tween(2000, rect.color, {[4]=0})
	:onEnd(function()
		run()
	end)


return start
