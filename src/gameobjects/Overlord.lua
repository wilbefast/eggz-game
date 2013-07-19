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
      
  acceleration = 600,

  MAX_DX = 400,
  MAX_DY = 400,

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 32, 32)

    self.player = player
  end,
}
Overlord:include(GameObject)


function Overlord:update(dt)
  
  GameObject.update(self, dt)
  
    --local dx, dy = love.joystick.getAxes(1)
  local inp = input[self.player]

  if inp.x == 0 or self.dx*inp.x < 0 then
  	self.FRICTION_X = 300
  else
  	self.FRICTION_X = 0
  end
	self.dx = self.dx + inp.x*dt*self.acceleration

  if inp.y == 0 or self.dy*inp.y < 0 then
  	self.FRICTION_Y = 300
  else
  	self.FRICTION_Y = 0
  end 
  self.dy = self.dy + inp.y*dt*self.acceleration
end

function Overlord:draw()
	player.bindTeamColour[self.player]()
		love.graphics.rectangle("fill", self.x-self.w/2, self.y-self.w/2, self.w, self.h)
	love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]

return Overlord