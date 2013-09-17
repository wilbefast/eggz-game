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
BOMB GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local BombBlast = Class
{
  type = GameObject.TYPE.new("BombBlast"),

  init = function(self, x, y)
    GameObject.init(self, x, y)
    self.life = 1
  end,
}
BombBlast:include(GameObject)

--[[------------------------------------------------------------
Resources
--]]--

BombBlast.IMAGE = love.graphics.newImage("assets/BOMB-blast.png")

--[[------------------------------------------------------------
Game loop
--]]--

function BombBlast:update(dt)
  self.life = self.life - dt
  if self.life < 0 then
    self.purge = true
  end
end

function BombBlast:draw()
  love.graphics.setColor(255, 255, 255, self.life*255)
    love.graphics.draw(BombBlast.IMAGE, self.x, self.y,
      0, 1, 1, 96, 96)
  love.graphics.setColor(255, 255, 255, 255)
end

--[[------------------------------------------------------------
Export
--]]--

return BombBlast