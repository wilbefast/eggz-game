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

function state:enter()

  GameObject.INSTANCES = { }
  GameObject.NEW_INSTANCES = { }

  self.overlords = {}
  local i = 1
  for i = 1, n_players do
    self.overlords[i] = Overlord(player[i].startPosition.x, player[i].startPosition.y, i)
    i = i + 1
  end

  -- create grid
  self.grid = CollisionGrid(TILE_W, TILE_H, N_TILES_ACROSS, N_TILES_DOWN)
  GameObject.COLLISIONGRID = self.grid

  -- point camera at centre of collision-grid
  self.camera = Camera(0, 0)
  self.camera:lookAt(self.grid:centrePixel())

  -- not victory (yet)
  self.winner = false
	
	-- not pause (yet)
	self.pause = false

  -- player game music
  audio:play_music("loop_game", 0.1)
end

function state:keypressed(key, uni)
  
  -- quit game
  if (key=="escape") then
    GameState.switch(player_select)
  end

end

function state:update(dt)
	-- input
	for i = 1, n_players do
		-- check for pause key
		if input[i].cancel.trigger == 1 then
			self.pause = (not self.pause)
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
      if (p.total_conversion > 1/n_players)
      and (highest_conversion > second_highest_conversion + 0.05) then
      -- check if countdown to win has expired
        if p.winning > DELAY_BEFORE_WIN then
          -- we have a winner !
          self.winner = highest_conversion_i
          audio.music:stop()
          audio:play_sound("intro")
        else
          -- count down to win
          p.winning = p.winning + dt
          -- warn other players with a "tick tock"!
          if (math.floor(p.winning) > p.win_warnings)
          and (p.winning < DELAY_BEFORE_WIN) then
            p.win_warnings = p.win_warnings + 1
            --audio:play_sound("ticktock")
          end 
				end
			end

			-- as soon as winner is announced
			if self.winner then
				self.scoreboard = { }
				for i, overlord in ipairs(self.overlords) do
					self.scoreboard[i] = { x = overlord.x, y = overlord.y }
				end
			end
		end

  -- winner previously announced
  else
    for i, score in ipairs(self.scoreboard) do
      score.x, score.y = useful.lerp(score.x, player[i].startPosition.x, 3*dt), 
                                useful.lerp(score.y, player[i].startPosition.y, 3*dt)
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
        love.graphics.rectangle("fill", 0, 0, gw, gh)
      love.graphics.setColor(255, 255, 255)

      -- PAUSED - draw 'paused' text
      if self.pause then
        love.graphics.setFont(FONT_BIG)
        love.graphics.printf("Paused", w/2, h/2, 0, "center")
      end

      -- WINNING - draw avatars & score
			if self.winner then
				for i, score in ipairs(self.scoreboard) do
					self.overlords[i]:draw_icon(score.x, score.y)
					self.overlords[i]:draw_percent_conversion(score.x, score.y)
				end
			end
    end


  --- !!!
	self.camera:detach()
  --- !!!


  -- borders 
  love.graphics.setColor(getBackgroundColorWithAlpha(255))
    -- left
    love.graphics.rectangle("fill", 0, 0, x-self.grid.tilew, gh)
    love.graphics.draw(IMG_GRADIENT, x-self.grid.tilew, 0, 0, self.grid.tilew, gh)
    -- right
    love.graphics.rectangle("fill", x+w+self.grid.tilew, 0, gw-x-w-self.grid.tilew, gh)
    love.graphics.draw(IMG_GRADIENT, x+w+self.grid.tilew, 0, 0, -self.grid.tilew, gh)
    -- top
    love.graphics.rectangle("fill", 0, 0, w, y-self.grid.tileh)
    love.graphics.draw(IMG_GRADIENT, gw, 0, math.pi/2, self.grid.tilew, gw)
    -- bottom
    love.graphics.rectangle("fill", x, y+h+self.grid.tileh, w, gh-y-h-self.grid.tileh)
    love.graphics.draw(IMG_GRADIENT, 0, gh, -math.pi/2, self.grid.tilew, gw)
    
  love.graphics.setColor(255, 255, 255, 255)


  --- !!!
  self.camera:attach()
  --- !!!


  -- player UI and radial menus
    if (not self.winner) and (not self.pause) then
  		for i = 1, n_players do
	      -- gui overlay
	      for _, overlord in ipairs(self.overlords) do
	        overlord:draw_radial_menu()
	        overlord:draw_percent_conversion()
	      end
    	end
		end
  self.camera:detach()


end

return state