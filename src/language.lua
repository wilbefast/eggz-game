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
	initials = "EN"
}


--[[---------------------------------------------------------------------------
LANGUAGE 2 - FRENCH
--]]

languages[2] = 
{
	flag = love.graphics.newImage("assets/languages/france.png"),
	initials = "FR"
}

return languages