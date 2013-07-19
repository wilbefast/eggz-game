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
}

Tile.init = function(self)
	self.energy = math.random()
end

--[[------------------------------------------------------------
Game loop
--]]

function Tile:draw(x, y, w, h)
	love.graphics.setColor(255*self.energy, 255*self.energy, 255*self.energy)
		love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.setColor(255, 255, 255)
end

function Tile:update(dt)
	self.energy = useful.clamp(self.energy + dt/100/self.energy, 0, 1)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Tile