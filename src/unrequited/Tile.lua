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
		REGROWTH_SPEED = 0.05,

		init = function(self, i, j, w, h)
			self.i, self.j = i, j
			self.x, self.y, self.w, self.h = (i-1)*w, (j-1)*h, w, h
			self.energy = math.random()

			self.owner = 0
			self.conversion = 0 

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
Conversion
--]]

function Tile:convert(amount, player)

	if self.owner ~= player then
		if self.conversion < amount then
			self.conversion = (amount - self.conversion)
			self.owner = player
		else 
			self.conversion = math.min(1, self.conversion - amount)
		end
	else
		self.conversion = math.min(1, self.conversion + amount)
	end
end

--[[------------------------------------------------------------
Game loop
--]]

function Tile:draw()
	local subimage = math.min(#Tile.IMAGES, math.floor(#Tile.IMAGES * self.energy) + 1)
	love.graphics.draw(Tile.IMAGES[subimage], self.x, self.y)

	if self.owner ~= 0 then
		player.bindTeamColour[self.owner]((self.conversion*0.5)*255)
			love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor(255, 255, 255)
	end
end

function Tile:update(dt, total_energy)
	self.energy = math.min(1, self.energy + dt*Tile.REGROWTH_SPEED/(self.energy*total_energy))
end



--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Tile