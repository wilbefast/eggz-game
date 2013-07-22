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
  input[i] = { x = 0, y = 0, lay = false, lay_prev = false, lay_trigger = 0}
end
input[1].keyleft = function () return love.keyboard.isDown("left") end
input[1].keyright = function () return love.keyboard.isDown("right") end
input[1].keyup = function () return love.keyboard.isDown("up") end
input[1].keydown = function () return love.keyboard.isDown("down") end
input[1].keylay = function () return love.keyboard.isDown("rctrl") end


input[2].keyleft = function () return love.keyboard.isDown("a", "q") end
input[2].keyright = function () return love.keyboard.isDown("d") end
input[2].keyup = function () return love.keyboard.isDown("w", "z") end
input[2].keydown = function () return love.keyboard.isDown("s") end
input[2].keylay = function () return love.keyboard.isDown("lctrl") end

function input:update(dt)

  for i = 1, MAX_PLAYERS do
    local p = self[i]
    p.x, p.y = 0, 0

    --left
    if p.keyleft and p.keyleft() then
      p.x = p.x - 1 
    end
    --right
    if p.keyright and p.keyright() then
      p.x = p.x + 1 
    end
    -- up
    if p.keyup and p.keyup() then
      p.y = p.y - 1 
    end
    -- down
    if p.keydown and p.keydown() then 
      p.y = p.y + 1 
    end

    -- lay
    if p.keylay then
      p.lay = p.keylay()
      if p.lay then
        if not p.lay_prev then
          p.lay_trigger = 1
        else
          p.lay_trigger = 0
        end
        p.lay_prev = true
      else
        if p.lay_prev then
          p.lay_trigger = -1
        else
          p.lay_trigger = 0
        end
        p.lay_prev = false
      end
    end
  end

end


return input