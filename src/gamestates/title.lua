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

ARROWS_IMG = love.graphics.newImage("assets/menu/MENU-arrows.png")

local current_button = 1

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #(language[current_language].title)
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #(language[current_language].title) then
    result = 1
  end
  return result
end

local state = GameState.new()
state.controlling_player = 1

function state:enter()
  audio:play_music("loop_menu", 0.06)
end

function state:leave()
  audio:play_sound("EGG-drop")
end

function accept()
  local button_name = language[1].title[current_button]
	if button_name == "Versus" then 
    GameState.switch(player_select)
	elseif button_name == "Creggits" then 
		GameState.switch(credits)
	elseif button_name == "Controls" then 
		GameState.switch(controls)
  elseif button_name == "Language" then 
    GameState.switch(language_select)
	elseif button_name == "Quit" then 
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
    if (button_changing == 0) and (input[i].x ~= 0) then
      audio:play_sound("EGG-pick")
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

local BUTTON_OFFSET = 550

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
  love.graphics.setFont(FONT_MASSIVE)
  local button_names = language[current_language].title
  local by = bgy + bgh*0.675

  if button_changing == 0 then

    local bx = w/2

    useful.printf(button_names[current_button], bx, by, cos/10)
    love.graphics.setColor(255, 255, 255, 64)
      useful.printf(button_names[before(current_button)], bx - BUTTON_OFFSET, by)
      useful.printf(button_names[after(current_button)], bx + BUTTON_OFFSET, by)
    love.graphics.setColor(love.graphics.getBackgroundColor())
      love.graphics.rectangle("fill", 0, 0, bgx, h)
      love.graphics.rectangle("fill", bgx+bgw, 0, bgx, h)
    love.graphics.setColor(255, 255, 255, 255)

    -- arrows
    love.graphics.setColor(255, 255, 255, 255 - (sin+2)*64)
      love.graphics.draw(ARROWS_IMG, bx, bgy + bgh*0.725, 0, 
        1.15 + 0.05*sin, 
        1.15 + 0.05*sin, 
        ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
    love.graphics.setColor(255, 255, 255, 255)

  else

    local bx = w/2 - BUTTON_OFFSET*button_changing
    love.graphics.setColor(255, 255, 255, 64)
      useful.printf(button_names[current_button], bx, by, cos/10)
      useful.printf(button_names[before(current_button)], bx - BUTTON_OFFSET, by)
      useful.printf(button_names[after(current_button)], bx + BUTTON_OFFSET, by)
      useful.printf(button_names[before(before(current_button))], bx - BUTTON_OFFSET*2, by)
      useful.printf(button_names[after(after(current_button))], bx + BUTTON_OFFSET*2, by)
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