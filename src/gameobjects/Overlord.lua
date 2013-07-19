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

local Overlord = Class
{
  type = GameObject.TYPE.new("Overlord"),
      
  acceleration = 1000,

  MAX_DX = 400,
  MAX_DY = 400,

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 32, 32)

    self.player = player
    self.egg_ready = 0
  end,
}
Overlord:include(GameObject)


function Overlord:update(dt)
  
  GameObject.update(self, dt)
  
    --local dx, dy = love.joystick.getAxes(1)
  local inp = input[self.player]

  -- Snapped position ---------------------------------------------
  self.tile = GameObject.COLLISIONGRID:pixelToTile(self.x, self.y)

  -- Directional movement ---------------------------------------------
  if (inp.x == 0) or (self.dx*inp.x < 0) then
  	self.FRICTION_X = 600
  else
  	self.FRICTION_X = 0
  end
  self.dx = self.dx + inp.x*dt*self.acceleration

  if (inp.y == 0) or (self.dy*inp.y < 0) then
  	self.FRICTION_Y = 600
  else
  	self.FRICTION_Y = 0
  end 
  self.dy = self.dy + inp.y*dt*self.acceleration

  if (inp.x == 0 and inp.y == 0) then
  	self.x = useful.lerp(self.x, self.tile.x + 32, dt*3)
  	self.y = useful.lerp(self.y, self.tile.y + 32, dt*3)
  end

  -- Transportation ------------------------------------------------------
  if self.passenger then
    self.passenger.x = self.x
    self.passenger.y = self.y + 16
  end

	-- Egg transporation -------------------------------------------
	if inp.lay_trigger == 1 then

    -- pick up tile occupant
		if self.tile.occupant then
      self.passenger = self.tile.occupant
      self.passenger.transport = self
      self.tile.occupant = nil
      self.passenger.tile = nil
      self.egg_ready = 0

    -- put down passenger
    elseif self.passenger then
      self.passenger.tile = self.tile
      self.passenger.transport = nil
      self.tile.occupant = self.passenger
      self.passenger.x = self.tile.x
      self.passenger.y = self.tile.y
      self.passenger = nil

    -- lay egg
    elseif self.egg_ready == 1 then
      Egg(self.tile, self.player)
      self.egg_ready = 0
    end
  end

  -- Egg production ------------------------------------------------------
  if not self.passenger then
    self.egg_ready = math.min(1, self.egg_ready + dt*0.2)
  end
end



function Overlord:draw()
	player.bindTeamColour[self.player]()

    -- draw body
		love.graphics.rectangle("fill", self.x-self.w/2, self.y - self.w*1.5, 
																		self.w, self.h)

    -- draw selected tile
		love.graphics.setLineWidth(3)
			love.graphics.rectangle("line", self.tile.x, self.tile.y, 64, 64)
		love.graphics.setLineWidth(1)

    -- draw egg being laid
    if self.egg_ready > 0 then
      local egg_size = 0.3*32*self.egg_ready
      love.graphics.rectangle(useful.tri(self.egg_ready == 1, "fill", "line"), 
        self.x - egg_size/2, 
        self.y - egg_size/2, 
        egg_size, egg_size)
    end

    -- draw shadow
    love.graphics.setColor(0, 0, 0, 128)
    love.graphics.rectangle("fill", self.x-self.w/2, self.y - self.h*0.25, 
                                    self.w, self.h/2)

	love.graphics.setColor(255, 255, 255)


end

--[[----------------------------------------------------------------------------
Export
--]]

return Overlord