--[[
(C) Copyright 2013 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

local language = {}

current_language = 1

--[[---------------------------------------------------------------------------
LANGUAGE 1 - 'STRALIAN
--]]

language[1] = 
{
	flag = love.graphics.newImage("assets/languages/australia.png"),
	initials = "EN",
	title = { "Versus", "Controls", "Tutorial", "Language", "Creggits", "Quit" },
	howtoplay = 
	{
		title = "Tutorial",
		"Press to lay, pick and drop eggz.",
		"Eggz mature faster on fertile land.",
		"Hold to evolve mature eggz.",
		"Statues attack nearby foes.",
		"Shrines convert the area.",
		"Hold to pour acid.",
		"Convert 50% of the map to win!"
	},
	controls = 
	{
		title = "Controls"
	},
	credits = 
	{ 
		title = "Creggits", 
		{ what = "Design and programming", who = "William 'Wilbefast' Dyce" },
		{ what = "Graphics and sound", who = "Barth 'Nyrlem' Frey" }
	},
	player_select =
	{
		title = "Versus",
		humans = "Human",
		robots = "A.I.",
		coming_soon = "Coming soon ..."
	},
	colour = { "Red", "Blue", "Yellow", "Purple" },
	wins = "wins!",
	tutorial =
	{
		lay = "tap to lay",
		pick = "tap to grab",
		grow = "blah",
		evolve = "hold to evolve"
	}
}


--[[---------------------------------------------------------------------------
LANGUAGE 2 - FRENCH
--]]

language[2] = 
{
	flag = love.graphics.newImage("assets/languages/france.png"),
	initials = "FR",
	title = { "Versus", "Contrôles", "Tutoriel", "Langue", "Credits", "Quitter" },
	howtoplay = 
	{
		title = "Tutoriel",
		"Appuyer pour pondre, prendre et déposer les oeufs.",
		"Les oeufs grandissent plus vite sur du terrain fertile.",
		"Maintenir enfoncé pour evolver un oeuf mature.",
		"Les statues attaquent tout enemi proche.",
		"Les lieux saints convertissent du terrain.",
		"Maintenir enfoncé pour verser de l'acide.",
		"Convertir 50% du terrain pour gagner !"
	},
	controls = 
	{
		title = "Contrôles"
	},
	credits = 
	{ 
		title = "Credits", 
		{ what = "Concept et development", who = "William 'Wilbefast' Dyce" },
		{ what = "Graphismes et son", who = "Barth 'Nyrlem' Frey" }
	},
	player_select =
	{
		title = "Versus",
		humans = "Humain",
		robots = "I.A.",
		coming_soon = "À venir ..."
	},
	colour = { "Rouge", "Bleu", "Jaune", "Violet" },
	wins = "gagne!"
}

return language