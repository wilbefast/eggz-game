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
  ENERGY_START = 1,
  MAX_W = 24,
  MAX_H = 24,

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
    self.convertArea = GameObject.COLLISIONGRID:getNeighbours4(tile, true) -- center
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
Game loop
--]]--

function Convertor:update(dt)

  Plant.update(self, dt)

  self.view:update(dt)

  for _, tile in pairs(self.convertArea) do
    tile:convert(0.3*dt, self.player)
  end
end

function Convertor:draw()
  self.view:draw(self)
end

--[[------------------------------------------------------------
Export
--]]--

return Convertor