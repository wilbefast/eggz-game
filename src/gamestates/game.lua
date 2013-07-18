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
  self.n = Overlord(32, 32)


  -- create grid
  self.grid = CollisionGrid(64, 64, 11, 11)

  -- point camera at centre of collision-grid
  self.camera = Camera(0, 0)
  self.camera:lookAt(self.grid:centrePixel())
  self.camera:zoom(scaling.SCALE_MAX)

  
end

function state:enter()
  
end


function state:leave()
end


function state:keypressed(key, uni)
  
  -- quit game
  if key=="escape" then
    love.event.push("quit")
  end
  
end

function state:update(dt)
  GameObject.updateAll(dt)
end


function state:draw()

	self.camera:attach()

		self.grid:draw()

  	GameObject.drawAll()

	self.camera:detach()


end

return state