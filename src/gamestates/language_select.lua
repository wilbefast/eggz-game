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
LANGUAGE SELECT GAMESTATE
--]]------------------------------------------------------------

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #language
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #language then
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

function state:keypressed(key)
  if key=="escape" then
    love.event.push("quit")
  end
end

local flag_changing = 0
local flag_rotation = 0

function state:update(dt)

  for i = 1, MAX_PLAYERS do
    -- launch language switch
    if (flag_changing == 0) and (input[i].x ~= 0) then
      audio:play_sound("EGG-pick")
      flag_changing = flag_changing + input[i].x*dt
      self.controlling_player = i
    end
    -- confirm
    if (input[i].start.trigger == 1) or (input[i].confirm.trigger == 1) or (input[i].cancel.trigger == 1) then
      GameState.switch(title)
    end
  end

  -- switch language over time
  if flag_changing ~= 0 then
    flag_changing = flag_changing + 7*dt*useful.sign(flag_changing)/(1 + 2*math.abs(flag_changing))
    flag_rotation = useful.lerp(flag_rotation, math.pi/2, math.abs(flag_changing))
    if flag_changing > 1 then
      current_language = after(current_language)
      flag_changing = input[self.controlling_player].x*dt
    elseif flag_changing < -1 then
      current_language = before(current_language)
      flag_changing = input[self.controlling_player].x*dt
    end
  else
    -- button rotation animation
    flag_rotation = flag_rotation + 2*dt
    if flag_rotation > math.pi*2 then
      flag_rotation = flag_rotation - math.pi*2
    end
  end
end


function state:draw()

  -- cache
  local w, h = DEFAULT_W, DEFAULT_H

  -- background
  scaled_draw(MENU_BG, w*0.5, h*0.5, 0, 0.8, 0.8, MENU_BG:getWidth()*0.5, MENU_BG:getHeight()*0.5)

  -- animation
  local cos, sin = math.cos(flag_rotation), math.sin(flag_rotation)

  -- language
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf("Language", w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)

  -- buttons
  local flagw, flagh, flagy = language[current_language].flag:getWidth(), 
                    language[current_language].flag:getHeight(), h*0.5

  if flag_changing == 0 then

    local flagx = w/2
    scaled_draw(language[current_language].flag, flagx, flagy, cos/10, 1.1, 1.1, flagw/2, flagh/2)
    love.graphics.setColor(255, 255, 255, 64)
      scaled_draw(language[before(current_language)].flag, flagx - flagw, flagy, 0, 0.9, 0.9, flagw/2, flagh/2)
      scaled_draw(language[after(current_language)].flag, flagx + flagw, flagy, 0, 0.9, 0.9, flagw/2, flagh/2)
  else

    local flagx = w/2 - flagw*flag_changing
    love.graphics.setColor(255, 255, 255, 64)
      scaled_draw(language[current_language].flag, flagx, flagy, cos/10,  1.1, 1.1, flagw/2, flagh/2)
      scaled_draw(language[before(current_language)].flag, flagx - flagw, flagy, 0, 1, 1, flagw/2, flagh/2)
      scaled_draw(language[after(current_language)].flag, flagx + flagw, flagy, 0, 1, 1, flagw/2, flagh/2)
      scaled_draw(language[before(before(current_language))].flag, flagx - 2*flagw, flagy, 0, 1, 1, flagw/2, flagh/2)
      scaled_draw(language[after(after(current_language))].flag, flagx + 2*flagw, flagy, 0, 1, 1, flagw/2, flagh/2)
  end

  -- arrows
  love.graphics.setColor(255, 255, 255, 255 - (sin+2)*32)
    scaled_draw(ARROWS_IMG, w/2, h/2, 0, 
      1.15 + 0.05*sin, 
      1.15 + 0.05*sin, 
      ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
  love.graphics.setColor(255, 255, 255, 255)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state