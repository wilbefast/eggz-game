--[[
(C) Copyright 2013 William

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
CONTROLS GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

function state:update(dt)
  for i = 1, MAX_PLAYERS do
    if (input[i].cancel.trigger == 1) or (input[i].start.trigger == 1) or
    (input[i].confirm.trigger == 1) then
      GameState.switch(title)
    end
  end
end

function state:leave()
  audio:play_sound("EGG-drop")
end

function state:keypressed(key, uni)
  if (key=="escape") then
    GameState.switch(title)
  end
end

function state:draw()
  -- background
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local bgx, bgy = (w - MENU_BG:getWidth())/2, (h - MENU_BG:getHeight())/2
  love.graphics.draw(MENU_BG, bgx, bgy)

  -- controls elements
  local x, y = (w - CONTROLS_IMG:getWidth())/2, (h - CONTROLS_IMG:getHeight())/2
  love.graphics.draw(CONTROLS_IMG, x, y)

  -- borders
  drawBorders()
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state