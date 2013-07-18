--[[
(C) Copyright 2013 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License fDEFAULT_W, DEFAULT_H, zor more details.
--]]

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

GameState = require("hump/gamestate")
Class = require("hump/class")

useful = require("unrequited/useful")
audio = require("unrequited/audio")
scaling = require("unrequited/scaling")
input = require("unrequited/input")
GameObject = require("unrequited/GameObject")

Overlord = require("gameobjects/Overlord")

title = require("gamestates/title")
game = require("gamestates/game")

--[[------------------------------------------------------------
GLOBAL SETTINGS
--]]------------------------------------------------------------

DEBUG = true
audio.mute = false

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)
    
  -- set up the screen resolution
  if (not scaling:setup(1280, 720, (not DEBUG))) then --FIXME
    print("Failed to set mode")
    love.event.push("quit")
  end

  -- initialise random
  math.randomseed(os.time())

  -- go to the initial gamestate
  GameState.switch(title)
end

function love.focus(f)
  GameState.focus(f)
end

function love.quit()
  GameState.quit()
end

function love.keypressed(key, uni)
  GameState.keypressed(key, uni)
end

function keyreleased(key, uni)
  GameState.keyreleased(key)
end

MIN_DT = 1/60
MAX_DT = 1/30
function love.update(dt)
  dt = math.max(MIN_DT, math.min(MAX_DT, dt))
  input:update(dt)
  GameState.update(dt)
end

function love.draw()
  GameState.draw()
end
