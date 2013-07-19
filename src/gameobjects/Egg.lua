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
EGG GAMEOBJECT
--]]------------------------------------------------------------

local Egg = Class
{
  type = GameObject.TYPE.new("Egg"),

  init = function(self, x, y, player)
    GameObject.init(self, x + 32, y + 32, 16, 16)

    self.player = player
  end,
}
Egg:include(GameObject)


function Egg:update(dt)
  GameObject.update(self, dt)
end

function Egg:draw()
	player.bindTeamColour[self.player]()
		love.graphics.rectangle("fill", self.x-self.w/2, self.y-self.w/2, self.w, self.h)
	love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]

return Egg