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
GAME GAMESTATE
--]]------------------------------------------------------------

local state = GameState.new() 

function state:init() 
end

function state:reset_winning()
  self.winner = false
  for _, p in ipairs(player) do
    p.winning = 0
    p.win_warnings = 0
  end
end

function state:enter()

  GameObject.INSTANCES = { }
  GameObject.NEW_INSTANCES = { }

  self.overlords = {}
  for i = 1, n_players do
    self.overlords[i] = Overlord(player[i].startPosition.x, player[i].startPosition.y, i)
  end

  -- create grid
  self.grid = CollisionGrid(TILE_W, TILE_H, N_TILES_ACROSS, N_TILES_DOWN)
  GameObject.COLLISIONGRID = self.grid

  -- point camera at centre of collision-grid
  self.camera = Camera(0, 0)
  self.camera:lookAt(self.grid:centrePixel())

  -- not victory (yet)
  for _, p in ipairs(player) do
    p.total_conversion = 0
    p.tutorial = 1
  end
  self:reset_winning()
	
  -- log percents
  self.gamelog = { highest = 0, total_time = 0, time_till_next = 3, period = 3, animation = 0 }

	-- not pause (yet)
	self.pause = false

  -- player game music
  audio:play_music("loop_game", 0.2)
end

function state:keypressed(key, uni)
  
  -- quit game
  if key=="escape" then
    GameState.switch(player_select)
  end

end

