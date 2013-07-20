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
IMPORTS
--]]------------------------------------------------------------

local Class = require("hump/class")

--[[------------------------------------------------------------
TILE CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local Tile = Class
{
		REGROWTH_SPEED = 0.01,

		init = function(self, i, j, w, h)
			self.i, self.j = i, j
			self.x, self.y, self.w, self.h = (i-1)*w, (j-1)*h, w, h
			self.energy = math.random()
		end
}


--[[------------------------------------------------------------
Resources
--]]

Tile.IMAGES = {}
for i = 1, 6 do
  Tile.IMAGES[i] = love.graphics.newImage("assets/tiles/tile" .. i .. ".png")
end


--[[------------------------------------------------------------
Game loop
--]]

function Tile:draw()
	--love.graphics.setColor(255*(1-self.energy), 255*(1-self.energy), 255*(1-self.energy))
		local subimage = math.min(#Tile.IMAGES, math.floor(#Tile.IMAGES * self.energy) + 1)
		love.graphics.draw(Tile.IMAGES[subimage], self.x, self.y)
	--love.graphics.setColor(255, 255, 255)
end

function Tile:update(dt, total_energy)
	self.energy = math.min(1, self.energy + dt*Tile.REGROWTH_SPEED/(self.energy*total_energy))
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Tile