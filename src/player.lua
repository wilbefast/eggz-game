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


--[[---------------------------------------------------------------------------
PLAYER 1 - RED
--]]

player[1] = 
{
	-- red
	name = "Red",
	bindTeamColour = function (a) love.graphics.setColor(255, 0, 0, a or 255) end,
	-- top right
	startPosition = 
	{ 
		x = TILE_W*(N_TILES_ACROSS - 2.5),  	
		y = TILE_W*2.5
	},
	-- top right
	ui =
	{
		x = TILE_W*(N_TILES_ACROSS + 1.5), 
		y = 0
	}

}


--[[---------------------------------------------------------------------------
PLAYER 2 - BLUE
--]]

player[2] = 
{
	-- blue
	name = "Blue",
	bindTeamColour = function (a) love.graphics.setColor(0, 120, 255, a or 255) end,
	-- top left
	startPosition = 
  { 
  	x = TILE_W*2.5, 					
  	y = TILE_H*2.5
	},

	-- top left
	ui =
	{
		x = -1.5*TILE_W, 
		y = 0
	}
}


--[[---------------------------------------------------------------------------
PLAYER 3 - YELLOW
--]]

player[3] = 
{
	-- yellow
	name = "Yellow",
	bindTeamColour = function (a) love.graphics.setColor(255, 255, 0, a or 255) end,
	-- bottom left
	startPosition = 
  { 
  	x = TILE_W*2.5, 		
  	y = TILE_H*(N_TILES_DOWN - 2.5)       	
	},
	-- bottom left
	ui =
	{
		x = -1.5*TILE_W,
		y = TILE_W*(N_TILES_DOWN - 1)
	}
}


--[[---------------------------------------------------------------------------
PLAYER 4 - PURPLE
--]]

player[4] = 
{
	-- purple
	name = "Purple",
	bindTeamColour = function (a) love.graphics.setColor(160, 0, 255, a or 255) end,
	-- bottom right
	startPosition =
  { 
  	x = TILE_W*(N_TILES_ACROSS - 2.5), 		
  	y = TILE_H*(N_TILES_DOWN - 2.5) 	
	},
	-- bottom right
	ui =
	{
		x = TILE_W*(N_TILES_ACROSS + 1.5), 
		y = TILE_H*(N_TILES_DOWN - 1)
	}
}

--[[---------------------------------------------------------------------------
EXPORT
--]]

return player