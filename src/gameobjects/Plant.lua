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
PLANT GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Plant = Class
{
  type = GameObject.TYPE.new("Plant"),

  init = function(self, tile, player)
    GameObject.init(self, tile.x + tile.w/2, tile.y + tile.h/2, 
    											self.MAX_W, self.MAX_H)

    self:plant(tile)

    self.energy = self.ENERGY_START
    self.hitpoints = self.HITPOINTS_START

    self.player = player
  end,
}
Plant:include(GameObject)


--[[------------------------------------------------------------
Take damage
--]]--

function Plant:takeDamage(amount)
	SpecialEffect(self.x, self.y+1, Turret.ATTACK_ANIM, 7)
	audio:play_sound("KNIGHT-attack-hit", 0.1)
	self.hitpoints = self.hitpoints - amount
	if self.hitpoints < 0 then
		self.purge = true
		self.tile.occupant = nil
	end
end

--[[------------------------------------------------------------
Pick up and put down
--]]--

function Plant:plant(tile)
	audio:play_sound("EGG-drop")
	if self.transport then
		self.transport.passenger = nil
		self.transport = nil
	end
	if self.tile then
		self.tile.occupant = nil
	end
	self.tile = tile
  self.x, self.y = tile.x + tile.w/2, tile.y  + tile.h/2
	tile.occupant = self
end

function Plant:uproot(transport)
	audio:play_sound("EGG-pick")
	if self.transport then
		self.transport.passenger = nil
	end
	if self.tile then
		self.tile.occupant = nil
		self.tile = nil
	end
	self.transport = transport
	transport.passenger = self
end


--[[------------------------------------------------------------
Game loop
--]]--

function Plant:update(dt)
  GameObject.update(self, dt)

  self.w = self.MAX_W * self.energy
  self.h = self.MAX_H * self.energy

  -- Planted? ------------------------------------------------------
  if self.tile then

	  -- Draw energy ------------------------------------------------------
	  local energy_drawn = math.min(self.tile.energy, 
	  															self.ENERGY_DRAW_SPEED*self.tile.energy*self.tile.energy*dt)
	  if energy_drawn + self.energy > 1 then
	  	energy_drawn = 1 - self.energy
	  end
	  self.tile.energy = self.tile.energy - energy_drawn
	  self.energy = math.min(1, self.energy 
	  						+ energy_drawn*self.ENERGY_DRAW_EFFICIENCY)

	  -- Consume energy ------------------------------------------------------
	  self.energy = math.max(0, self.energy - self.ENERGY_CONSUME_SPEED*dt)

	else
		-- Being moved? ------------------------------------------------------
	end
end

--[[------------------------------------------------------------
Export
--]]--

return Plant