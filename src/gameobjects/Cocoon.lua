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
COCOON GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Cocoon = Class
{
  type = GameObject.TYPE.new("Cocoon"),

  ENERGY_DRAW_SPEED = 0.0,            -- per second
  ENERGY_CONSUME_SPEED = 0,           -- per second
  ENERGY_DRAW_EFFICIENCY = 0.0,       -- percent
  ENERGY_START = 0,
  MAX_W = 24,
  MAX_H = 24,

  ARMOUR = 1,

  init = function(self, tile, player, evolvesTo)
    Plant.init(self, tile, player)
    self.maturity = 0
    self.evolvesTo = evolvesTo
  end,
}
Cocoon:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Cocoon.IMAGES =
{
  {
    love.graphics.newImage("assets/RED-egg-D.png"),
    love.graphics.newImage("assets/BLUE-egg-D.png")
  },
  love.graphics.newImage("assets/WHITE-egg.png")
}

--[[------------------------------------------------------------
Game loop
--]]--

function Cocoon:update(dt)
  Plant.update(self, dt)

  self.maturity = self.maturity + 0.1*dt
  if self.maturity > 1 then
    self.purge = true
    self.evolvesTo(self.tile, self.player)
  end
end

function Cocoon:draw()

  love.graphics.draw(Cocoon.IMAGES[1][self.player], self.x, self.y,
    0, 1, 1, 32, 40)
  if self.maturity*3 > 2 then
    love.graphics.setColor(255, 255, 255, (self.maturity*3-2)*255)
      love.graphics.draw(Cocoon.IMAGES[2], self.x, self.y,
      0, 1, 1, 32, 40)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Cocoon