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

--[[------------------------------------------------------------
EGG GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Egg = Class
{
  type = GameObject.TYPE.new("Egg"),

  ENERGY_DRAW_SPEED = 0.3, 				-- per second
  ENERGY_CONSUME_SPEED = 0.01, 		-- per second
  ENERGY_DRAW_EFFICIENCY = 0.3, 	-- percent
  MAX_W = 32,
  MAX_H = 32,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
  end,
}
Egg:include(Plant)


--[[------------------------------------------------------------
Game loop
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Egg