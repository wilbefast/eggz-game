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
			self.non_mans_land = true
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

function Tile:convert(amount, converter)

	self.no_mans_land = false

	-- convert enemy
	if self.owner ~= converter then
		amount = amount*(1 + self.conversion)
		if self.conversion < amount then
			self.conversion = (amount - self.conversion)
			self.owner = converter
		else 
			self.conversion = math.min(1, self.conversion - amount)
		end

	-- reinforce ally
	else
		self.conversion = math.min(1, self.conversion + amount*(1 - self.conversion))
	end

end

--[[------------------------------------------------------------
Game loop
--]]

local LINE_WIDTH = 3

function Tile:draw()
	local subimage = math.min(#Tile.IMAGES, math.floor(#Tile.IMAGES * self.energy) + 1)
	love.graphics.draw(Tile.IMAGES[subimage], self.x, self.y)
end

function Tile:drawContours()
	if (self.owner ~= 0) and (self.conversion > 0.1) then
		love.graphics.setLineWidth(LINE_WIDTH)
		player.bindTeamColour[self.owner]((self.conversion*0.2)*255)
			love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		player.bindTeamColour[self.owner]()

			-- calculate offsets
			local left, right = self.x, self.x+self.w
			local top, bottom = self.y, self.y+self.h
	    if not self.leftContiguous then
	    	left = left + LINE_WIDTH
	    end
	    if not self.rightContiguous  then
	    	right = right - LINE_WIDTH
	    end
	    if not self.aboveContiguous  then
	    	top = top + LINE_WIDTH
	    end
	    if not self.belowContiguous  then
	    	bottom = bottom - LINE_WIDTH
	    end

	   	-- draw boundaries
	    if not self.leftContiguous then
	    	love.graphics.line(left, top, left, bottom)
	    end
	    if not self.rightContiguous  then
	    	love.graphics.line(right, top, right, bottom)
	    end
	    if not self.aboveContiguous  then
	    	love.graphics.line(left, top, right, top)
	    end
	    if not self.belowContiguous  then
	    	love.graphics.line(left, bottom, right, bottom)
	    end

	    -- draw boundary corners
			if self.leftContiguous and self.aboveContiguous and (not self.nwContiguous) then -- NW
				love.graphics.line(self.x - LINE_WIDTH, self.y + LINE_WIDTH, self.x + LINE_WIDTH, self.y - LINE_WIDTH)
			end
			if self.leftContiguous and self.belowContiguous and (not self.swContiguous) then -- SW
				love.graphics.line(self.x - LINE_WIDTH, self.y + self.h - LINE_WIDTH, self.x + LINE_WIDTH, self.y + self.h + LINE_WIDTH)
			end
			if self.rightContiguous and self.aboveContiguous and (not self.neContiguous) then -- NE
				love.graphics.line(self.x + self.w - LINE_WIDTH, self.y - LINE_WIDTH, self.x + self.w + LINE_WIDTH, self.y + LINE_WIDTH)
			end
			if self.rightContiguous and self.belowContiguous and (not self.seContiguous) then -- SE
				love.graphics.line(self.x + self.w - LINE_WIDTH, self.y + self.h + LINE_WIDTH, self.x + self.w + LINE_WIDTH, self.y + self.h - LINE_WIDTH)
			end

		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 255, 255)
	end
end

function Tile:update(dt, total_energy)
	self.energy = math.min(1, 
		self.energy + dt*Tile.REGROWTH_SPEED/(self.energy*total_energy)*(1+2*self.conversion))

	if self.no_mans_land then
		self.conversion = math.max(0, self.conversion - 0.5*dt)
		if self.conversion == 0 then
			self.owner = 0
		end
	end

	self.no_mans_land = true
end



--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return Tile