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
  ENERGY_START = 0,
  MAX_W = 24,
  MAX_H = 24,

  IDLE = 1,
  WARMUP = 2,
  ATTACK = 3,
  COOLDOWN = 4,

  ATTACK_ENERGY_COST = 0.1,
  ATTACK_WARMUP_DURATION = 0.4,
  ATTACK_DURATION = 0.3,
  ATTACK_COOLDOWN_DURATION = 0.8,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
    
    -- set state
    self.state = Turret.IDLE
    self.timer = 0

    -- animation
    self.subimage = 1

    -- set guard area
    self.guardArea = GameObject.COLLISIONGRID:getNeighbours8(tile)
    self.guardArea_x = self.x
    local endx = self.x
    self.guardArea_y = self.y
    local endy = self.y
    for _, t in pairs(self.guardArea) do
      love.graphics.rectangle("line", t.x, t.y, t.w, t.h)
      self.guardArea_x = math.min(self.guardArea_x, t.x)
      endx = math.max(endx, t.x + t.w)
      self.guardArea_y = math.min(self.guardArea_y, t.y)
      endy = math.max(endy, t.y + t.h)
    end
    self.guardArea_w = endx - self.guardArea_x
    self.guardArea_h = endy - self.guardArea_y
    
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

--[[------------------------------------------------------------
State machine
--]]--

Turret.state_update = { }

Turret.state_update[Turret.IDLE] = function(self, dt)
  if self.enemies > 0 and (self.energy >= Turret.ATTACK_ENERGY_COST) then
    self.state = Turret.WARMUP
    audio:play_sound("KNIGHT-attack1", 0.25)
    self.subimage = 2
    self.energy = self.energy - Turret.ATTACK_ENERGY_COST
    self.timer = 0
  end
end

Turret.state_update[Turret.WARMUP] = function(self, dt)
  if self.timer > self.ATTACK_WARMUP_DURATION then
    audio:play_sound("KNIGHT-attack2", 0.25)
    audio:play_sound("KNIGHT-attack-hit", 0.25)
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

  -- check for enemies
  self.enemies = 0
  for _, t in pairs(self.guardArea) do
    if t.occupant and (t.occupant.player ~= self.player) then
      self.enemies = self.enemies + 1
    end
  end

  -- update timer
  self.timer = self.timer + dt

  -- act according to state
  Turret.state_update[self.state](self, dt)
end

function Turret:draw()
  love.graphics.draw(Turret.IMAGES[self.player][self.subimage], self.x, self.y,
    0, 1, 1, 32, 40)
  player.bindTeamColour[self.player]()
    love.graphics.rectangle("line", self.guardArea_x, self.guardArea_y, 
      self.guardArea_w, self.guardArea_h)
  love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]--

return Turret