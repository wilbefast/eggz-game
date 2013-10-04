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

  MATURATION_SPEED = 1,

  ARMOUR = 4,

  init = function(self, tile, player, evolvesTo)
    Plant.init(self, tile, player)
    self.maturity = 0
    self.evolvesTo = evolvesTo
    self.maturationTime = evolvesTo.maturationTime
    self.soundIsStarted = false
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
    love.graphics.newImage("assets/BLUE-egg-D.png"),
    love.graphics.newImage("assets/YELLOW-egg-D.png"),
    love.graphics.newImage("assets/PURPLE-egg-D.png")
  },
  love.graphics.newImage("assets/WHITE-egg.png")
}

-- default: recycle only
Cocoon.EVOLUTION_ICONS =
{
  nil,
  { 
    love.graphics.newImage("assets/radial_cancel_Y.png"), 
    love.graphics.newImage("assets/radial_cancel_hl_Y.png")
  },
  nil,
}

--[[------------------------------------------------------------
Game loop
--]]--

function Cocoon:update(dt)
  Plant.update(self, dt)

  if not self.stunned then
    self.maturity = self.maturity + dt*self.MATURATION_SPEED
    if self.maturity > self.maturationTime then
      self.purge = true
      local evolution = self.evolvesTo(self.tile, self.player)
      evolution.hitpoints = self.hitpoints
      if self.child_energy then
        evolution.energy = self.child_energy
      end
    end
    end
end

function Cocoon:draw(x, y)

  x, y = x or self.x, y or self.y

  love.graphics.draw(Cocoon.IMAGES[1][self.player], x, y,
    0, 1, 1, 32, 50)

  if self.stunned then
    love.graphics.draw(Plant.IMG_STUN, x, y, 0, 1.2, -1.2, 32, 20)
  else
    local finishedness = (self.maturity - 0.66*self.maturationTime) / (0.34*self.maturationTime)
    if finishedness > 0 then -- over 66%
      -- play sound
      if self.maturity >= self.maturationTime-1 and not self.soundIsStarted then
        audio:play_sound("EGG-hatch")
        self.soundIsStarted = true
      end

      -- Pokemon evolution effect (tm)
      love.graphics.setColor(255, 255, 255, finishedness*255)
        love.graphics.draw(Cocoon.IMAGES[2], x, y,
        0, 1, 1, 32, 40)
      love.graphics.setColor(255, 255, 255, 255)
    end
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Cocoon