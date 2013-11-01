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

local IMG_KEYDIRS = love.graphics.newImage("assets/menu/keyboard_directions.png")
local IMG_KEYACTION = love.graphics.newImage("assets/menu/keyboard_action.png")


local angle, cos, sin = 0, 0, 0

function state:update(dt)
  angle = angle + dt
  if angle > 2*math.pi then
    angle = angle - 2*math.pi
  end
  cos, sin = math.cos(angle), math.sin(angle)

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

function state:enter()
end

function state:leave()
  audio:play_sound("EGG-drop")
end

function state:draw()
  
  -- cache
  local w, h = DEFAULT_W, DEFAULT_H

  -- background
  scaled_draw(MENU_BG, w*0.5, h*0.5, 0, 0.8, 0.8, MENU_BG:getWidth()*0.5, MENU_BG:getHeight()*0.5)

  -- title
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf(language[current_language].controls.title, w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)

  -- controls for each player
  love.graphics.setFont(FONT_SMALL)
  for i = 1, MAX_PLAYERS do
    local x, y = w*(0.2 + (i-1)*0.2), h*0.35

    if input[i].gamepad then
      -- gamepad outline

    else
      -- keyboard outline
      player[i].bindTeamColour()
        scaled_draw(IMG_KEYDIRS, x, y, 0, 1.2, 1.2, IMG_KEYDIRS:getWidth()*0.5, IMG_KEYDIRS:getHeight()*0.5)
      -- keyboard buttons
      local lang = language[current_language]
      love.graphics.setColor(255, 255, 255)
        input[i]:drawButton("up", x, y+30)
        input[i]:drawButton("left", x-40, y+70)
        input[i]:drawButton("down", x, y+70)
        input[i]:drawButton("right", x+40, y+70)
    end
  end

  -- reset colour
  love.graphics.setColor(255, 255, 255)
end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state