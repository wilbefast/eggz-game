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
  love.graphics.newImage("assets/menu/MENU-play-" .. language[current_language].initials ..  ".png"),
  --love.graphics.newImage("assets/menu/MENU-controls-" .. languages[current_language].initials ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-credits-" .. language[current_language].initials ..  ".png"),
  love.graphics.newImage("assets/menu/MENU-leave-" .. language[current_language].initials ..  ".png")
}

local PLAY = 1
-- local CONTROLS = 2
-- local CREDITS = 3
-- local LEAVE = 4
local CREDITS = 2
local LEAVE = 3
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
state.controlling_player = 1

function state:enter()
  audio:play_music("loop_menu", 0.06)
end

function accept()
	if current_button == PLAY then 
    GameState.switch(player_select)
	elseif current_button == CREDITS then 
		GameState.switch(credits)
	elseif current_button == CONTROLS then 
		GameState.switch(controls)
	elseif current_button == LEAVE then 
		love.event.push("quit")
	end
end

function state:keypressed(key)
  if key=="escape" then
    love.event.push("quit")
  end
end

local button_changing = 0
local button_rotation = 0

function state:update(dt)

  for i = 1, MAX_PLAYERS do
    -- launch button switch
    if button_changing == 0 then
      button_changing = button_changing + input[i].x*dt
      self.controlling_player = i
    end
    -- confirm or cancel
    if (input[i].start.trigger == 1) or (input[i].confirm.trigger == 1) then
      accept()
    end
  end

  -- switch buttons over time
  if button_changing ~= 0 then
    button_changing = button_changing + 7*dt*useful.sign(button_changing)/(1 + 2*math.abs(button_changing))
    button_rotation = useful.lerp(button_rotation, math.pi/2, math.abs(button_changing))
    if button_changing > 1 then
      current_button = after(current_button)
      button_changing = input[self.controlling_player].x*dt
    elseif button_changing < -1 then
      current_button = before(current_button)
      button_changing = input[self.controlling_player].x*dt
    end
  else
    -- button rotation animation
    button_rotation = button_rotation + 2*dt
    if button_rotation > math.pi*2 then
      button_rotation = button_rotation - math.pi*2
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
  local cos, sin = math.cos(button_rotation), math.sin(button_rotation)

  -- buttons

  local bw, bh, by = BUTTON_IMG[current_button]:getWidth(), BUTTON_IMG[current_button]:getHeight(), bgy + bgh*0.725

  if button_changing == 0 then

    local bx = w/2
    love.graphics.draw(BUTTON_IMG[current_button], bx, by, cos/10, 1.1, 1.1, bw/2, bh/2)
    love.graphics.setColor(255, 255, 255, 64)
      love.graphics.draw(BUTTON_IMG[before(current_button)], bx - bw, by, 0, 0.9, 0.9, bw/2, bh/2)
      love.graphics.draw(BUTTON_IMG[after(current_button)], bx + bw, by, 0, 0.9, 0.9, bw/2, bh/2)
    love.graphics.setColor(love.graphics.getBackgroundColor())
      love.graphics.rectangle("fill", 0, 0, bgx, h)
      love.graphics.rectangle("fill", bgx+bgw, 0, bgx, h)
    love.graphics.setColor(255, 255, 255, 255)

    -- arrows
    love.graphics.setColor(255, 255, 255, 255 - (sin+2)*64)
      love.graphics.draw(ARROWS_IMG, bx, by, 0, 
        1.15 + 0.05*sin, 
        1.15 + 0.05*sin, 
        ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
    love.graphics.setColor(255, 255, 255, 255)

  else

    local bx = w/2 - bw*button_changing
    love.graphics.setColor(255, 255, 255, 64)
      love.graphics.draw(BUTTON_IMG[current_button], bx, by, cos/10, 1, 1, bw/2, bh/2)
      love.graphics.draw(BUTTON_IMG[before(current_button)], bx - bw, by, 0, 1, 1, bw/2, bh/2)
      love.graphics.draw(BUTTON_IMG[after(current_button)], bx + bw, by, 0, 1, 1, bw/2, bh/2)
      love.graphics.draw(BUTTON_IMG[before(before(current_button))], bx - 2*bw, by, 0, 1, 1, bw/2, bh/2)
      love.graphics.draw(BUTTON_IMG[after(after(current_button))], bx + 2*bw, by, 0, 1, 1, bw/2, bh/2)
    love.graphics.setColor(love.graphics.getBackgroundColor())
      love.graphics.rectangle("fill", 0, 0, bgx, h)
      love.graphics.rectangle("fill", bgx+bgw, 0, bgx, h)
    love.graphics.setColor(255, 255, 255, 255)

  end

  
  -- borders
  drawBorders()

end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state