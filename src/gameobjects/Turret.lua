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

  ENERGY_DRAW_SPEED = 0.3,              -- per second
  ENERGY_CONSUME_SPEED = 0,           -- per second
  ENERGY_DRAW_EFFICIENCY = 15,       -- percent
  ENERGY_START = 1,
  MAX_W = 24,
  MAX_H = 24,

  IDLE = 1,
  WARMUP = 2,
  ATTACK = 3,
  COOLDOWN = 4,

  ARMOUR = 3,

  ATTACK_ENERGY_COST = 0.1,
  ATTACK_WARMUP_DURATION = 0.4,
  ATTACK_DURATION = 0.3,
  ATTACK_COOLDOWN_DURATION = 0.8,
  ATTACK_DAMAGE = 0.4,

  REGEN_SPEED = 0.01,
  REGEN_EFFICIENCY = 1,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
    
    -- set state
    self.state = Turret.IDLE
    self.timer = 0

    -- animation
    self.subimage = 1

    -- set guard area
    self.guardArea = GameObject.COLLISIONGRID:getNeighbours8(tile)
    
  end,
}
Turret:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--

Turret.IMAGES = 
{
  {
    love.graphics.newImage("assets/RED-knight-01.png"),
    love.graphics.newImage("assets/RED-knight-02.png")
  },
  {
    love.graphics.newImage("assets/BLUE-knight-01.png"),
    love.graphics.newImage("assets/BLUE-knight-02.png")
  }
}

Turret.ATTACK_IMG = love.graphics.newImage("assets/FX-attack.png")
Turret.ATTACK_ANIM = Animation(Turret.ATTACK_IMG, 36, 36, 6, 0, 0)


--[[------------------------------------------------------------
Take damage
--]]--

function Turret:die()
  audio:play_sound("KNIGHT-destroyed")
end

--[[------------------------------------------------------------
State machine
--]]--

Turret.state_update = { }

Turret.state_update[Turret.IDLE] = function(self, dt)
  -- fight
  if (#(self.enemies) > 0) 
  and (self.energy >= Turret.ATTACK_ENERGY_COST) then
    self.state = Turret.WARMUP
    audio:play_sound("KNIGHT-attack1", 0.2)
    self.subimage = 2
    self.energy = self.energy - Turret.ATTACK_ENERGY_COST
    self.timer = 0
  end
end

Turret.state_update[Turret.WARMUP] = function(self, dt)

  if #(self.enemies) == 0 then
    self.timer = 0
    self.state = Turret.IDLE
  elseif self.timer > self.ATTACK_WARMUP_DURATION then
    audio:play_sound("KNIGHT-attack2", 0.3)
    local who = useful.randIn(self.enemies)
    who:takeDamage(self.ATTACK_DAMAGE)
    self.state = Turret.ATTACK
    self.subimage = 1
    self.timer = 0
  end
end

Turret.state_update[Turret.ATTACK] = function(self, dt)
  if self.timer > self.ATTACK_DURATION then
    self.state = Turret.COOLDOWN
    self.timer = 0
  end
end

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
    -- check for enemies
    self.enemies = {}
    for _, t in pairs(self.guardArea) do
      if t.occupant and (t.occupant.player ~= self.player) and (not t.occupant:isType("Bomb")) then
        table.insert(self.enemies, t.occupant)
      end
    end

    -- update timer
    self.timer = self.timer + dt

    -- act according to state
    Turret.state_update[self.state](self, dt)
  end
end

function Turret:draw()
  love.graphics.draw(Turret.IMAGES[self.player][self.subimage], self.x, self.y,
    0, 1, 1, 32, 40)

    if self.stunned then
      love.graphics.draw(Plant.IMG_STUN, self.x, self.y, 0, 1, 1, 32, 32)
    end
end

--[[------------------------------------------------------------
Export
--]]--

return Turret