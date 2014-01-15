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
OVERLORD GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Overlord = Class
{
  type = GameObject.TYPE.new("Overlord"),
      
  ACCELERATION = 1000,

  MAX_DX = 400,
  MAX_DY = 400,

  BLINK_PERIOD = 5,
  BLINK_PERIOD_VAR = 5,
  BLINK_LENGTH = 0.1,
	
	CONVERT_SPEED = 0,--1,
  EGG_PRODUCTION_SPEED = 0.2,

  init = function(self, x, y, p)
    GameObject.init(self, x, y, 32, 32)

    self.player = p
    self.egg_ready = 0.7
    self.z = 1

    self.radial_menu = 0
    self.radial_menu_x = 0
    self.radial_menu_y = 0

    self.desired_dx = 0
    self.desired_dy = 0

    self.percent_gui = 0

    self.wave = 0

    self.blink = math.random()*self.BLINK_PERIOD

    -- create AI controller if needed
    if player[p].ai_controlled then
      self.ai = AI(self)
    end
  end,
}
Overlord:include(GameObject)
Overlord.class = Overlord

--[[------------------------------------------------------------
Resources
--]]--

Overlord.IDLE = love.graphics.newImage("assets/ALIEN-BODY-idle.png")

Overlord.LEFT = love.graphics.newImage("assets/ALIEN-BODY-left.png")
Overlord.RIGHT = love.graphics.newImage("assets/ALIEN-BODY-right.png")
Overlord.UP = love.graphics.newImage("assets/ALIEN-BODY-up.png")
Overlord.DOWN = love.graphics.newImage("assets/ALIEN-BODY-down.png")

Overlord.CARRY_FRONT = love.graphics.newImage("assets/ALIEN-BODY-carry-front.png")
Overlord.CARRY_BACK = love.graphics.newImage("assets/ALIEN-BODY-carry-back.png")

Overlord.EYES = love.graphics.newImage("assets/ALIEN-EYES.png")
Overlord.SHADOW = love.graphics.newImage("assets/ALIEN-SHADOW.png")

Overlord.RADIAL_HL = love.graphics.newImage("assets/radial_hl.png")

--[[------------------------------------------------------------
Collisions
--]]--

function Overlord:eventCollision(other, dt)
  if other:isType("Overlord") then
    self.dx = self.dx + (self.x - other.x)*dt*100
    self.dy = self.dy + (self.y - other.y)*dt*100
  end
end

function Overlord:enemyTerritory(tile)

  tile = (tile or self.tile)

  -- can't land in enemy territory
  if (tile.owner ~= 0) and (tile.owner ~= self.player) and (tile.conversion > 0.5) then
    return true
  else
    return false
  end
end

function Overlord:canUproot(tile)

  tile = (tile or self.tile)

  if self.skip_next_grab then
    return false

  -- can't uproot if nothing to uproot
  elseif not tile.occupant then
    return false

  -- stunned plants are locked down
  elseif tile.occupant.stunned then
    return false

  -- can't uproot enemy's plants from their territory
  elseif (tile.occupant.player ~= self.player) and self:enemyTerritory(tile) then
    return false
  
  -- any other egg or bomb is fine to pick up
  elseif tile.occupant.canBeUprooted then
    return true

  else
    return false
  end
end

function Overlord:canEvolve(tile)

  tile = (tile or self.tile)

  -- can't evolve if nothing to evolve
  if not tile.occupant then
    return false

  -- stunned plants are locked down
  elseif tile.occupant.stunned then
    return false

  -- can't uproot enemy's plants from their territory
  elseif tile.occupant.player ~= self.player then
    return false
  
  -- can't evolve your own plants if they're on enemy territory
  elseif self:enemyTerritory(tile) then
    return false
  -- some plants can't evolve
  elseif not tile.occupant:canEvolve() then
    return false

  -- all good otherwise
  else
    return true
  end
end

function Overlord:canSwap(tile)
  return
    (self:canUproot(tile) and self.passenger)--((self.egg_ready >= 1) or (self.passenger)))
end

function Overlord:canBomb(tile)
  -- bombs can be planted on anywhere
  return ((not self.skip_next_grab) and self.passenger and self.passenger:isType("Bomb"))
end


