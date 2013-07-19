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
EGG GAMEOBJECT
--]]------------------------------------------------------------

local Egg = Class
{
  type = GameObject.TYPE.new("Egg"),

  ENERGY_DRAW_SPEED = 0.1, 				-- per second
  ENERGY_CONSUME_SPEED = 0.03, 				-- per second
  ENERGY_DRAW_EFFICIENCY = 0.3, 	-- percent

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 16, 16)

    self.tile = GameObject.COLLISIONGRID:pixelToTile(self.x, self.y)
    self.tile.occupant = self

    self.energy = 0.3

    self.player = player
  end,
}
Egg:include(GameObject)


function Egg:update(dt)
  GameObject.update(self, dt)

  self.w = 32 * self.energy
  self.h = 32 * self.energy

  -- Draw energy ------------------------------------------------------
  local energy_drawn = math.min(self.tile.energy, self.ENERGY_DRAW_SPEED*dt)
  if energy_drawn + self.energy > 1 then
  	energy_drawn = 1 - self.energy
  end
  self.tile.energy = self.tile.energy - energy_drawn
  self.energy = math.min(self.energy + energy_drawn*self.ENERGY_DRAW_EFFICIENCY, 1)

  -- Consume energy ------------------------------------------------------
  self.energy = math.max(0, self.energy - self.ENERGY_CONSUME_SPEED*dt)

end

function Egg:draw()
	player.bindTeamColour[self.player]()
		love.graphics.rectangle("fill", 
			self.x + 32 - self.w/2, self.y + 32 - self.w/2, self.w, self.h)
		love.graphics.rectangle("line", 
			self.x + 16, self.y + 16, 32, 32)	
	love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]

return Egg