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
BOMB GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Bomb = Class
{
  type = GameObject.TYPE.new("Bomb"),

  ENERGY_DRAW_SPEED = 0.1, 						-- per second
  ENERGY_CONSUME_SPEED = 0,--0.01, 		-- per second
  ENERGY_DRAW_EFFICIENCY = 0.7, 			-- percent
  ENERGY_START = 0, --0.3
  MAX_W = 24,
  MAX_H = 24,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
  end,
}
Bomb:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Bomb.IMAGES = 
{
  love.graphics.newImage("assets/BOMB.png"),
}

--[[------------------------------------------------------------
Game loop
--]]--

function Bomb:draw()

  love.graphics.draw(Bomb.IMAGES[1], self.x, self.y,
    0, 1, 1, 32, 40)

end

--[[------------------------------------------------------------
Export
--]]--

return Bomb