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
  ACCELERATION_BURDENED = 500,

  MAX_DX = 400,
  MAX_DY = 400,

  BLINK_PERIOD = 5,
  BLINK_PERIOD_VAR = 5,
  BLINK_LENGTH = 0.1,
	
	CONVERT_SPEED = 0,--1,
  EGG_PRODUCTION_SPEED = 0.2,

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 32, 32)

    self.player = player
    self.egg_ready = 0.7
    self.z = 1

    self.radial_menu = 0
    self.radial_menu_x = 0
    self.radial_menu_y = 0

    self.desired_dx = 0
    self.desired_dy = 0

    self.percent_gui = 0

    self.blink = math.random()*self.BLINK_PERIOD
  end,
}
Overlord:include(GameObject)

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

function Overlord:enemyTerritory()
  -- can't land in enemy territory
  if (self.tile.owner ~= 0) and (self.tile.owner ~= self.player) and (self.tile.conversion > 0.5) then
    return true
  else
    return false
  end
end

function Overlord:canUproot()
  -- can't uproot if nothing to uproot
  if not self.tile.occupant then
    return false

  -- stunned plants are locked down
  elseif self.tile.occupant.stunned then
    return false

  -- can't uproot enemy's plants from their territory
  elseif (self.tile.occupant.player ~= self.player) and self:enemyTerritory() then
    return false
  
  -- everything else is fine
  else
    return true
  end
end

function Overlord:canPlant()

  local tile, payload = self.tile, self.passenger

  -- bombs can be planted on anywhere
  if payload and payload:isType("Bomb") then
    return true

  elseif self:enemyTerritory() then
    return false

  -- can't plant nothing
  elseif not payload and (self.egg_ready == 0) then
    return false

  -- nothing else can go on top of something
  elseif tile.occupant then
    return false
  
  -- everything else is fine
  else
    return true
  end
end





