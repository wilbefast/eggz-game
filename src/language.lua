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

local languages = {}

current_language = 1

--[[---------------------------------------------------------------------------
LANGUAGE 1 - 'STRALIAN
--]]

languages[1] = 
{
	flag = love.graphics.newImage("assets/languages/australia.png"),
	initials = "EN",
	title = { "Versus", "Language", "Creggits", "Quit" },
	credits = 
	{ 
		title = "Creggits", 
		{ what = "Design and programming", who = "William 'Wilbefast' Dyce" },
		{ what = "Graphics and sound", who = "Barth 'Nyrlem' Frey" }
	},
	player_select =
	{
		title = "Versus",
		humans = "Humans",
		robots = "Robots",
		coming_soon = "Coming soon ..."
	},
	colour = { "Red", "Blue", "Yellow", "Purple" },
	wins = "wins!"
}


--[[---------------------------------------------------------------------------
LANGUAGE 2 - FRENCH
--]]

languages[2] = 
{
	flag = love.graphics.newImage("assets/languages/france.png"),
	initials = "FR",
	title = { "Duel", "Langue", "Credits", "Quitter" },
	credits = 
	{ 
		title = "Credits", 
		{ what = "Concept et development", who = "William 'Wilbefast' Dyce" },
		{ what = "Graphismes et son", who = "Barth 'Nyrlem' Frey" }
	},
	player_select =
	{
		title = "Duel",
		humans = "Humains",
		robots = "Robots",
		coming_soon = "A venir ..."
	},
	colour = { "Rouge", "Bleu", "Jaune", "Violet" },
	wins = "gagne!"
}

return languages