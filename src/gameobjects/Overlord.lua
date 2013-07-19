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

  MAX_DX = 300,
  MAX_DY = 300,

  FRICTION_X = 25,
  FRICTION_Y = 25,

  init = function(self, x, y, player)
    GameObject.init(self, x, y, 32, 32)

    self.player = player
  end,
}
Overlord:include(GameObject)


function Overlord:update(dt)
  
  GameObject.update(self, dt)
  
  --local dx, dy = love.joystick.getAxes(1)
  self.dx = self.dx + input[self.player].x*dt*self.acceleration
  self.dy = self.dy + input[self.player].y*dt*self.acceleration
end

function Overlord:draw()

end

--[[------------------------------------------------------------
Export
--]]

return Overlord