--[[------------------------------------------------------------
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
  
  -- Get input
  local inp = input[self.player]

  -- Animation: blink eyes periodically
  self.blink = self.blink - dt 
  if self.blink < 0 then
    self.blink = self.BLINK_PERIOD + self.BLINK_PERIOD_VAR*math.random()
  end

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

  -- Snap to position -------------------------------------------------
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

  -- Directional movement ---------------------------------------------
  if self.z > 0 then
    local acceleration = useful.tri(self.passenger, self.ACCELERATION_BURDENED, self.ACCELERATION)
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

  -- Radial menu ---------------------------------------------------------
  else
    self.dx, self.dx = 0, 0

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

  -- Transportation ------------------------------------------------------
  if self.passenger then
    self.passenger.x = self.x
    self.passenger.y = self.y
  end

	-- Put down a plant  -------------------------------------------
	if inp.confirm.pressed and self:canPlant() then
    -- put down passenger
    if self.passenger then
      self.previous_passenger = self.passenger
      self.passenger:plant(self.tile)
    -- lay egg
    elseif self.egg_ready == 1 then
      self.previous_passenger = Egg(self.tile, self.player)
      self.egg_ready = 0
    end
  
  -- Pick up a plant  -------------------------------------------
  elseif inp.confirm.trigger == -1 and self:canUproot() then
    -- pick up tile occupant
    if (self.tile.occupant:isType("Egg") or (self.tile.occupant:isType("Bomb")))
    and (not self.previous_passenger)
    and (self.radial_menu < 1) then
        local swap, occ = self.passenger, self.tile.occupant
        occ:uproot(self)
        if swap then
          swap:plant(self.tile)
          self.passenger = occ
        end
        self.dx = self.dx * 0.5
        self.dy = self.dy * 0.5
    end
    self.previous_passenger = nil
  end

  -- Egg production ------------------------------------------------------
  self.egg_ready = math.min(1, self.egg_ready + dt*self.EGG_PRODUCTION_SPEED)

  -- Land on the ground --------------------------------------------------
  if inp.confirm.pressed then
    self.z = math.max(0, self.z - dt*10)
    if (self.z == 0) 
    and self.tile.occupant 
    and (self.tile.occupant.player == self.player)
    and (self.tile.occupant:canEvolve()) then
      -- Open radial menu
      self.evolvee = self.tile.occupant
      self.radial_menu = math.min(1, self.radial_menu + dt*6)
    elseif not self.tile.occupant then
      -- Close radial menu
      self.radial_menu = math.max(0, self.radial_menu - dt*8)
    end

  else -- if not inp.confirm.pressed
    -- Select option from radial menu
    if (self.radial_menu == 1) and (self.radial_menu_choice ~= 0) 
    and (self.tile.occupant) and (self.tile.occupant.EVOLUTION[self.radial_menu_choice]) then
        self.tile.occupant.purge = true

        local evolution
        if self.tile.occupant:isType("Cocoon") then
          evolution = Egg(self.tile, self.player)
          evolution.energy = 1
        else
          evolution = Cocoon(self.tile, self.player, self.tile.occupant.EVOLUTION[self.radial_menu_choice])
          evolution.child_energy = 1--self.tile.occupant.child_energy
        end
        evolution.hitpoints = self.tile.occupant.hitpoints
        self.radial_menu_x, self.radial_menu_y = 0, 0
    end

    -- Close radial menu
    self.z = math.min(1, self.z + dt*10)
    self.radial_menu = math.max(0, self.radial_menu - dt*8)
  end
end

function Overlord:draw(x, y)

  -- cache workspace variables
  x, y = (x or self.x), (y or self.y)
  local dx, dy = self.desired_dx, self.desired_dy
  
  -- draw shadow
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
      self.passenger:drawTransported(x, y)
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

    local scaley, offy = 1, 0
    if self.blink <= self.BLINK_LENGTH then
      scaley, offy = 0.3, 6
    end
    love.graphics.draw(Overlord.EYES, x - Overlord.EYES:getWidth()/2 + 3 + dx*8, 
                                      y - (2.2 + 0.5*self.z)*self.h + offy, 0, 1, scaley)
  end

  -- draw egg being laid
  if self.egg_ready > 0 then
    local egg_size = 0.3*Egg.MAX_W*self.egg_ready

    love.graphics.setColor(255, 255, 255, useful.tri(self.egg_ready < 1, 128, 255))
    love.graphics.draw(Egg.IMAGES[self.player][1][2], 
      x, y - (2.5 + 0.5*self.z)*self.h, 
      0, 0.1 + self.egg_ready*0.7, 0.1 + self.egg_ready*0.7, 32, 40)
  end

  -- reset colours
	love.graphics.setColor(255, 255, 255)
end

function Overlord:draw_radial_menu(x, y)

  x, y = (x or self.x), (y or self.y)

  if self.radial_menu > 0 then
    love.graphics.setColor(255, 255, 255, self.radial_menu*255)

    function drawRadial(dx, dy, i)
      if self.evolvee.EVOLUTION[i] then
        local scale, image
        if i == self.radial_menu_choice then
          scale, image = 1.3*self.radial_menu, self.evolvee.EVOLUTION_ICONS[i][2]
          love.graphics.draw(self.RADIAL_HL, x + dx, y + dy, 0, scale, scale, 32, 32)
        else
          scale, image = 1*self.radial_menu, self.evolvee.EVOLUTION_ICONS[i][1]
        end
        love.graphics.draw(image, x + dx, y + dy, 
                            0, scale, scale, 18, 18)
      end
    end

    drawRadial(self.radial_menu*64, 0, 1)
    drawRadial(0, -self.radial_menu*64, 2)
    drawRadial(-self.radial_menu*64, 0, 3)
  end
end

function Overlord:draw_icon(x, y)
	x, y = (x or self.x), (y or self.y)

	player[self.player].bindTeamColour()
		love.graphics.draw(Overlord.IDLE, x, y - self.h/2*self.z, 0, 1, 1, 42, 86)
	love.graphics.setColor(255, 255, 255)
		love.graphics.draw(Overlord.EYES, x - Overlord.EYES:getWidth()/2 + 3, 
																			y - (2.2 + 0.5*self.z)*self.h)
end

function Overlord.draw_static(x, y, team)
  player[team].bindTeamColour()
    love.graphics.draw(Overlord.IDLE, x, y, 0, 1, 1, 47, 47)
  love.graphics.setColor(255, 255, 255)
    love.graphics.draw(Overlord.EYES, x - Overlord.EYES:getWidth()/2 + 3, 
                                      y - 31)
end

function Overlord:draw_percent_conversion(x, y)

  x, y = (x or self.x), (y or self.y)

  local alpha, offset_y
  if not game.winner then
    alpha, offset_y = 255*self.percent_gui, 20*self.percent_gui
  else
    alpha, offset_y = 255, -24
  end

  love.graphics.setFont(FONT_SMALL)
  
  local total_conversion = math.floor(player[self.player].total_conversion*100)
    love.graphics.setColor(5, 15, 5, alpha)
      love.graphics.printf(tostring(total_conversion) .. "%", x+3, y+23+offset_y, 0, 'center')
    player[self.player].bindTeamColour(alpha)
      love.graphics.printf(tostring(total_conversion) .. "%", x, y+20+offset_y, 0, 'center')
  love.graphics.setColor(255, 255, 255)
end


--[[----------------------------------------------------------------------------
Export
--]]--

return Overlord