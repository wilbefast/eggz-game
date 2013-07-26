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

  self.player = {}
  self.player[1] = Overlord(64*11 - 32,         64*6 - 32,    1)
  self.player[2] = Overlord(32,                 64*6 - 32,    2)
  --self.player[3] = Overlord(64*6 - 32,          32,           3)
  --self.player[4] = Overlord(64*6 - 32,          64*11 - 32,   4)

  -- create grid
  self.grid = CollisionGrid(64, 64, 11, 11)
  GameObject.COLLISIONGRID = self.grid

  -- point camera at centre of collision-grid
  self.camera = Camera(0, 0)
  self.camera:lookAt(self.grid:centrePixel())

  -- not victory (yet)
  self.winner = false
end


function state:leave()
end


function state:keypressed(key, uni)
  
  -- quit game
  if (key=="escape") then
    GameState.switch(title)
  end

end

function state:update(dt)

  if not self.winner then

    GameObject.updateAll(dt)

    self.grid:update(dt)

    for i = 1, n_players do
      if player.total_conversion[i] > 1/n_players then
        self.winner = i
      end
    end

  end

end


function state:draw()

	self.camera:attach()

    -- game objects
		self.grid:draw()
  	GameObject.drawAll()

    if not self.winner then

      -- gui overlay
      for _, p in ipairs(self.player) do
        p:draw_radial_menu()
        p:draw_percent_conversion()
      end

    else
      
      -- dark overlay
      local r, g, b = love.graphics.getBackgroundColor()
      love.graphics.setColor(r, g, b, 200)
        love.graphics.rectangle("fill", 0, 0, self.grid.tilew*self.grid.w, self.grid.tileh*self.grid.h)
      love.graphics.setColor(255, 255, 255)

      -- draw avatars
      for _, p in ipairs(self.player) do
        p:draw()
        p:draw_percent_conversion()
      end
    end


	self.camera:detach()


end

return state