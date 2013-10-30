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

local state = GameState.new()

function state:update(dt)
  for i = 1, MAX_PLAYERS do
    if (input[i].cancel.trigger == 1) or (input[i].start.trigger == 1) or
    (input[i].confirm.trigger == 1) then
      GameState.switch(title)
    end
  end
end

function state:keypressed(key, uni)
  if key=="escape" then
    GameState.switch(title)
  end
end

function state:leave()
  audio:play_sound("EGG-drop")
end

local angle, cos, sin = 0, 0, 0

function state:draw()
  
  -- cache
  local w, h = DEFAULT_W, DEFAULT_H

  -- background
  scaled_draw(MENU_BG, w*0.5, h*0.5, 0, 0.8, 0.8, MENU_BG:getWidth()*0.5, MENU_BG:getHeight()*0.5)

  -- title
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf(language[current_language].credits.title, w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)

  -- task performed
  love.graphics.setFont(FONT_NORMAL)
  useful.printf(language[current_language].credits[1].what, w*0.3 , h*0.35)
  useful.printf(language[current_language].credits[2].what, w*0.3 , h*0.65)

  -- who performed them
  love.graphics.setFont(FONT_SMALL)
  useful.printf(language[current_language].credits[1].who, w*0.7, h*0.37)
  useful.printf(language[current_language].credits[2].who, w*0.7 , h*0.67)

  -- borders
  drawBorders()
end

function state:update(dt)
  angle = angle + dt
  if angle > 2*math.pi then
    angle = angle - 2*math.pi
  end
  cos, sin = math.cos(angle), math.sin(angle)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state