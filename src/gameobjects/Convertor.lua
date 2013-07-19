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
CONVERTOR GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Convertor = Class
{
  type = GameObject.TYPE.new("Convertor"),

  ENERGY_DRAW_SPEED = 0.1,            -- per second
  ENERGY_CONSUME_SPEED = 0,           -- per second
  ENERGY_DRAW_EFFICIENCY = 0.7,       -- percent
  ENERGY_START = 0,
  MAX_W = 24,
  MAX_H = 24,

  maturity = 0,
  MATURE_SPEED = 0.1,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
  end,
}
Convertor:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Convertor.IMAGES = 
{
  {
    love.graphics.newImage("assets/RED-knight-01.png"),
    love.graphics.newImage("assets/RED-knight-02.png")
  },
  {
    love.graphics.newImage("assets/BLUE-knight-01.png"),
    love.graphics.newImage("assets/BLUE-knight-02.png")
  }
}

--[[------------------------------------------------------------
Game loop
--]]--

function Convertor:draw()
  love.graphics.draw(Convertor.IMAGES[self.player][1], self.x, self.y,
    0, 1, 1, 32, 40)
end

--[[------------------------------------------------------------
Export
--]]--

return Convertor