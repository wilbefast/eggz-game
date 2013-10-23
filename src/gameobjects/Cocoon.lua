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

  init = function(self, tile, player, evolvesTo, evolvesFrom)
    Plant.init(self, tile, player)
    self.maturity = 0
    self.evolvesTo = evolvesTo
    self.evolvesFrom = (evolvesFrom or Egg)
    self.maturationTime = evolvesTo.maturationTime
    self.soundIsStarted = false

    self.view = AnimationView(Cocoon.ANIMS[self.player], 6, 1, 32, 50)
  end,
}
Cocoon:include(Plant)
Cocoon.class = Cocoon

--[[------------------------------------------------------------
Resources
--]]--

Cocoon.IMAGES =
{
  {
    love.graphics.newImage("assets/red_egg_d.png"),
    love.graphics.newImage("assets/blue_egg_d.png"),
    love.graphics.newImage("assets/yellow_egg_d.png"),
    love.graphics.newImage("assets/purple_egg_d.png")
  },
  love.graphics.newImage("assets/WHITE-egg.png")
}

Cocoon.ANIMS = {}
for i = 1, #(Cocoon.IMAGES[1]) do
  Cocoon.ANIMS[i] = Animation(Cocoon.IMAGES[1][i], 64, 64, 6)
end

-- default: recycle only
Cocoon.EVOLUTION_ICONS =
{
  nil,
  { 
    love.graphics.newImage("assets/menu_cancel.png"), 
    love.graphics.newImage("assets/menu_cancel_hover.png")
  },
  nil,
}

--[[------------------------------------------------------------
Game loop
--]]--

function Cocoon:update(dt)
  Plant.update(self, dt)

  self.view:update(dt)

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

function useful.arc(centrex, centrey, radius, starta, enda, segments)
  segments = (segments or 10)

  if starta > enda then
    local swap = starta
    starta = enda
    enda = swap
  end

  local x, y
  local angle_step = (enda - starta)/segments
  for i = 1, segments+1 do
    local angle = starta + angle_step*(i-1)
    local new_x, new_y = centrex + math.cos(angle)*radius, centrey + math.sin(angle)*radius
    if (x and y) then
      love.graphics.line(x, y, new_x, new_y)
    end
    x, y = new_x, new_y
  end
end

function Cocoon:draw(x, y)

  x, y = x or self.x, y or self.y

  -- love.graphics.draw(Cocoon.IMAGES[1][self.player], x, y,
  --   0, 1, 1, 32, 50)
  self.view:draw(self)

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
        0, 1, 1, 32, 50)
      love.graphics.setColor(255, 255, 255, 255)
    end
  end

  -- how evolved is it
  --player[self.player].bindTeamColour()
  love.graphics.setLineWidth(2)
  local arc = math.pi*(-0.5 + math.max(0, math.min(2, 2*(self.maturity/self.maturationTime))))
    useful.arc(self.x, self.y, 20, -math.pi*0.5, arc, 15)

  -- what is this evolving to ?
  love.graphics.setColor(255, 255, 255, 128+64*math.cos(game.overlords[self.player].wave*0.3))
    love.graphics.draw(self.evolvesTo.ICON, self.x, self.y, 0, 1, 1, 18, 18)

  -- reset
  love.graphics.setColor(255, 255, 255)

  -- draw overlay
  Plant.draw(self)
end

--[[------------------------------------------------------------
Export
--]]--

return Cocoon