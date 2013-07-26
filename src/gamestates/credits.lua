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
CREDITS GAMESTATE
--]]------------------------------------------------------------

local CREDITS_IMG = love.graphics.newImage("assets/menu/Credits-" .. LANGUAGE .. ".png")

local state = GameState.new()

function state:keypressed(key, uni)
  -- return to title
  if key=="escape" then
    GameState.switch(title)
  end
end

function state:draw()
  -- background
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local bgx, bgy = (w - MENU_BG:getWidth())/2, (h - MENU_BG:getHeight())/2
  love.graphics.draw(MENU_BG, bgx, bgy)

  -- credits
  local x, y = (w - CREDITS_IMG:getWidth())/2, (h - CREDITS_IMG:getHeight())/2
  love.graphics.draw(CREDITS_IMG, x, y)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state