function Overlord:canPlant(tile)

  local tile, payload = (tile or self.tile), self.passenger

  if self.skip_next_grab then
    return false

  -- can't plant on enemy territory
  elseif self:enemyTerritory() then
    return false

  -- can't plant nothing
  elseif (not payload) and (self.egg_ready < 1) then
    return false

  -- nothing else can go on top of something
  elseif tile.occupant then
    return false
  
  -- everything else is fine
  else
    return true
  end
end

function Overlord:canLand(tile)
  return (self:canUproot(tile) or self:canPlant(tile) or self:canEvolve(tile) or self:canBomb(tile))
end



--[[---------------------------------------------------------------------------
Game loop
--]]--

function Overlord:update(dt)
  
  -- Standard update (physics)
  GameObject.update(self, dt)

  -- Lap around world
  local world_w, world_h = game.grid.tilew * game.grid.w, game.grid.tileh * game.grid.h
  -- ... horizontal
  if self.x > world_w then
    self.x = self.x - world_w
  elseif self.x < 0 then
    self.x = self.x + world_w
  end
  -- ... vertical
  if self.y > world_h then
    self.y = self.y - world_h
  elseif self.y < 0 then
    self.y = self.y + world_h
  end
  
  -- Get input / ai
  local inp
  if self.ai then
    inp = self.ai
    inp:update(dt)
  else
    inp = input[self.player]
  end

  -- Snap to position ---------------------------------------------------------
  if self.tile then self.tile.overlord = nil end
  self.tile = GameObject.COLLISIONGRID:pixelToTile(self.x, self.y)
  if (inp.x == 0 and inp.y == 0) then
    self.x = useful.lerp(self.x, self.tile.x + 32, dt*3)
    self.y = useful.lerp(self.y, self.tile.y + 32, dt*3)
  end

  -- current tile is inacessible to the other player
  self.tile.overlord = self

  -- Convert tile
  if (self.tile.owner == 0) or (self.tile.owner == self.player) then
    self.tile:convert(self.CONVERT_SPEED * dt, self.player)
  end

  -- Inform player if an action is impossible -------------------------------
  self.cantDoIt = (inp.confirm.pressed and (not self:canLand()) and (not self.skip_next_grab))
  self.wave = self.wave + dt*math.pi*4
  if self.wave > math.pi*20 then
    self.wave = self.wave - math.pi*20
  end

  -- Animation: blink eyes periodically
  self.blink = self.blink - dt 
  if self.blink < 0 then
    self.blink = self.BLINK_PERIOD + self.BLINK_PERIOD_VAR*math.random()
  end

  -- Egg production -----------------------------------------------------------
  self.egg_ready = math.min(1, self.egg_ready + dt*self.EGG_PRODUCTION_SPEED)

  -- Desired move, for animation
  if self.radial_menu == 0 then
    self.desired_dx, self.desired_dy = inp.x, inp.y
  else
    self.desired_dx, self.desired_dy = 0, 0
  end

  -- Display percent control GUI
  if (math.abs(self.dx) < 10) and (math.abs(self.dy) < 10) then
    self.percent_gui = math.min(1, self.percent_gui + dt*5)
  else
    self.percent_gui = math.max(0, self.percent_gui - dt*3)
  end


  -- Directional movement -----------------------------------------------------
  if self.z > 0 then
    local acceleration
    if self.passenger then 
      acceleration = self.ACCELERATION*self.passenger.ACCELERATION_MODIFIER
    else
      acceleration = self.ACCELERATION
    end
    if (inp.x == 0) or (self.dx*inp.x < 0) then
    	self.FRICTION_X = 600
    else
    	self.FRICTION_X = useful.tri(self.z < 1, 2000, 0)
    end
    self.dx = self.dx + inp.x*dt*acceleration

    if (inp.y == 0) or (self.dy*inp.y < 0) then
    	self.FRICTION_Y = 600
    else
    	self.FRICTION_Y = useful.tri(self.z < 1, 2000, 0)
    end 
    self.dy = self.dy + inp.y*dt*acceleration

  -- Radial menu --------------------------------------------------------------
  else -- self.z == 0

    if not self:canEvolve() then

    else
      self.dx, self.dx = 0, 0

      self.desired_dx, self.desired_dy = 0, 0

      local any_input = ((inp.x ~= 0) or (inp.y ~= 0))
      self.radial_menu_x = useful.lerp(self.radial_menu_x, inp.x, useful.tri(any_input, 7, 1)*dt)
      self.radial_menu_y = useful.lerp(self.radial_menu_y, inp.y, useful.tri(any_input, 7, 1)*dt)

      if (math.abs(self.radial_menu_x) < 0.1) and (math.abs(self.radial_menu_y) < 0.1) then
        self.radial_menu_choice = 0
      else
        local bomb = self.radial_menu_x
        local turret = -self.radial_menu_y
        local converter = -self.radial_menu_x

        -- evolve bomb
        if (bomb > 0.1) and (bomb > 2*turret) and (bomb > 2*converter) then
          self.radial_menu_choice = 1

        -- evolve turret
        elseif (turret > 0.1) and (turret > 2*bomb) and (turret > 2*converter) then
          self.radial_menu_choice = 2

        -- evolve converter
        elseif (converter > 0.1) and (converter > 2*turret) and (converter > 2*bomb) then
          self.radial_menu_choice = 3

        else
          self.radial_menu_choice = 0
        end
      end
    end
  end

  -- Transportation -----------------------------------------------------------
  if self.passenger then
    self.passenger.x = self.x
    self.passenger.y = self.y
  end

  -- Drop a bomb --------------------------------------------------------------
  if inp.confirm.pressed and self:canBomb() then
    if (self.z == 0) or self:enemyTerritory() then
      self.passenger:drop(self.tile)
      self.skip_next_grab = true
    end
  
  -- Pick down or pick up a plant  ---------------------------------------------------------
  elseif (inp.confirm.trigger == -1) then


    if self:canPlant() then
      -- put down passenger
      if self.passenger then
        self.passenger:plant(self.tile)
        self.skip_next_grab = true
      -- lay egg
      elseif (self.egg_ready == 1) then
        Egg(self.tile, self.player)
        self.egg_ready = 0
        self.skip_next_grab = true
      end
    end

    if self:canUproot() then
      -- pick up tile occupant
      if (self.radial_menu < 1) then
        -- cache
        local swap, occ = self.passenger, self.tile.occupant

        -- in any case uproot
        occ:uproot(self)

        -- swap if applicable
        if swap or (self.egg_ready >= 1) then
          -- swap for passenger
          if swap then
            swap:plant(self.tile)
          end
          self.passenger = occ
        end

        -- slow momentum when picking up
        self.dx = self.dx * 0.5
        self.dy = self.dy * 0.5
      end
    end 

    self.skip_next_grab = false
  end

  -- Land on the ground -------------------------------------------------------
  if inp.confirm.pressed and self:canLand() then
    self.z = math.max(0, self.z - dt*10)
    if (self.z == 0) 
    and self:canEvolve() then
      -- Open radial menu
      self.evolvee = self.tile.occupant
      self.radial_menu = math.min(1, self.radial_menu + dt*6)
    elseif not self.tile.occupant then
      -- Close radial menu
      self.radial_menu = math.max(0, self.radial_menu - dt*8)
    end

  elseif not inp.confirm.pressed then
    -- Select option from radial menu
    if (self.radial_menu == 1) and (self.radial_menu_choice ~= 0) 
    and (self.tile.occupant) and (self.tile.occupant.EVOLUTION[self.radial_menu_choice]) then
        -- remove the original plant
        self.tile.occupant:onEvolution()
        self.tile.occupant.purge = true
        -- what will it evolve to ?
        local evolution
        local original_hitpoints, original_energy = self.tile.occupant.hitpoints, self.tile.occupant.energy
        if self.tile.occupant:isType("Cocoon") then
          -- cancel evolution (immediately return to original from)
          evolution = self.tile.occupant.evolvesFrom(self.tile, self.player)
        else
          -- start new evolution
          evolution = Cocoon(self.tile, self.player, 
              self.tile.occupant.EVOLUTION[self.radial_menu_choice], self.tile.occupant.class)
          evolution.child_energy = original_hitpoints
        end
        -- set hitpoints/energy based on original's hitpoints/energy
        evolution.hitpoints, evolution.energy = original_hitpoints, original_energy
        -- close the menu
        self.radial_menu_x, self.radial_menu_y = 0, 0
    end

    -- Close radial menu
    self.z = math.min(1, self.z + dt*10)
    self.radial_menu = math.max(0, self.radial_menu - dt*8)
    self.radial_menu_x, self.radial_menu_y = 0, 0
  end

  -- Advance through tutorials
  if tutorial.get(self.player).isPassed(self) then
    tutorial.next(self.player)
  end
