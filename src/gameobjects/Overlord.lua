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
      
  speed = 256,

  init = function(self, x, y)
    GameObject.init(self, x, y, 32, 32)
  end,
}
Overlord:include(GameObject)



function Overlord:update(dt)
  
  GameObject.update(self, dt)
  
  --local dx, dy = love.joystick.getAxes(1)
  self.x, self.y = self.x + input.x*dt*self.speed, self.y + input.y*dt*self.speed
end


--[[------------------------------------------------------------
Export
--]]

return Overlord