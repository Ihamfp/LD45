local uqt = require("ubiquitousse")
local scene = uqt.scene

local shine = require("shine")
local entities = require("entities")

local Text = require("entity.text")

local s = scene.new("intro")
entities.reset(s)
s.effect = shine.vignette{
	radius = 1.1,
	opacity = 0.3
}

local credits = Text:new("LemonMilk.otf", 32, [[HYKOTRON








Un jeu formidable


Par des gens formidables


Pour des gens formidables

















Idée originale par Lenade Lamidedi et Étienne Fildadut




Conception de l'acte I par Lenade Lamidedi et Simon Émile Béranger




Conception de l'acte II et III par Étienne Fildadut











Programmation par Étienne Fildadut




Art par Étienne Fildadut




Doublage et musique de l'introduction par Lenade Lamidedi









Musique du reste par Jean Michel Silence




Dialogues du vieux par Jean Michel Stéréotype




Animation de bouche par Jean Michel Stylepic-Ture




Synonymes par Wiktionnaire




Bêta test final par Simon Émile Béranger




Autres bêta tests par Lenade Lamidedi







Dialogue de MrHyke par MrHyke







Fotes d'ortografe par Étiene Fildaut






Correction des dites fotes par Leande Lamdiedi










Idées non implémentées par Lenade Lamide et Simon Émile Béranger












To be continued... (Lenade, arrête tes conneries!)













" C'était une expérience formidable, ça a duré 4 jours "
			- Étienne Fildadut







" Il y a pas moyen d'avoir plus d'explosions ? "
			- Lenade Lamidedi




" Si ça rend comme dans ma tête, on est en train de faire le meilleur jeu de l'univers "
			- Étienne Fildadut




" ah, un détail, le tube n'est pas percé dans le jeu, par conséquent, les bulletins ne peuvent pas être repoussés "
			- Simon Émile Béranger




" Ouais c'est bon j'ai fait des traits, on va dire que c'est des trous. "
			- Étienne Fildadut




" C'était pas mal, mais ça manque d'explosions. "
			- Lenade Lamidedi








" Et tu peux pas mettre des explosions dans le générique ? "
			- Lenade Lamidedi







" Non. "
			- Le vieux qui répond au générique










Merci d'avoir supporté ce jeu.














Cordialement.
]], 30, love.graphics.getHeight() + 50, {
	limit = love.graphics.getWidth() - 60,
	alignX = "center", alignY = "top"
})

local jvc2020 = Text:new("LemonMilk.otf", 32, [[" first try
excellent jeu
20/20
https://giphy.com/gifs/happy-yes-P0RWkdsRpK7ss "
			- Le vrai Lord Hypington the IIIrd, 11 avril 2017 à 14h48
]], love.graphics.getWidth()/2, love.graphics.getHeight()/2 -64, {
	alignX = "center", alignY = "center",
	color = { 255, 255, 255, 0 }
})

s.time.tween(10000*14, credits, {
	y = -720*15
}, "linear")
:chain(750, jvc2020, {
	color = { 255, 255, 255, 255 }
}, "inOutQuad")
:chain(750, jvc2020, {
	color = { 255, 255, 255, 0 }
}, "inOutQuad"):after(5000)
:onEnd(function()
	scene.switch("intro")
end)

return s
