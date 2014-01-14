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

state.freeze_mode = false

local PLAYER_TYPES = {}
useful.bind(PLAYER_TYPES, "human", 1)
useful.bind(PLAYER_TYPES, "ai", 2)

state.players = {}
state.players[PLAYER_TYPES["human"]] =
{
  previous_number = n_players,
  current_number = n_players,
  desired_number = n_players,
  direction = 1
}

state.players[PLAYER_TYPES["ai"]] =
{
  previous_number = n_bots,
  current_number = n_bots,
  desired_number = n_bots,
  direction = -1
}

function state:enter()
  audio:play_music("loop_menu", 0.06)
  self.player_type = PLAYER_TYPES["human"]
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
  local v_input = false

  -- bots or humans ?
  local p_type = self.players[self.player_type]

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

    -- ... request a change from bots to player or vice-versa
    if (input[i].y ~= 0) and (not v_input) then
      v_input = true
      if not self.freeze_mode then
        self.player_type = (self.player_type + 1)
        if self.player_type > #PLAYER_TYPES then
          self.player_type = 1
          -- refresh "bots or humans ?"
          p_type = self.players[self.player_type]
        end
        self.freeze_mode = true
      end
    end

    -- ... request a change in the number of players/bots ?
    if (input[i].x ~= 0) then
      h_input = true

      local new_desired_number = useful.round(p_type.current_number) 
        + p_type.direction*useful.sign(input[i].x)
      if new_desired_number < 0 then
        self.player_type = self.player_type%2 + 1
        return 
      end
      new_desired_number = useful.clamp(new_desired_number, 0, MAX_PLAYERS)

      if (p_type.desired_number == p_type.current_number) 
      and (new_desired_number ~= p_type.current_number) then
        audio:play_sound("EGG-pick")
      end

      p_type.desired_number = new_desired_number
    end
  end

  -- apply horizontal input
  p_type.current_number 
    = useful.lerp(p_type.current_number, p_type.desired_number, dt*5)

  -- make sure there are always between 2 and 4 players of all types combined
  if not self.freeze_mode then
    p_other_type = self.players[self.player_type%2 + 1]
    local n1, n2 = useful.round(p_type.current_number), useful.round(p_other_type.current_number)
    if n1 + n2 > MAX_PLAYERS then
      p_other_type.current_number = MAX_PLAYERS - n1
      p_other_type.previous_number = p_other_type.current_number 
      p_other_type.desired_number = p_other_type.current_number 
    elseif n1 + n2 < MIN_PLAYERS then
      p_other_type.current_number = MIN_PLAYERS - n1
      p_other_type.previous_number = p_other_type.current_number 
      p_other_type.desired_number = p_other_type.current_number 
      if n1 == 0 then
        self.player_type = self.player_type%2 + 1
      end
    end
  end

  
  -- has horizontal input ceased ?
  if not h_input then

    local p = useful.round(p_type.current_number)
    
    -- snap forwards ?
    if p == p_type.previous_number then
      p_type.current_number = p_type.desired_number
    -- snap backwards ?
    else
      p_type.desired_number = p
    end
 
    p_type.previous_number = p 
  end


  -- has vertical input ceased ?
  if self.freeze_mode and (not v_input) then
    self.freeze_mode = false
  end

end

function state:keypressed(key, uni)
  if (key=="escape") then
    GameState.switch(title)
  end
end

function state:leave()
  n_players = useful.round(state.players[PLAYER_TYPES.human].current_number)
  n_bots = useful.round(state.players[PLAYER_TYPES.ai].current_number)
  audio:play_sound("EGG-drop")
end


function state:draw()

  -- cache
  local w, h = DEFAULT_W, DEFAULT_H

  -- background
  scaled_draw(MENU_BG, w*0.5, h*0.5, 0, 0.8, 0.8, MENU_BG:getWidth()*0.5, MENU_BG:getHeight()*0.5)

  -- title
  love.graphics.setFont(FONT_MASSIVE)
  useful.printf(language[current_language].player_select.title, w*0.5, h*(0.1 - 0.01*cos), 0.03*sin)

  -- menu options
  love.graphics.setFont(FONT_BIG)

  -- 1. number of human players
  useful.printf(language[current_language].player_select.humans, w*0.2, h*0.4)
  for i = 1, useful.round(self.players[PLAYER_TYPES.human].current_number) do
    Overlord.draw_static(w*0.45 + i*w*0.065, h*0.42 + math.cos(angle + i*math.pi*1.618)*6, i)
  end

  -- 2. number of robot players
  useful.printf(language[current_language].player_select.robots, w*0.2, h*0.7)
  for i = 1, useful.round(self.players[PLAYER_TYPES.ai].current_number)  do
    Overlord.draw_static(w*0.775 - i*w*0.065, h*0.68 + math.cos(angle + i*math.pi*1.618)*6, 
      MAX_PLAYERS - i + 1)
  end
  --love.graphics.setFont(FONT_SMALL)
  --scaled_print(language[current_language].player_select.coming_soon, w*0.5, h*0.73)

  -- 3. arrows
  local arrow_y = useful.tri(self.player_type == PLAYER_TYPES["human"],
                    h*0.37, h*0.7)
  love.graphics.setColor(255, 255, 255, 255 - (sin+2)*32)
    scaled_draw(ARROWS_IMG, w*0.61, arrow_y, 0, 
      1 + 0.05*sin, 
      1 + 0.05*sin, 
      ARROWS_IMG:getWidth()/2, ARROWS_IMG:getHeight()/2)
  love.graphics.setColor(255, 255, 255, 255)
end



--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state