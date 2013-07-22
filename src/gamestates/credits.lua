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
TITLE GAMESTATE
--]]------------------------------------------------------------



local bg = love.graphics.newImage("assets/menu/MENU-credits-bg-" .. LANGUAGE .. ".png")


local state = GameState.new()

function state:init()
  w, h = love.graphics.getWidth(), love.graphics.getHeight()
  bgw, bgh = bg:getWidth(), bg:getHeight()
end

function state:enter()
end


function state:leave()
end


function state:keypressed(key, uni)
  -- return to title
  if key=="escape" then
    GameState.switch(title)
  end
end

function state:update(dt)
end


function state:draw()
  -- background
  local bgx, bgy = (w - bgw)/2, (h - bgh)/2
  love.graphics.draw(bg, bgx, bgy)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state