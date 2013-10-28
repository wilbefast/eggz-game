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
SELECT GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new()

state.previous_n_players = n_players
state.current_n_players = n_players
state.desired_n_players = n_players

function state:enter()
  audio:play_music("loop_menu", 0.06)
end

local angle, cos, sin = 0, 0, 0

function state:update(dt)

  angle = angle + dt
  if angle > 2*math.pi then
    angle = angle - 2*math.pi
  end
  cos, sin = math.cos(angle), math.sin(angle)

  -- if there is no horizontal input from anyone, stop !
  local h_input = false

  -- does any player ...
  for i = 1, MAX_PLAYERS do

    -- ... request start game ?
    if (input[i].start.trigger == 1) or (input[i].confirm.trigger == 1) then
      GameState.switch(game)
    end

    -- ... request return to title ?
    if (input[i].cancel.trigger == 1) then
      GameState.switch(title)
    end

    -- ... request a change in the number of players ?
    if (input[i].x ~= 0) then

      local new_desired_n_players = useful.clamp(useful.round(self.current_n_players) 
        + useful.sign(input[i].x), 2, MAX_PLAYERS)

      if (self.desired_n_players == self.current_n_players) 
      and (new_desired_n_players ~= self.current_n_players) then
        audio:play_sound("EGG-pick")
      end

      self.desired_n_players = new_desired_n_players
      h_input = true
    end
  end

  -- apply horizontal input
  self.current_n_players 
    = useful.lerp(self.current_n_players, self.desired_n_players, dt*5)
  
  -- has horizontal input ceased ?
  if not h_input then

    local p = useful.round(self.current_n_players)
    
    -- snap forwards ?
    if p == self.previous_n_players then
      self.current_n_players = self.desired_n_players
    -- snap backwards ?
    else
      self.desired_n_players = p
    end
 
    self.previous_n_players = p 
  end
end

function state:keypressed(key, uni)
  if (key=="escape") then
    GameState.switch(title)
  end
end

function state:leave()
  n_players = math.floor(state.current_n_players)
  audio:play_sound("EGG-drop")
end


function state:draw()

  -- background
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local bgx, bgy = (w - MENU_BG:getWidth())/2, (h - MENU_BG:getHeight())/2
  love.graphics.draw(MENU_BG, bgx, bgy)

  -- play !
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf(language[current_language].player_select.title, w*0.5, h*(0.15 - 0.01*cos), 0.03*sin)

  -- menu options
  love.graphics.setFont(FONT_BIG)

  -- 1. number of human players
  love.graphics.print(language[current_language].player_select.humans, w*0.2, h*0.35)
  for i = 1, useful.round(self.current_n_players) do
    Overlord.draw_static(w*0.47 + i*w/18, h*0.37 + math.cos(i*angle)*6, i)
  end

  -- 2. number of robot players
  love.graphics.print(language[current_language].player_select.robots, w*0.2, h*0.65)
  love.graphics.setFont(FONT_SMALL)
  love.graphics.print(language[current_language].player_select.coming_soon, w*0.5, h*0.67)

  -- 3. arrows
  love.graphics.setColor(255, 255, 255, 255 - (sin+2)*32)
    love.graphics.draw(ARROWS_IMG, w*0.61, h*0.37, 0, 
      1 + 0.05*sin, 
      1 + 0.05*sin, 
      ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
  love.graphics.setColor(255, 255, 255, 255)

  -- borders
  drawBorders()

end



--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state