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

local input = {}
for i = 1, MAX_PLAYERS do
  input[i] = { x = 0, y = 0}
end
input[1].keyleft = "left"
input[1].keyright = "right"
input[1].keyup = "up"
input[1].keydown = "down"
input[2].keyleft = "q"
input[2].keyright = "d"
input[2].keyup = "z"
input[2].keydown = "s"

function input:update(dt)

  for i = 1, MAX_PLAYERS do
    local p = self[i]
    p.x, p.y = 0, 0



    if p.keyleft and love.keyboard.isDown(p.keyleft) then
      p.x = p.x - 1 
    end
    if p.keyright and love.keyboard.isDown(p.keyright) then
      p.x = p.x + 1 
    end
    if p.keyup and love.keyboard.isDown(p.keyup) then
      p.y = p.y - 1 
    end
    if p.keydown and love.keyboard.isDown(p.keydown) then 
      p.y = p.y + 1 
    end
  end

end


return input