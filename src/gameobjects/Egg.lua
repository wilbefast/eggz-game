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

local Egg = Class
{
  type = GameObject.TYPE.new("Egg"),

  ENERGY_DRAW_SPEED = 0.3, 						-- per second
  ENERGY_CONSUME_SPEED = 0, 					-- per second
  ENERGY_DRAW_EFFICIENCY = 0.7, 				-- percent
  ENERGY_START = 0, 									--0.3
  MAX_W = 24,
  MAX_H = 24,

  init = function(self, tile, player)
    Plant.init(self, tile, player)
  end,
}
Egg:include(Plant)


--[[------------------------------------------------------------
Resources
--]]--

Egg.IMAGES = 
{
	-- RED
	{
		{ 
			love.graphics.newImage("assets/RED-egg-A.png"), 
			love.graphics.newImage("assets/RED-egg-carry-A.png")
		},
		{ 
			love.graphics.newImage("assets/RED-egg-B.png"),
			love.graphics.newImage("assets/RED-egg-carry-B.png")
		},
		{ 
			love.graphics.newImage("assets/RED-egg-C.png"),
			love.graphics.newImage("assets/RED-egg-carry-C.png")
		}
	},
	-- BLUE
	{
		{ 
			love.graphics.newImage("assets/BLUE-egg-A.png"), 
			love.graphics.newImage("assets/BLUE-egg-carry-A.png")
		},
		{ 
			love.graphics.newImage("assets/BLUE-egg-B.png"),
			love.graphics.newImage("assets/BLUE-egg-carry-B.png")
		},
		{ 
			love.graphics.newImage("assets/BLUE-egg-C.png"),
			love.graphics.newImage("assets/BLUE-egg-carry-C.png")
		}
	}
}

--[[------------------------------------------------------------
Game loop
--]]--

function Egg:draw()
	--player.bindTeamColour[self.player]()

		local evolution = 1
		if self.energy > 0.5 then
			if self.energy == 1 then
				evolution = 3
			else
				evolution = 2
			end
		end

		local carried = useful.tri(self.transport, 2, 1)

		love.graphics.draw(Egg.IMAGES[self.player][evolution][carried],
			self.x, 
			self.y,
			0,
			1, 1, 32, 40)

		--[[if not self.transport then
			love.graphics.rectangle("line", 
				self.x - self.MAX_W/2, 
				self.y - self.MAX_H/2,  
				self.MAX_W, self.MAX_H,
				32, 32)	
		end--]]
end


--[[------------------------------------------------------------
Export
--]]--

return Egg