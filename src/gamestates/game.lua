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
  for i = 1, n_players do
    self.overlords[i] = Overlord(player.startPosition[i].x, player.startPosition[i].y, i)
  end

  -- create grid
  self.grid = CollisionGrid(64, 64, 11, 11)
  GameObject.COLLISIONGRID = self.grid

  -- point camera at centre of collision-grid
  self.camera = Camera(0, 0)
  self.camera:lookAt(self.grid:centrePixel())

  -- not victory (yet)
  self.winner = false
	
	-- not pause (yet)
	self.pause = false
end

function state:keypressed(key, uni)
  
  -- quit game
  if (key=="escape") then
    GameState.switch(title)
  end

end

function state:update(dt)

	-- input
	for i = 1, n_players do
		-- check for pause key
		if input[i]:keyCancel() then
			self.pause = true
		end
		
		-- check for unpause key
		if input[i]:keyConfirm() then
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
			
			-- check for victory
			for i = 1, n_players do
				if player.total_conversion[i] > 1/n_players then
					-- we have a winner !
					self.winner = i
					audio.music:stop()
					audio:play_sound("intro")
					break
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
      score.x, score.y = useful.lerp(score.x, player.startPosition[i].x, 3*dt), 
                                useful.lerp(score.y, player.startPosition[i].y, 3*dt)
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

  		if o.x < o.w then
  			o:draw(o.x + w, o.y)
			elseif o.x > w-o.w then
  			o:draw(o.x - w, o.y)
  		end

  		if o.y < o.h*3 then
  			o:draw(o.x, o.y + h)
			elseif o.y > h-o.y then
  			o:draw(o.x, o.y - h)
  		end

  	end

    if (not self.winner) and (not self.pause) then

      -- gui overlay
      for _, overlord in ipairs(self.overlords) do
        overlord:draw_radial_menu()
        overlord:draw_percent_conversion()
      end

    else
      
      -- dark overlay
      local r, g, b = love.graphics.getBackgroundColor()
      love.graphics.setColor(r, g, b, 200)
        love.graphics.rectangle("fill", 0, 0, gw/2, gh)
      love.graphics.setColor(255, 255, 255)

      -- draw avatars & score
			if self.winner then
				for i, score in ipairs(self.scoreboard) do
					self.overlords[i]:draw_icon(score.x, score.y)
					self.overlords[i]:draw_percent_conversion(score.x, score.y)
				end
			end
    end


	self.camera:detach()

	-- borders 
  love.graphics.setColor(love.graphics.getBackgroundColor())
  	-- left
    love.graphics.rectangle("fill", 0, 0, x, gh)
    -- right
    love.graphics.rectangle("fill", x+w, 0, gw-x-w, gh)
    -- top
    love.graphics.rectangle("fill", x, 0, w, y)
    -- bottom
    love.graphics.rectangle("fill", x, y+h, w, gh-y-h)
  love.graphics.setColor(255, 255, 255, 255)


end

return state