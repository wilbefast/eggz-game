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



local bg = love.graphics.newImage("assets/menu/MENU-bg.png")
local button =
{
  love.graphics.newImage("assets/menu/MENU-play-" .. LANGUAGE ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-credits-" .. LANGUAGE ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-leave-" .. LANGUAGE ..  ".png")
}
local PLAY = 1
local CREDITS = 2
local LEAVE = 3
local current_button = PLAY

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #button
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #button then
    result = 1
  end
  return result
end

local w, h, bgw, bgh


local state = GameState.new()

function state:init()
  w, h = love.graphics.getWidth(), love.graphics.getHeight()
  bgw, bgh = bg:getWidth(), bg:getHeight()
  bw, bh = button[1]:getWidth(), button[1]:getHeight()
end

function state:enter()
end


function state:leave()
end


function state:keypressed(key, uni)
  
  -- quit game
  if key=="escape" then
    if current_button ~= LEAVE then 
      current_button = LEAVE
    else
      love.event.push("quit")
    end
    
  elseif key=="return" then
    if current_button == PLAY then GameState.switch(game)
    elseif current_button == CREDITS then GameState.switch(credits)
    elseif current_button == LEAVE then love.event.push("quit")
    end


  elseif key=="left" then
    current_button = before(current_button)

  elseif key=="right" then
    current_button = after(current_button)
  end
  
end

function state:update(dt)
end


function state:draw()
  -- background
  local bgx, bgy = (w - bgw)/2, (h - bgh)/2
  love.graphics.draw(bg, bgx, bgy)

  -- buttons
  love.graphics.draw(button[current_button], (w - bw)/2, h*0.7 - bh/2)
  love.graphics.setColor(255, 255, 255, 64)
    love.graphics.draw(button[before(current_button)], bgx-bw*0.7, h*0.7 - bh/2)
    love.graphics.draw(button[after(current_button)], bgx+bgw-bw*0.3, h*0.7 - bh/2)
  love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("fill", 0, 0, bgx, h)
    love.graphics.rectangle("fill", bgx+bgw, 0, bgx, h)
  love.graphics.setColor(255, 255, 255, 255)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state