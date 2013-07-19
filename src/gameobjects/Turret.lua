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

--[[------------------------------------------------------------
Initialisation
--]]--

local Turret = Class
{
  type = GameObject.TYPE.new("Turret"),

  ENERGY_DRAW_SPEED = 0.1, 						-- per second
  ENERGY_CONSUME_SPEED = 0,--0.01, 		-- per second
  ENERGY_DRAW_EFFICIENCY = 0.7, 			-- percent
  ENERGY_START = 0.3,
  MAX_W = 24,
  MAX_H = 24,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
  end,
}
Turret:include(Plant)


--[[------------------------------------------------------------
Game loop
--]]--

function Turret:draw()
	player.bindTeamColour[self.player]()

		love.graphics.circle("fill", self.x, self.y, self.w)

		if not self.transport then
			love.graphics.circle("line", self.x, self.y, self.MAX_W)
		end

	love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]--

return Turret