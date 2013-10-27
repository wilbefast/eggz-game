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

  ENERGY_DRAW_SPEED = 0.0, 						-- per second
  ENERGY_CONSUME_SPEED = 0, 		      -- per second
  ENERGY_DRAW_EFFICIENCY = 0.0, 			-- percent
  ENERGY_START = 0,
  MAX_W = 24,
  MAX_H = 24,

  maturationTime = 16, -- seconds

  uses = 3,

  init = function(self, tile)
    Plant.init(self, tile, 0)
    self.player = 0
  end,
}
Bomb:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Bomb.IMAGES = 
{
  love.graphics.newImage("assets/BOMB.png"),
  love.graphics.newImage("assets/BOMB-carry.png")
}

Bomb.EXPLODE_IMG = love.graphics.newImage("assets/FX-bomb.png")

Bomb.EXPLODE_ANIM = Animation(Bomb.EXPLODE_IMG , 64, 64, 6)

--[[------------------------------------------------------------
Resources
--]]--

function Bomb:uproot(transport)
  Plant.uproot(self, transport)
  audio:play_sound("EGG-pick")
end

function applyStun(tile, t)
	if tile.occupant then
		tile.occupant:stun(t)
	end
end

function Bomb:drop(tile)

  if self.transport then --and tile.occupant then
    
    -- deduct one use
    self.uses = self.uses - 1
    if self.uses == 0 then
      self.purge = true
      self.transport.passenger = nil
    end

    -- visual queue
    SpecialEffect(self.x, self.y+1, Bomb.EXPLODE_ANIM, 7, 0, 12)

    -- audio queue
    log:write("DROP")
    audio:play_sound("BOMB-dropped", 0.1)

    -- apply effect to the tile
    tile.acidity = 1

  else
    Plant.plant(self, tile)
    audio:play_sound("EGG-drop") --FIXME
  end
end

--[[------------------------------------------------------------
Game loop
--]]--

function Bomb:draw(x, y)
  x, y = x or self.x, y or self.y

  if self.transport then
    return
  end
  love.graphics.draw(Bomb.IMAGES[1], x, y,
    0, 1, 1, 32, 40)

  -- draw overlay
  Plant.draw(self)
end

function Bomb:drawTransported(x, y)
  x, y = x or self.x, y or self.y
  love.graphics.draw(Bomb.IMAGES[2], x, y,
    0, 1, 1, 24, 64)
end

--[[------------------------------------------------------------
Export
--]]--

return Bomb