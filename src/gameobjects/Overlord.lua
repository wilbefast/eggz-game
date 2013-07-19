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

  -- Snapped position ---------------------------------------------
  self.snapx = useful.floor(self.x, GameObject.COLLISIONGRID.tilew)
  self.snapy = useful.floor(self.y, GameObject.COLLISIONGRID.tileh)

  -- Directional movement ---------------------------------------------
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

  if inp.x == 0 and inp.y == 0 then
  	self.x = useful.lerp(self.x, self.snapx + 32, dt*2)
  	self.y = useful.lerp(self.y, self.snapy + 32, dt*2)
  end

	-- Egg laying ------------------------------------------------------
	if inp.lay == 1 then
		Egg(self.snapx, self.snapy, self.player)
	end

end



function Overlord:draw()
	player.bindTeamColour[self.player]()
		love.graphics.rectangle("fill", self.x-self.w/2, self.y-self.w/2, 
																		self.w, self.h)
		love.graphics.setLineWidth(3)
			love.graphics.rectangle("line", self.snapx, self.snapy, 64, 64)
		love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255)
end

--[[----------------------------------------------------------------------------
Export
--]]

return Overlord