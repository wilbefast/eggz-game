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

  ENERGY_DRAW_SPEED = 0.003,            -- per second
  ENERGY_CONSUME_SPEED = 0,           -- per second
  ENERGY_DRAW_EFFICIENCY = 0.7,       -- percent
  ENERGY_START = 1,
  MAX_W = 24,
  MAX_H = 24,

  maturationTime = 10, -- seconds
  child_energy = 1,

  ARMOUR = 0,

  IMAGES = 
  {
    love.graphics.newImage("assets/RED-fountain-anim.png"),
    love.graphics.newImage("assets/BLUE-fountain-anim.png")
  },

  init = function(self, tile, player)
    Plant.init(self, tile, player)

    self.view = AnimationView(Convertor.ANIMS[self.player], 7, 0, 32, 32)

    -- set guard area
    self.convertArea = GameObject.COLLISIONGRID:getNeighbours4(tile) -- center
  end,
}
Convertor:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Convertor.ANIMS = {}
for i = 1, #Convertor.IMAGES do
  Convertor.ANIMS[i] = Animation(Convertor.IMAGES[i], 64, 64, 5)
end


--[[------------------------------------------------------------
Take damage
--]]--

function Convertor:die()
  audio:play_sound("FOUNTAIN-destroyed")
end


--[[------------------------------------------------------------
Game loop
--]]--

function Convertor:update(dt)

  Plant.update(self, dt)

  if (self.energy >= 0.1) and (not stunned) then
    self.view:update(dt)

    -- convert surrounding area
    for _, tile in pairs(self.convertArea) do
      tile:convert(3*dt*(1/#self.convertArea), self.player)
    end

    -- convert center tile faster
    self.tile:convert(3*dt, self.player)
  end
end

function Convertor:draw()

  if self.energy < 0.1 then
    love.graphics.setColor(96, 96, 96)
  end
  self.view:draw(self)
  love.graphics.setColor(255, 255, 255)

  if self.stunned then
    love.graphics.draw(Plant.IMG_STUN, self.x, self.y, 0, 0.8, 0.8, 32, 18)
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Convertor