end

function Overlord:draw(x, y)

  -- cache workspace variables
  x, y = (x or self.x), (y or self.y)
  local dx, dy = self.desired_dx, self.desired_dy

  -- draw shadow
  love.graphics.setColor(255, 255, 255, 64)
  love.graphics.draw(Overlord.SHADOW, 
    x - Overlord.SHADOW:getWidth()/2 - dx*6, 
    y - Overlord.SHADOW:getHeight()/2 - dy*6)

  -- set team colour
  player[self.player].bindTeamColour()

  -- draw transported object
  if self.passenger then
    love.graphics.draw(Overlord.CARRY_BACK, x, y - self.h/2*self.z, 
                               0, 1, 1, 42, 86)
    love.graphics.setColor(255, 255, 255)
      self.passenger:drawTransported(x, y + 16*(1 - self.z))
    player[self.player].bindTeamColour()
  end

  -- draw body
  local image
  if self.passenger then
    image = Overlord.CARRY_FRONT
  elseif self.radial_menu > 0 then
    image = Overlord.IDLE
  else
    if dx < 0 then
      image = Overlord.LEFT
    elseif dx > 0 then
      image = Overlord.RIGHT
    elseif dy > 0 then
      image = Overlord.DOWN
    elseif dy < 0 then
      image = Overlord.UP
    else
      image = Overlord.IDLE
    end
  end
  love.graphics.draw(image, x, y - self.h/2*self.z, 
                             0, 1, 1, 42, 86)
  -- draw eyes
  love.graphics.setColor(255, 255, 255)
  if (dy >= 0)  then

    -- eyes height
    local scaley, offy = 1, 0
    if self.blink <= self.BLINK_LENGTH then
      scaley, offy = 0.2, 6
    end

    -- eyes position
    local eyes_x = x -  Overlord.EYES:getWidth()/2 + 3 + dx*8
    local eyes_y = y - (2.2 + 0.5*self.z)*self.h + offy
    if self.cantDoIt then
      eyes_x = eyes_x + math.cos(self.wave)*8
    end

    -- draw!
    love.graphics.draw(Overlord.EYES, eyes_x, eyes_y, 0, 1, scaley)
  end

  -- draw egg being laid
  if self.egg_ready > 0 then
    
    local egg_y = y - (2.5 + 0.5*self.z)*self.h

    love.graphics.setColor(255, 255, 255, useful.tri(self.egg_ready < 1, self.egg_ready*128, 255))
    love.graphics.draw(Egg.IMAGES[self.player][1][2],
      x, egg_y,
      0, 0.2 + self.egg_ready*0.8, 0.2 + self.egg_ready*0.8, 32, 40)
  end

  -- reset colours
	love.graphics.setColor(255, 255, 255)

  -- ai
  if DEBUG and self.ai then
    self.ai:draw()
  end

  -- tutorial
  -- useful.printf("tutorial " .. tostring(player[self.player].tutorial) .. tostring(tutorial.getMessage(self.player)), 
  --   self.x, self.y + 20)
