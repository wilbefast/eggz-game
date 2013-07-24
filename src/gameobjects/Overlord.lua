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
      
  acceleration = 1000,

  MAX_DX = 400,
  MAX_DY = 400,
	
	CONVERT_SPEED = 1,

  SPAWN = { Bomb, Turret, Convertor}, -- FIXME

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 32, 32)

    self.player = player
    self.egg_ready = 0.7
    self.z = 1
    self.radial_menu = 0
    self.radial_menu_x = 0
    self.radial_menu_y = 0
  end,
}
Overlord:include(GameObject)

--[[------------------------------------------------------------
Resources
--]]--

Overlord.IMAGES_RADIAL =
{
  { 
    love.graphics.newImage("assets/radial_bomb_B.png"), 
    love.graphics.newImage("assets/radial_bomb_hl_B.png")
  },
  {
    love.graphics.newImage("assets/radial_turret_Y.png"),
    love.graphics.newImage("assets/radial_turret_hl_Y.png")
  },
  {
    love.graphics.newImage("assets/radial_fountain_X.png"),
    love.graphics.newImage("assets/radial_fountain_hl_X.png")
  }
}

Overlord.IMAGES =
{
  love.graphics.newImage("assets/ALIEN-BODY-idle.png")
}

Overlord.EYES = love.graphics.newImage("assets/ALIEN-EYES.png")

Overlord.SHADOW = love.graphics.newImage("assets/ALIEN-SHADOW.png")

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

  -- can't uproot if carrying
  if self.passenger then
    return false

  -- can't uproot if nothing to uproot
  elseif not self.tile.occupant then
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

  -- bombs can be planted on enemies
  if payload 
  and payload:isType("Bomb") 
  and (tile.occupant) 
  and (not tile.occupant:isType("Bomb"))
  and (tile.occupant.player ~= self.player) then
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
  
  GameObject.update(self, dt)
  
    --local dx, dy = love.joystick.getAxes(1)
  local inp = input[self.player]

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
    if (inp.x == 0) or (self.dx*inp.x < 0) then
    	self.FRICTION_X = 600
    else
    	self.FRICTION_X = useful.tri(self.z < 1, 2000, 0)
    end
    self.dx = self.dx + inp.x*dt*self.acceleration

    if (inp.y == 0) or (self.dy*inp.y < 0) then
    	self.FRICTION_Y = 600
    else
    	self.FRICTION_Y = useful.tri(self.z < 1, 2000, 0)
    end 
    self.dy = self.dy + inp.y*dt*self.acceleration
  -- Radial menu ---------------------------------------------------------
  else
    self.dx, self.dx = 0, 0
    self.radial_menu_x = useful.lerp(self.radial_menu_x, inp.x, 7*dt)
    self.radial_menu_y = useful.lerp(self.radial_menu_y, inp.y, 7*dt)

    if (math.abs(self.radial_menu_x) < 0.1) and (math.abs(self.radial_menu_y) < 0.1) then
      self.radial_menu_choice = 0
    else
      local bomb = self.radial_menu_x
      local turret = -self.radial_menu_y
      local converter = -self.radial_menu_x

      -- evolve bomb
      if (bomb > 2*turret) and (bomb > 2*converter) then
        self.radial_menu_choice = 1

      -- evolve turret
      elseif (turret > 2*bomb) and (turret > 2*converter) then
        self.radial_menu_choice = 2

      -- evolve converter
      elseif (converter > 2*turret) and (converter > 2*bomb) then
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
	if inp.lay_trigger == 1 and self:canPlant() then
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
  elseif inp.lay_trigger == -1 and self:canUproot() then
    -- pick up tile occupant
    if (self.tile.occupant:isType("Egg") or (self.tile.occupant:isType("Bomb")))
    and (not self.previous_passenger)
    and (self.radial_menu < 1) then
        self.tile.occupant:uproot(self)
    end
    self.previous_passenger = nil
  end

  -- Egg production ------------------------------------------------------
  self.egg_ready = math.min(1, self.egg_ready + dt*0.2)

  -- Land on the ground --------------------------------------------------
  if inp.lay then
    self.z = math.max(0, self.z - dt*10)
    if (self.z == 0) 
      and self.tile.occupant 
      and (self.tile.occupant.player == self.player)
      and self.tile.occupant:isType("Egg")
      and (not self.tile.occupant.stunned)
      and (self.tile.occupant.energy == 1) then
    -- Open radial menu
      self.radial_menu = math.min(1, self.radial_menu + dt*6)
    elseif not self.tile.occupant then
      -- Close radial menu
      self.radial_menu = math.max(0, self.radial_menu - dt*8)
    end

  else -- if not inp.lay
    -- Select option from radial menu
    if (self.radial_menu == 1) and (self.radial_menu_choice ~= 0) and (self.tile.occupant) then
        self.tile.occupant.purge = true
        Cocoon(self.tile, self.player, self.SPAWN[self.radial_menu_choice]).hitpoints 
          = self.tile.occupant.hitpoints
    end

    -- Close radial menu
    self.z = math.min(1, self.z + dt*10)
    self.radial_menu = math.max(0, self.radial_menu - dt*8)
  end
end

function Overlord:draw()
  -- draw shadow
  love.graphics.draw(Overlord.SHADOW, 
    self.x - Overlord.SHADOW:getWidth()/2, 
    self.y - Overlord.SHADOW:getHeight()/2)

  -- draw transported object
  if self.passenger then
    self.passenger:drawTransported()
  end

  -- set team colour
  player.bindTeamColour[self.player]()

  -- draw selected tile
  love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.tile.x, self.tile.y, 64, 64)
  love.graphics.setLineWidth(1)

  -- draw body
  love.graphics.draw(Overlord.IMAGES[1], self.x, self.y - self.h/2*self.z, 
                             0, 1, 1, 42, 86)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(Overlord.EYES, self.x - Overlord.EYES:getWidth()/2, 
                                    self.y - (2.2 + 0.5*self.z)*self.h)

  -- draw egg being laid
  if self.egg_ready > 0 then
    local egg_size = 0.3*Egg.MAX_W*self.egg_ready

    love.graphics.setColor(255, 255, 255, useful.tri(self.egg_ready < 1, 128, 255))
    love.graphics.draw(Egg.IMAGES[self.player][1][2], 
      self.x, self.y - (2.5 + 0.5*self.z)*self.h, 
      0, 0.1 + self.egg_ready*0.7, 0.1 + self.egg_ready*0.7, 32, 40)
  end

  -- reset colours
	love.graphics.setColor(255, 255, 255)

end

function Overlord:draw_gui()
  -- draw radial menu
  if self.radial_menu > 0 then
    love.graphics.setColor(255, 255, 255, self.radial_menu*255)

    function drawRadial(x, y, i)
      local scale, image
      if i == self.radial_menu_choice then
        scale, image = 1.3*self.radial_menu, Overlord.IMAGES_RADIAL[i][2]
      else
        scale, image = 1*self.radial_menu, Overlord.IMAGES_RADIAL[i][1]
      end
      love.graphics.draw(image, self.x + x, self.y + y, 
                          0, scale, scale, 18, 18)
    end

    drawRadial(self.radial_menu*64, 0, 1)
    drawRadial(0, -self.radial_menu*64, 2)
    drawRadial(-self.radial_menu*64, 0, 3)

    -- reset colours
    love.graphics.setColor(255, 255, 255)
  end
end


--[[----------------------------------------------------------------------------
Export
--]]--

return Overlord