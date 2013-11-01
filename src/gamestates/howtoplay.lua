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

local message_i = 1

local images =
{
  love.graphics.newImage("assets/howtoplay/pick_drop.png"),
  love.graphics.newImage("assets/howtoplay/fertile.png"),
  love.graphics.newImage("assets/howtoplay/evolve.png"),
  love.graphics.newImage("assets/howtoplay/altars.png"),
  love.graphics.newImage("assets/howtoplay/statues.png"),
}

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #(language[current_language].howtoplay)
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #(language[current_language].howtoplay) then
    result = 1
  end
  return result
end

local state = GameState.new()
state.controlling_player = 1

function state:enter()
  message_i = 1
end

function state:leave()
  audio:play_sound("EGG-drop")
end

function state:keypressed(key)
  if key=="escape" then
    GameState.switch(title)
  end
end

local changing = 0
local rotation = 0

local angle, cos, sin = 0, 0, 0

function state:update(dt)

  angle = angle + dt
  if angle > 2*math.pi then
    angle = angle - 2*math.pi
  end
  cos, sin = math.cos(angle), math.sin(angle)

  for i = 1, MAX_PLAYERS do
    -- launch button switch
    local ix = input[i].x
    if (changing == 0) 
    and ((ix ~= 0) or (input[i].start.trigger == 1) or (input[i].confirm.trigger == 1)) then
      audio:play_sound("EGG-pick")
      changing = useful.tri(ix ~= 0, ix, 1)*dt
      self.controlling_player = i
    end
    -- cancel
    if (input[i].cancel.trigger == 1) then
      GameState.switch(title)
    end
  end

  -- switch buttons over time
  if changing ~= 0 then
    changing = changing + 7*dt*useful.sign(changing)/(1 + 2*math.abs(changing))
    rotation = useful.lerp(rotation, math.pi/2, math.abs(changing))
    if changing > 1 then
      message_i = after(message_i)
      changing = input[self.controlling_player].x*dt
    elseif changing < -1 then
      message_i = before(message_i)
      changing = input[self.controlling_player].x*dt
    end
  else
    -- button rotation animation
    rotation = rotation + 2*dt
    if rotation > math.pi*2 then
      rotation = rotation - math.pi*2
    end
  end
end

local BUTTON_OFFSET = 550

function state:draw()

  -- cache
  local w, h = DEFAULT_W, DEFAULT_H

  -- background
  scaled_draw(MENU_BG, w*0.5, h*0.5, 0, 0.8, 0.8, MENU_BG:getWidth()*0.5, MENU_BG:getHeight()*0.5)

  -- title
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf(language[current_language].howtoplay.title, w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)

  -- animation
  local cos, sin = math.cos(rotation), math.sin(rotation)

  -- prepare to draw menu options
  love.graphics.setFont(FONT_MASSIVE)
  local tutorial_messages = language[current_language].howtoplay
  local arrow_y, message_y = h*0.7, h*0.75

  -- small font for messages
  love.graphics.setFont(FONT_SMALL)

  -- cache
  local arrow_width = ARROWS_IMG:getWidth()
  local message_width = arrow_width*0.8
  local im = images[message_i]

  -- not currently changing message => current message 'floats around'
  if changing == 0 then

    local message_x = w*0.5

    -- draw the current image
    scaled_draw(im, w*0.5, h*0.4, 0, 1.2, 1.2, im:getWidth()*0.5, im:getHeight()*0.5)

    -- draw the current message
    useful.printf(tutorial_messages[message_i], message_x, message_y, cos/10, message_width)
    love.graphics.setColor(255, 255, 255, 64)
      useful.printf(tutorial_messages[before(message_i)], message_x - BUTTON_OFFSET, message_y, 0, message_width)
      useful.printf(tutorial_messages[after(message_i)], message_x + BUTTON_OFFSET, message_y, 0, message_width)

    -- arrows
    love.graphics.setColor(255, 255, 255, 255 - (sin+2)*64)
      scaled_draw(ARROWS_IMG, message_x, arrow_y, 0, 
        1.15 + 0.05*sin, 
        1.15 + 0.05*sin, 
        arrow_width*0.5, ARROWS_IMG:getHeight()*0.5)
    love.graphics.setColor(255, 255, 255, 255)

  -- currently changing
  else

    local achanging = math.abs(changing)
    local scale = 1

    -- faded out the current image
    if achanging < 0.5 then
      scale = 1 - achanging*2
    else
      scale = (achanging - 0.5)*2
      im = images[useful.tri(changing > 0, after(message_i), before(message_i))]
    end
    love.graphics.setColor(255, 255, 255, scale*255)
      scaled_draw(im, w*0.5, h*0.4, 0, scale*1.2, scale*1.2, im:getWidth()*0.5, im:getHeight()*0.5)

    -- the current option
    local message_x = w/2 - BUTTON_OFFSET*changing
    love.graphics.setColor(255, 255, 255, 64)
      useful.printf(tutorial_messages[message_i], message_x, message_y, cos/10, message_width)
      useful.printf(tutorial_messages[before(message_i)], message_x - BUTTON_OFFSET, message_y, 0, message_width)
      useful.printf(tutorial_messages[after(message_i)], message_x + BUTTON_OFFSET, message_y, 0, message_width)
      useful.printf(tutorial_messages[before(before(message_i))], message_x - BUTTON_OFFSET*2, message_y, 0, message_width)
      useful.printf(tutorial_messages[after(after(message_i))], message_x + BUTTON_OFFSET*2, message_y, 0, message_width)
    end

  -- current page
  love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(FONT_NORMAL)
    useful.printf(tostring(message_i) .. " / " .. tostring(#tutorial_messages), 0.5*w, h, 0, w)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state