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

  -- defaults
  REGEN_SPEED = 0.1,
  REGEN_EFFICIENCY = 0.1,
  maturationTime = 1,

  init = function(self, tile, player)
    GameObject.init(self, tile.x + tile.w/2, tile.y + tile.h/2, 
    											self.MAX_W, self.MAX_H)

    self:plant(tile)

    self.energy = self.ENERGY_START
    self.hitpoints = (self.HITPOINTS_START or 1)
    self.stunned = false
		
		self.eat = AnimationView(Plant.ANIM_EAT, 16.0, 0, 32, 40)
		self.eat.amount = 1

    self.player = player
  end,
}
Plant:include(GameObject)
Plant.class = Plant

--[[------------------------------------------------------------
Resources
--]]--

Plant.IMG_STUN = love.graphics.newImage("assets/FX-chains.png")
Plant.IMG_EAT = love.graphics.newImage("assets/FX-eat.png")
Plant.ANIM_EAT = Animation(Plant.IMG_EAT, 64, 64, 5, 0, 0)

-- default: recycle only
Plant.EVOLUTION_ICONS =
{
  nil,
  { 
    love.graphics.newImage("assets/menu_recycle.png"), 
    love.graphics.newImage("assets/menu_recycle_hover.png")
  },
  nil,
}

--[[------------------------------------------------------------
Evolve
--]]--

function Plant:canEvolve()
	return (self.EVOLUTION and (not self.stunned)) -- override me!
end

--[[------------------------------------------------------------
Take damage
--]]--

function Plant:die()
	--override me
end

function Plant:takeDamage(amount, attacker)
	self.hitpoints = self.hitpoints - amount/(1 + self.ARMOUR)
	if self.hitpoints < 0 then
		self.purge = true
		self.tile.energy = math.min(1, self.energy/self.ENERGY_DRAW_EFFICIENCY)
		self.tile.occupant = nil
		self:die()
	end
end

function Plant:stun(n_seconds)
	if self.CAN_BE_STUNNED then
		self.stunned = n_seconds
		--self.energy = 0
	end
end

--[[------------------------------------------------------------
Pick up and put down
--]]--

function Plant:plant(tile)
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

  -- Unstunned -------------------------------------------------------
  if self.stunned then
  	self.stunned = self.stunned - dt
  	if self.stunned <= 0 then
  		self.stunned = false
  	end
  end

  -- Planted ? ------------------------------------------------------
  if self.tile then

  	-- On enemy territory
		if (self.tile.conversion > 0.5) and (self.tile.owner ~= self.player) then
			self.energy = math.max(0, self.energy - 0.1*dt)
			if self.energy == 0 then
				-- stopped conversion
				--self.player = self.tile.owner
			end
		else
			-- Not stunned ?
			if (not self.stunned) then
			  -- Draw energy ------------------------------------------------------
			  local drawn_energy = math.min(self.tile.energy, 
			  															self.ENERGY_DRAW_SPEED*self.tile.energy*self.tile.energy*dt)
																		
				self.eat.amount = (drawn_energy/(self.ENERGY_DRAW_SPEED*dt))
				self.eat:update(dt * (0.2 + 0.8 * self.eat.amount))
 
			  -- Regenerate ------------------------------------------------------
			  local regen = math.min(math.min(drawn_energy, self.REGEN_SPEED*dt), 
			  											(1 - self.hitpoints)/self.REGEN_EFFICIENCY)
			  drawn_energy = drawn_energy - regen
			  self.tile.energy = self.tile.energy - regen
			  self.hitpoints = self.hitpoints + regen*self.REGEN_EFFICIENCY

			  -- Store energy not consume by regeneration ------------------------
			  if drawn_energy + self.energy > 1 then
			  	drawn_energy = 1 - self.energy
			  end
			  self.tile.energy = self.tile.energy - drawn_energy
			  self.energy = math.min(1, self.energy 
			  						+ drawn_energy*self.ENERGY_DRAW_EFFICIENCY)

			  -- Consume energy ------------------------------------------------------
			  self.energy = math.max(0, self.energy - self.ENERGY_CONSUME_SPEED*dt)
		  end
	  end
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Plant