end

function Overlord:draw_radial_menu(x, y)

  if self.radial_menu > 0 then
    x, y = (x or self.x), (y or self.y)

    love.graphics.setColor(255, 255, 255, self.radial_menu*255)

    function drawRadial(dx, dy, i)
      if self.evolvee.EVOLUTION[i] then
        local image, scale
        if i == self.radial_menu_choice then
          scale = 1.1
          image = self.evolvee.EVOLUTION_ICONS[i][2]
          love.graphics.draw(self.RADIAL_HL, x + dx, y + dy, 0, scale, scale, 32, 32)
        else
          scale = 0.9
          image = self.evolvee.EVOLUTION_ICONS[i][1]
        end
        love.graphics.draw(image, x + dx, y + dy, 
                            0, self.radial_menu*scale, self.radial_menu*scale, 18, 18)
      end
    end

    drawRadial(self.radial_menu*64, 0, 1)
    drawRadial(0, -self.radial_menu*64, 2)
    drawRadial(-self.radial_menu*64, 0, 3)

    love.graphics.setColor(255, 255, 255)
  end

  
end

function Overlord.draw_static(x, y, team)
  x, y = (x or self.x), (y or self.y)
  player[team].bindTeamColour()
    scaled_draw(Overlord.IDLE, x, y, 0, 1, 1, 47, 47)
  love.graphics.setColor(255, 255, 255)
    scaled_draw(Overlord.EYES, x - Overlord.EYES:getWidth()/2 + 3, 
                                      y - 31)
end

--[[---------------------------------------------------------------------------
Export
--]]--

return Overlord