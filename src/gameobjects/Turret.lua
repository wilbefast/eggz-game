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
TURRET GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Turret = Class
{
  type = GameObject.TYPE.new("Turret"),

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
    self.guardArea = GameObject.COLLISIONGRID:getNeighbours8(tile)
  end,
}
Turret:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Turret.IMAGES = 
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

function Turret:draw()
  love.graphics.draw(Turret.IMAGES[self.player][1], self.x, self.y,
    0, 1, 1, 32, 40)

  for i, v in pairs(self.guardArea) do
    love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Turret