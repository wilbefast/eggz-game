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
COLLISIONGRID CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]

local CollisionGrid = Class
{
  init = function(self, tilew, tileh, w, h)
  
    -- grab the size of the tiles
    self.tilew, self.tileh = tilew, tileh
  
    -- grab the size of the map
    if w and h then
      self.w, self.h = w, h
    else
      self.w = love.graphics.getWidth() / tilew
      self.h = love.graphics.getHeight() / tileh
    end

    -- create the collision map
    self.tiles = {}
    for x = 1, self.w do
      self.tiles[x] = {}
      for y = 1, self.h do
        self.tiles[x][y] = Tile()
      end
    end
  end
}


--[[----------------------------------------------------------------------------
Map functions to all or part of the grid
--]]--

function CollisionGrid:mapRectangle(startx, starty, w, h, f)
  for x = startx, startx + w - 1 do
    for y = starty, starty + h - 1 do
      if self:validGridPos(x, y) then
        f(self.tiles[x][y])
      end
    end
  end
end

--[[------------------------------------------------------------
Game loop
--]]

function CollisionGrid:draw(view) 

  local start_x, end_x, start_y, end_y
  if view then
    start_x = math.max(1, math.floor(view.x / self.tilew))
    end_x = math.min(self.w, 
                start_x + math.ceil(view.w / self.tilew))
    
    start_y = math.max(1, math.floor(view.y / self.tileh))
    end_y = math.min(self.h, 
                start_y + math.ceil(view.h / self.tileh))
  else
    start_x, start_y = 1, 1
    end_x, end_y = self.w, self.h
  end

  for x = start_x, end_x do
    for y = start_y, end_y do
      self.tiles[x][y]:draw((x-1)*self.tilew, (y-1)*self.tileh, self.tilew, 64)--self.tileh)
    end
  end

    --TODO use sprite batches
end

--[[----------------------------------------------------------------------------
Accessors
--]]--

function CollisionGrid:gridToTile(x, y)
  if self:validGridPos(x, y) then
    return self.tiles[x][y]
  else
    return nil --FIXME return default tile
  end
end

function CollisionGrid:pixelToTile(x, y)
  return self:gridToTile(math.floor(x / self.tilew) + 1,
                         math.floor(y / self.tileh) + 1)
end


function CollisionGrid:centrePixel()
  return self.w*self.tilew/2, self.h*self.tileh/2
end

--[[----------------------------------------------------------------------------
Conversion
--]]--

function CollisionGrid:pixelToGrid(x, y)
  return math.floor(x / self.tilew) + 1, math.floor(y / self.tileh) +1
end

function CollisionGrid:gridToPixel(x, y)
  return (x-1) * self.tilew, (y-1) * self.tileh
end


--[[----------------------------------------------------------------------------
Avoid array out-of-bounds exceptions
--]]--

function CollisionGrid:validGridPos(x, y)
  return (x >= 1 
      and y >= 1
      and x <= self.w 
      and y <= self.h) 
end

function CollisionGrid:validPixelPos(x, y)
  return (x >= 0
      and y >= 0
      and x <= self.size.x*self.tilew
      and y <= self.size.y*self.tileh)
end


--[[----------------------------------------------------------------------------
Basic collision tests
--]]--

function CollisionGrid:gridCollision(x, y, type)
  type = (type or Tile.TYPE.WALL)
  return (self:gridToTile(x, y).type == type)
end

function CollisionGrid:pixelCollision(x, y)
  local tile = self:pixelToTile(x, y)
  return (not tile)
end

--[[----------------------------------------------------------------------------
GameObject collision tests
--]]--

function CollisionGrid:collision(go, x, y, type)
  -- x & y are optional: leave them out to test the object where it actually is
  x = (x or go.x)
  y = (y or go.y)
  
  -- rectangle collision mask, origin is at the top-left
  return (self:pixelCollision(x,         y,        type) 
      or  self:pixelCollision(x + go.w,  y,         type) 
      or  self:pixelCollision(x,         y + go.h,  type)
      or  self:pixelCollision(x + go.w,  y + go.h, type))
end

function CollisionGrid:collision_next(go, dt)
  return self:collision(go, go.x + go.dx*dt, go.y + go.dy*dt)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return CollisionGrid