function state:update(dt)


  -- log conversion amount
  if (not self.winner) and (not self.pause) then
    self.gamelog.time_till_next = self.gamelog.time_till_next - dt
    self.gamelog.total_time = self.gamelog.total_time + dt
    if self.gamelog.time_till_next < 0 then
      self.gamelog.time_till_next = self.gamelog.period

      -- create log entry with timestamp
      local log_entry = { time_stamp = self.gamelog.total_time }
      -- at each player's conversion to log entry
      for i = 1, n_players do
        local log_value = player[i].total_conversion
        log_entry[i] = log_value
        
        if log_value > self.gamelog.highest then
          self.gamelog.highest = log_value
        end
      end

      self.gamelog[#(self.gamelog) + 1] = log_entry
    end
  -- log animation
  elseif self.winner then
    self.gamelog.animation = math.min(self.gamelog.animation + dt)
  end



	-- input
	for i = 1, n_players do

		-- check for pause key
		if input[i].cancel.trigger == 1 then
			self.pause = (not self.pause)
      break -- multiple player have the same cancel key 
		end
		
		-- check for unpause key
		if (input[i].confirm.trigger == 1) or (input[i].start.trigger == 1) then
			self.pause = false
		end
	end

  -- no winner yet
  if (not self.winner) then

		if not self.pause then
			-- update games objects
			GameObject.updateAll(dt)

			-- update grid tiles
			self.grid:update(dt)

      -- find player with highest conversion
      local highest_conversion, highest_conversion_i = -1, -1
      local second_highest_conversion, second_highest_conversion_i = -1, -1
      for i = 1, n_players do
        local conversion = player[i].total_conversion
        -- new best ?
        if conversion > highest_conversion then
          -- YES - the new runner up is the old leader ...
          second_highest_conversion = highest_conversion
          second_highest_conversion_i = highest_conversion_i
          -- ... and the new leader in the race is ...
          highest_conversion = conversion
          highest_conversion_i = i
        else
          -- NOPE - and there are no prizes for second best :'(
          player[i].winning = 0
          player[i].win_warnings = 0 

          -- new second best ?
          if conversion > second_highest_conversion then
            -- YEP - the runner-up is overtaken 
            second_highest_conversion_i = i 
            second_highest_conversion = conversion
          end   
        end
      end
			
			-- check for victory
      local p = player[highest_conversion_i]
      --if (p.total_conversion > 0.05)
      if (p.total_conversion > 1/n_players)
      and (highest_conversion > second_highest_conversion + 0.01) then
      -- check if countdown to win has expired
        if p.winning > DELAY_BEFORE_WIN then
          -- we have a winner !
          self.winner = highest_conversion_i
          audio.music:stop()
          audio:play_sound("intro")
        else
          

          -- warn other players with a "tick tock"!
          if p.winning == 0 then
            audio:play_sound("tick")
          elseif (math.floor(p.winning) > p.win_warnings)
          and (p.winning < DELAY_BEFORE_WIN) then
            p.win_warnings = p.win_warnings + 1
            audio:play_sound("tick")
          end 
          -- count down to win
          p.winning = p.winning + dt
				end

      else -- nobody winning :'(
        self:reset_winning()
			end
		end
  end

end


function state:draw()

	local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
	local w, h = self.grid.w*self.grid.tilew, self.grid.h*self.grid.tileh
	local x, y = (gw - w)/2, (gh - h)/2

	self.camera:attach()

    -- game objects
		self.grid:draw()
  	GameObject.drawAll()
    
    -- draw extra overlords for map torus lapping
  	for i = 1, n_players do
  		local o = self.overlords[i]

  		if o.x < o.w*3 then
  			o:draw(o.x + w, o.y)
			elseif o.x > w-o.w*3 then
  			o:draw(o.x - w, o.y)
  		end

  		if o.y < o.h*5 then
  			o:draw(o.x, o.y + h)
			elseif o.y > h-o.y then
  			o:draw(o.x, o.y - h)
  		end

  	end

    if (not self.winner) and (not self.pause) then
      -- business as usual
    else 
      -- dark overlay
      local r, g, b = love.graphics.getBackgroundColor()
      love.graphics.setColor(r, g, b, 200)
        love.graphics.rectangle("fill", -self.grid.tilew, -self.grid.tileh, gw, gh)
      love.graphics.setColor(255, 255, 255)

      -- PAUSED - draw 'paused' text
      if self.pause then
        love.graphics.setFont(FONT_BIG)
        love.graphics.printf("Paused", w/2, h/2, 0, "center")
      end
    end


  --- !!!
	self.camera:detach()
  --- !!!


  -- borders 
  local tw, th = self.grid.tilew, self.grid.tileh
  love.graphics.setColor(getBackgroundColorWithAlpha(255))
    -- left
    love.graphics.rectangle("fill", 0, 0, x-tw, gh)
    love.graphics.draw(IMG_GRADIENT, x-tw, y-th, 0, tw, h+2*th)
    -- right
    love.graphics.rectangle("fill", x+w+tw, 0, gw-x-w-tw, gh)
    love.graphics.draw(IMG_GRADIENT, x+w+tw, y-th, 0, -tw, h+2*th)
    -- top
    love.graphics.rectangle("fill", x-tw, 0, w+2*tw, y-th)
    love.graphics.draw(IMG_GRADIENT, x-tw, y-th, math.pi/2, tw, -w-2*tw)
    -- bottom
    love.graphics.rectangle("fill", x, y+h+th, w, gh-y-h-th)
    love.graphics.draw(IMG_GRADIENT, x-tw, y+h+th,  -math.pi/2, tw, w+2*tw)
    
  love.graphics.setColor(255, 255, 255, 255)


  --- !!!
  self.camera:attach()
  --- !!!

  for _, overlord in ipairs(self.overlords) do

    -- draw radial menu
    if not self.winner then
      overlord:draw_radial_menu()
    end

    -- draw percent conversion
    local x, y = player[overlord.player].ui.x, player[overlord.player].ui.y
    love.graphics.setFont(FONT_HUGE)
    local total_conversion = math.floor(player[overlord.player].total_conversion*100)
      love.graphics.setColor(210, 228, 210)
        love.graphics.printf(tostring(total_conversion) .. "%", x+3, y+3, 0, 'center')
      player[overlord.player].bindTeamColour()
        love.graphics.printf(tostring(total_conversion) .. "%", x, y, 0, 'center')
    love.graphics.setColor(255, 255, 255)

    -- draw eggz in "storage" ready to be laid
    -- if overlord.egg_ready > 0 then
    --   player[overlord.player].bindTeamColour()
    --   love.graphics.setFont(FONT_SMALL)
    --     if overlord.egg_ready == 1 then
    --       local flux = math.cos(overlord.wave)
    --       love.graphics.draw(Egg.IMAGES.FILL, x, y+128, 0, 1.3+flux*0.1, 1.3+flux*0.1, 32, 40)
    --       -- love.graphics.setColor(210, 228, 210)
    --       -- love.graphics.printf("Egg!", x, y+108, 0, "center")
    --     else
    --       love.graphics.draw(Egg.IMAGES.OUTLINE, x, y+128, 0, 1.2, 1.2, 32, 40)
    --       local seconds = tostring(math.floor((1 - overlord.egg_ready)/Overlord.EGG_PRODUCTION_SPEED) + 1)
    --       love.graphics.printf(seconds, x, y+108, 0, "center")
    --     end
    --     love.graphics.setColor(255, 255, 255)
    -- end

  end



  if self.winner then

    -- graph players' progression
    love.graphics.setLineWidth(3)

    local max_log_i = self.gamelog.animation*(#(self.gamelog))

    previous =  { x = 0, y = h*0.9 }
    current = { }
    for i = 1, n_players do  
      player[i].bindTeamColour(220)
      
      for log_i, entry in ipairs(self.gamelog) do

        if log_i > max_log_i then
          break
        end

        current.x, current.y = (entry.time_stamp/self.gamelog.total_time) * w - 2*i, 
                                (0.1 + (1 - entry[i]/self.gamelog.highest)*0.8) * h - 2*i
        love.graphics.line(previous.x, previous.y, current.x, current.y)
        previous.x, previous.y = current.x, current.y
      end 
      previous.x, previous.y = 0, h*0.9
  
    end

    -- display 'winner is X' text
    player[self.winner].bindTeamColour()
      love.graphics.setFont(FONT_HUGE)
      useful.printf(language[current_language].colour[self.winner] .. " " ..
                    language[current_language].wins, w*0.5, 0)
    love.graphics.setColor(255, 255, 255)
end

  --- !!!
  self.camera:detach()
  --- !!!


end

return state