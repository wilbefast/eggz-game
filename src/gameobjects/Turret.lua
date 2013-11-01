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
TURRET GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Turret = Class
{
  type = GameObject.TYPE.new("Turret"),

  ENERGY_DRAW_SPEED = 0,              -- per second
  ENERGY_CONSUME_SPEED = 0,           -- per second
  ENERGY_DRAW_EFFICIENCY = 0,       -- percent
  ENERGY_START = 1,
  MAX_W = 24,
  MAX_H = 24,

  IDLE = 1,
  WARMUP = 2,
  ATTACK = 3,
  COOLDOWN = 4,

  ARMOUR = 3,

  maturationTime = 8, -- seconds
  child_energy = 1,

  ATTACK_ENERGY_COST = 0,--0.1,
  ATTACK_WARMUP_DURATION = 0.4,
  ATTACK_DURATION = 0.3,
  ATTACK_COOLDOWN_DURATION = 0.8,
  ATTACK_DAMAGE = 0.4,

  REGEN_EFFICIENCY = 1,

  CAN_BE_STUNNED = true,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
    
    -- set state
    self.state = Turret.IDLE
    self.timer = 0

    -- animation
    self.subimage = 1

    -- set guard area
    self.guardArea = GameObject.COLLISIONGRID:getNeighbours8(tile)
		
		-- target tile whose occupant will be damaged
		self.targetTile = nil
	
    -- progression of projectile from 0 to 1
    self.projectileProgress = 0
    
  end,
}
Turret:include(Plant)
Turret.class = Turret

--[[------------------------------------------------------------
Resources
--]]--


Turret.IMAGES = 
{
  {
    love.graphics.newImage("assets/red_tower_1.png"),
    love.graphics.newImage("assets/red_tower_2.png"),
    projectile = love.graphics.newImage("assets/RED_attack.png")
  },
  {
    love.graphics.newImage("assets/blue_tower_1.png"),
    love.graphics.newImage("assets/blue_tower_2.png"),
    projectile = love.graphics.newImage("assets/BLUE_attack.png")
  },
  {
    love.graphics.newImage("assets/yellow_tower_1.png"),
    love.graphics.newImage("assets/yellow_tower_2.png"),
    projectile = love.graphics.newImage("assets/YELLOW_attack.png")
  },
  {
    love.graphics.newImage("assets/purple_tower_1.png"),
    love.graphics.newImage("assets/purple_tower_2.png"),
    projectile = love.graphics.newImage("assets/PURPLE_attack.png")
  }
}



Turret.ANIMATIONS = {}
for i = 1, 4 do
  Turret.ANIMATIONS[i] = {}
  Turret.ANIMATIONS[i].charge = Animation(Turret.IMAGES[i].projectile, 64, 64, 5, 0, 0)
  Turret.ANIMATIONS[i].projectile = Animation(Turret.IMAGES[i].projectile, 64, 64, 1, 320, 0)
  Turret.ANIMATIONS[i].impact = Animation(Turret.IMAGES[i].projectile, 64, 64, 4, 384, 0)
end

--[[------------------------------------------------------------
Take damage
--]]--

function Turret:die()
  Plant.die(self)
  audio:play_sound("KNIGHT-destroyed")
end

function Turret:takeDamage(amount, attacker, ignoreArmour)
  Plant.takeDamage(self, amount, attacker, ignoreArmour)

  if attacker and (not self.aggro) then
    self.aggro = attacker
  end
end

--[[------------------------------------------------------------
State machine
--]]--

Turret.state_update = { }


