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

local TITLE_IMG = love.graphics.newImage("assets/menu/Title.png")

local ARROWS_IMG = love.graphics.newImage("assets/menu/MENU-arrows.png")

local BUTTON_IMG =
{
  love.graphics.newImage("assets/menu/MENU-play-" .. LANGUAGE ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-controls-" .. LANGUAGE ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-credits-" .. LANGUAGE ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-leave-" .. LANGUAGE ..  ".png")
}

local PLAY = 1
local CONTROLS = 2
local CREDITS = 3
local LEAVE = 4
local current_button = PLAY

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #BUTTON_IMG
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #BUTTON_IMG then
    result = 1
  end
  return result
end

local state = GameState.new()

function state:init()
end

function state:enter()
  if audio.music:isStopped() then
    audio.music:play()
  end
end


function state:leave()
end

function cancel()
	if current_button ~= LEAVE then 
		current_button = LEAVE
	else
		love.event.push("quit")
	end
end

function accept()
	if current_button == PLAY then 
		GameState.switch(game)
	elseif current_button == CREDITS then 
		GameState.switch(credits)
	elseif current_button == CONTROLS then 
		GameState.switch(controls)
	elseif current_button == LEAVE then 
		love.event.push("quit")
	end
end

function state:keypressed(key, uni)
  
  -- quit game
  if key=="escape" then
		cancel()
    
  elseif key=="return" then
		accept()

  elseif key=="left" then
    current_button = before(current_button)

  elseif key=="right" then
    current_button = after(current_button)
  end
  
end

local button_rotation = 0

function state:update(dt)

  button_rotation = button_rotation + 2*dt
  if button_rotation > math.pi*2 then
    button_rotation = button_rotation - math.pi*2
  end

	if USE_GAMEPADS then
		if input[1].keylay() then
			accept()
		elseif input[1].keyEast() then
			cancel()
		end
	end
end


function state:draw()

  -- background
  local bgw, bgh, w, h = MENU_BG:getWidth(), MENU_BG:getHeight(), love.graphics.getWidth(), love.graphics.getHeight()
  local bgx, bgy = (w - bgw)/2, (h - bgh)/2
  love.graphics.draw(MENU_BG, bgx, bgy)

  -- title
  local tx, ty = (w - TITLE_IMG:getWidth())/2, h/3 - TITLE_IMG:getHeight()/2
  love.graphics.draw(TITLE_IMG, tx, ty)

  -- animation
  local anim1, anim2 = math.cos(button_rotation), math.sin(button_rotation)

  -- buttons
	local bw, bh = BUTTON_IMG[current_button]:getWidth(), BUTTON_IMG[current_button]:getHeight()
  local bx, by = w/2, bgy + bgh*0.725
  love.graphics.draw(BUTTON_IMG[current_button], bx, by, anim1/10, 1.1, 1.1, bw/2, bh/2)
  love.graphics.setColor(255, 255, 255, 64)
    love.graphics.draw(BUTTON_IMG[before(current_button)], bx - bw, by, 0, 0.9, 0.9, bw/2, bh/2)
    love.graphics.draw(BUTTON_IMG[after(current_button)], bx + bw, by, 0, 0.9, 0.9, bw/2, bh/2)
  love.graphics.setColor(love.graphics.getBackgroundColor())
    love.graphics.rectangle("fill", 0, 0, bgx, h)
    love.graphics.rectangle("fill", bgx+bgw, 0, bgx, h)
  love.graphics.setColor(255, 255, 255, 255)

  -- arrows
  love.graphics.setColor(255, 255, 255, 255 - (anim2+2)*64)
    love.graphics.draw(ARROWS_IMG, bx, by, 0, 
      1.15 + 0.05*anim2, 
      1.15 + 0.05*anim2, 
      ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
  love.graphics.setColor(255, 255, 255, 255)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state