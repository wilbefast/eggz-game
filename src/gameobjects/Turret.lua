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

  maturationTime = 8, -- seconds
  child_energy = 1,

  ATTACK_ENERGY_COST = 0.1,
  ATTACK_WARMUP_DURATION = 0.4,
  ATTACK_DURATION = 0.3,
  ATTACK_COOLDOWN_DURATION = 0.8,
  ATTACK_DAMAGE = 0.4,

  REGEN_SPEED = 0.01,
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
		
		-- target to damage on animation end
		self.target = nil
	
	-- lightning
	self.lightning = AnimationView(Turret.LIGHTNING_ANIM, 10.0, 0, 30, 54)
	self.lightning.offx, self.lightning.offy = 24, 50
	
    
  end,
}
Turret:include(Plant)

--[[------------------------------------------------------------
Resources
--]]--


Turret.IMAGES = 
{
  {
    love.graphics.newImage("assets/red_tower_1.png"),
    love.graphics.newImage("assets/red_tower_2.png")
  },
  {
    love.graphics.newImage("assets/blue_tower_1.png"),
    love.graphics.newImage("assets/blue_tower_2.png")
  },
  {
    love.graphics.newImage("assets/yellow_tower_1.png"),
    love.graphics.newImage("assets/yellow_tower_2.png")
  },
  {
    love.graphics.newImage("assets/purple_tower_1.png"),
    love.graphics.newImage("assets/purple_tower_2.png")
  }
}

Turret.ATTACK_IMG = love.graphics.newImage("assets/FX-attack.png")
Turret.ATTACK_ANIM = Animation(Turret.ATTACK_IMG, 36, 36, 6, 0, 0)
Turret.LIGHTNING_IMG = love.graphics.newImage("assets/FX-attack-bolt.png")
Turret.LIGHTNING_ANIM = Animation(Turret.LIGHTNING_IMG, 128, 64, 5, 0, 0)
Turret.LAUCNH_IMG = love.graphics.newImage("assets/FX-attack-launch.png")
Turret.LAUNCH_ANIM = Animation(Turret.LAUCNH_IMG, 64, 64, 3, 0, 0)


--[[------------------------------------------------------------
Take damage
--]]--

function Turret:die()
  audio:play_sound("KNIGHT-destroyed")
end

function Turret:takeDamage(amount, attacker)
  Plant.takeDamage(self, amount, attacker)
  if not self.aggro then
    self.aggro = attacker
  end
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
		--SpecialEffect(self.x, self.y+1, Turret.LAUNCH_ANIM, 7, 0, 20)
    self.target = (self.aggro or useful.randIn(self.enemies))
    self.state = Turret.ATTACK
    self.subimage = 1
    self.timer = 0
		self.lightning.frame = 1
		self.lightning.visible = true
		
		if self.target.x == self.x then
			-- in line vertically
			if ((self.target.y < self.y) and not (self.target.y < self.y - 196)) or self.target.y > self.y + 196 then -- KLUDGE
				-- above => 90 degrees
				self.lightning.angle = -math.pi*0.5
			else
				-- below => -90 degrees
				self.lightning.angle = math.pi*0.5
			end
		else
			-- not in line vertically
			if self.target.y == self.y then
				-- in line horizontally
				if ((self.target.x < self.x) and not (self.target.x < self.x - 196)) or self.target.x > self.x + 196 then
					-- left => 180 degrees
					self.lightning.angle = math.pi
				else
					-- right => 0 degrees
					self.lightning.angle = 0
				end
			else
			
				-- not in line horizontally
				if ((self.target.x < self.x) and not (self.target.x < self.x - 196)) or self.target.x > self.x + 196 then
					-- West
					if ((self.target.y < self.y) and not (self.target.y < self.y - 196)) or self.target.y > self.y + 196 then
						-- North-west => 135 degree
						self.lightning.angle = math.pi*1.25
					else
						-- South-west => 225 degree
						self.lightning.angle = math.pi*0.75
					end
				else
					-- East
					if ((self.target.y < self.y) and not (self.target.y < self.y - 196)) or self.target.y > self.y + 196 then
						-- North-east => 45 degree
						self.lightning.angle = -math.pi*0.25
					else
						-- South-east => -45 degree
						self.lightning.angle = math.pi*0.25
					end
				end
			end
		end
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
		
		-- update lightning bolt
		if self.lightning.visible then
			if self.lightning:update(dt) then
				self.lightning.visible = false
				if self.target then
					self.target:takeDamage(self.ATTACK_DAMAGE, self)
					--SpecialEffect(self.target.x, self.target.y+1, Turret.ATTACK_ANIM, 7, 0, 12)
					SpecialEffect(self.target.x, self.target.y+1, Turret.LAUNCH_ANIM, 7, 0, 20)
            .colourise = function() player[self.player].bindTeamColour() end
					audio:play_sound("KNIGHT-attack-hit", 0.1)
				end
			end
		end
  end
end

function Turret:draw_lightning()
  player[self.player].bindTeamColour()
    self.lightning:draw(self)
  love.graphics.setColor(255, 255, 255)
end

function Turret:draw(x, y)

  x, y = x or self.x, y or self.y
	
	if (not self.stunned) and self.target and (self.target.y < y) and self.lightning.visible then
		self:draw_lightning()
	end

  -- draw sprite
  if self.energy < self.ATTACK_ENERGY_COST then
    love.graphics.setColor(128, 128, 128)
  end
  love.graphics.draw(Turret.IMAGES[self.player][self.subimage], x, y,
    0, 1, 1, 32, 50)
	
	if (not self.stunned) and self.target and (self.target.y >= y) and self.lightning.visible then
    self:draw_lightning()
	end

  -- draw overlay
  if self.stunned then
    love.graphics.draw(Plant.IMG_STUN, x, y, 0, 1, 1, 32, 32)
  end

end

--[[------------------------------------------------------------
Export
--]]--

return Turret