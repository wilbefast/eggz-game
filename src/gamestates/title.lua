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
TITLE GAMESTATE
--]]------------------------------------------------------------

local bg = love.graphics.newImage("assets/menu/MENU-bg.png")
local play = love.graphics.newImage("assets/menu/MENU-play-EN.png")


local state = GameState.new()

function state:init()
end

function state:enter()
end


function state:leave()
end


function state:keypressed(key, uni)
  
  -- quit game
  if key=="escape" then
    love.event.push("quit")
    
  elseif key=="return" then
    GameState.switch(game)
  end
  
end

function state:update(dt)
end


function state:draw()
  love.graphics.draw(bg, 
  	(love.graphics.getWidth()-bg:getWidth())/2, 
  	(love.graphics.getHeight()-bg:getHeight())/2)

  love.graphics.draw(play, 
  	(love.graphics.getWidth()-play:getWidth())/2, 
  	514)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state