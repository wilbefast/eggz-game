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

local player = {}
player[1] = {}
player[2] = {}
player[3] = {}



--[[---------------------------------------------------------------------------
PLAYER 1 - RED
--]]

player[1] = 
{
	-- red
	bindTeamColour = function (a) love.graphics.setColor(255, 0, 0, a or 255) end,
	-- right middle
	startPosition = 
	{ 
		x = 64*11 - 32,  	
		y = 64*6 - 32 	
	},
	total_conversion = 0
}


--[[---------------------------------------------------------------------------
PLAYER 2 - BLUE
--]]

player[2] = 
{
	-- blue
	bindTeamColour = function (a) love.graphics.setColor(0, 0, 255, a or 255) end,
	-- left middle
	startPosition = 
  { 
  	x = 32, 					
  	y = 64*6 - 32
	},
	total_conversion = 0
}


--[[---------------------------------------------------------------------------
PLAYER 3 - YELLOW
--]]

player[3] = 
{
	-- yellow
	bindTeamColour = function (a) love.graphics.setColor(255, 0, 255, a or 255) end,
	-- top middle
	startPosition = 
  { 
  	x = 64*6 - 32, 		
  	y = 32        	
	},
	total_conversion = 0
}


--[[---------------------------------------------------------------------------
PLAYER 4 - VIOLET
--]]

player[4] = 
{
	-- violet
	bindTeamColour = function (a) love.graphics.setColor(255, 255, 0, a or 255) end,
	-- bottom middle
	startPosition =
  { 
  	x = 64*6 - 32, 		
  	y = 64*11 - 32 	
	},
	total_conversion = 0
}

--[[---------------------------------------------------------------------------
EXPORT
--]]

return player