--[[--
IDLE
--]]--
Turret.state_update[Turret.IDLE] = function(self, dt)
  -- fight
  if (#(self.enemies) > 0) 
  and (self.energy >= Turret.ATTACK_ENERGY_COST) then
    self.state = Turret.WARMUP
    audio:play_sound("KNIGHT-attack1", 0.2)
    SpecialEffect(self.tile.x+32, self.tile.y+33, 
            Turret.ANIMATIONS[self.player].charge, 13, 0, 20)
    self.subimage = 2
    self.energy = self.energy - Turret.ATTACK_ENERGY_COST
    self.timer = 0
  end
end

--[[--
WARMUP
--]]--
Turret.state_update[Turret.WARMUP] = function(self, dt)

  if #(self.enemies) == 0 then
    self.timer = 0
    self.state = Turret.IDLE
    self.subimage = 1

  elseif self.timer > self.ATTACK_WARMUP_DURATION then
    audio:play_sound("KNIGHT-attack2", 0.3)
    -- NB: here self.enemies is guaranteed not to be empty
    self.targetTile = (self.aggro or useful.randIn(self.enemies)).tile 
    self.state = Turret.ATTACK
    self.projectileProgress = 0.01
    self.subimage = 1
    self.timer = 0
  end
end

--[[--
ATTACK
--]]--
Turret.state_update[Turret.ATTACK] = function(self, dt)
  if self.timer > self.ATTACK_DURATION then
    self.state = Turret.COOLDOWN
    self.timer = 0
  end
end

--[[--
COOLDOWN
--]]--
Turret.state_update[Turret.COOLDOWN] = function(self, dt)
  if self.timer > self.ATTACK_COOLDOWN_DURATION then
    self.state = Turret.IDLE
    self.timer = 0
  end
end

--[[------------------------------------------------------------
Game loop
--]]--

function Turret:update(dt)

  Plant.update(self, dt)

  if not self.stunned then

    -- if 'aggro' still alive?
    if self.aggro and self.aggro.purge then
      self.aggro = nil
    end

    -- check for enemies
    self.enemies = {}
    for _, t in pairs(self.guardArea) do
      if t.occupant and (t.occupant.player ~= self.player) and (t.occupant.player ~= 0) then
        table.insert(self.enemies, t.occupant)
      end
    end

    -- update timer
    self.timer = self.timer + dt

    -- act according to state
    Turret.state_update[self.state](self, dt)
		
		-- update projectile
    if self.projectileProgress > 0 then
      if self.projectileProgress > 1 then
        -- deal damage if target hasn't escaped
        if self.targetTile.occupant then
          self.targetTile.occupant:takeDamage(self.ATTACK_DAMAGE, self)
        end
        -- show special effect in any case
        SpecialEffect(self.targetTile.x+32, self.targetTile.y+33, Turret.ANIMATIONS[self.player].impact, 7, 0, 20)
        audio:play_sound("KNIGHT-attack-hit", 0.1)
        -- reset projectile progress
        self.projectileProgress = 0
      else
        self.projectileProgress = self.projectileProgress + 5*dt
      end
    end
  end
end

function Turret:draw_projectile()
  local projectNearness, projectileFarness = (1 - self.projectileProgress), self.projectileProgress
  local x = self.tile.x*projectNearness + (self.targetTile.x)*projectileFarness
  local y = self.tile.y*projectNearness + (self.targetTile.y)*projectileFarness - 20
  Turret.ANIMATIONS[self.player].projectile:draw(x, y)
end

function Turret:draw(x, y)

  x, y = x or self.x, y or self.y
	
	-- if (not self.stunned) and self.targetTile and (self.targetTile.y < y) and self.lightning.visible then
	-- 	
	-- end


  -- draw sprite
  if self.energy < self.ATTACK_ENERGY_COST then
    love.graphics.setColor(128, 128, 128)
  end
  love.graphics.draw(Turret.IMAGES[self.player][self.subimage], x, y,
    0, 1, 1, 32, 50)

  -- draw stun overlay
  if self.stunned then
    love.graphics.draw(Plant.IMG_STUN, x, y, 0, 1, 1, 32, 32)
  end

  -- draw projectile
  if self.projectileProgress > 0 then
    self:draw_projectile()
  end
  
  -- draw overlay
  Plant.draw(self)

end

--[[------------------------------------------------------------
Export
--]]--

return Turret