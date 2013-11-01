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
  useful.printf(language[current_language].controls.title, w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)
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