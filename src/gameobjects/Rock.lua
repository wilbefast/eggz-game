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
Rock GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Rock = Class
{
  type = GameObject.TYPE.new("Rock"),

  ENERGY_DRAW_SPEED = 0.0, 						-- per second
  ENERGY_CONSUME_SPEED = 0, 		      -- per second
  ENERGY_DRAW_EFFICIENCY = 0.0, 			-- percent
  ENERGY_START = 0,
  ACCELERATION_MODIFIER = 0.1,
  MAX_W = 24,
  MAX_H = 24,

  invulnerable = true,
  canBeUprooted = true,

  init = function(self, tile)
    Plant.init(self, tile, 0)
    self.player = 0
  end,
}
Rock:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Rock.IMAGES = 
{
  love.graphics.newImage("assets/ROCK.png"),
  love.graphics.newImage("assets/ROCK-carry.png")
}

--[[------------------------------------------------------------
Resources
--]]--

function Rock:uproot(transport)
  Plant.uproot(self, transport)
  audio:play_sound("EGG-pick")
end

function Rock:plant(tile)
  Plant.plant(self, tile)
  tile.conversion = 0
  tile.owner = 0
  audio:play_sound("EGG-drop") --FIXME
end

--[[------------------------------------------------------------
Game loop
--]]--

function Rock:draw(x, y)
  x, y = x or self.x, y or self.y

  if self.transport then
    return
  end
  love.graphics.draw(Rock.IMAGES[1], x, y, 0, 1, 1, 32, 40)

  -- draw overlay
  Plant.draw(self)
end

function Rock:drawTransported(x, y)
  x, y = x or self.x, y or self.y
  love.graphics.draw(Rock.IMAGES[2], x, y, 0, 1, 1, 24, 64)
end

--[[------------------------------------------------------------
Export
--]]--

return Rock