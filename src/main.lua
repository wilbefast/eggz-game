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
GLOBAL SETTINGS
--]]------------------------------------------------------------

DEBUG = false
MAX_PLAYERS = 4

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

Camera = require("hump/camera")
GameState = require("hump/gamestate")
Class = require("hump/class")
Vector = require("hump/vector-light")

player = require("player")

useful = require("unrequited/useful")
audio = require("unrequited/audio")
scaling = require("unrequited/scaling")
input = require("unrequited/input")
GameObject = require("unrequited/GameObject")
Animation = require("unrequited/Animation")
AnimationView = require("unrequited/AnimationView")
SpecialEffect = require("unrequited/SpecialEffect")

Tile = require("unrequited/Tile")
CollisionGrid = require("unrequited/CollisionGrid")
Plant = require("gameobjects/Plant")
Turret = require("gameobjects/Turret")
Convertor = require("gameobjects/Convertor")
Bomb = require("gameobjects/Bomb")
Egg = require("gameobjects/Egg")
Cocoon = require("gameobjects/Cocoon")
Overlord = require("gameobjects/Overlord")

title = require("gamestates/title")
game = require("gamestates/game")



--[[------------------------------------------------------------
SINGLETON SETTINGS
--]]------------------------------------------------------------

audio.mute = false

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)
    
  -- set up the screen resolution
  local modes = love.graphics.getModes()
  local success = false
  table.sort(modes, function(a, b) 
    return (a.width*a.height > b.width*b.height) end)
  for i, m in ipairs(modes) do
    -- try to set the resolution
    if love.graphics.setMode(m.width, m.height, true) then
      success = true
      break
    end
  end
  if not success then
    print("Failed to set video mode")
    love.event.push("quit")
  end

  -- initialise random
  math.randomseed(os.time())

    -- no mouse
  love.mouse.setVisible(false)
  
  -- window title
  love.graphics.setCaption("Eggz")
  
  -- window icon
  --love.graphics.setIcon()  

  -- load music/sound
  audio:load_music("loop")

  audio:load_sound("EGG-pick")
  audio:load_sound("EGG-drop")
  audio:load_sound("EGG-hatch")
  audio:load_sound("EGG-destroyed")

  audio:load_sound("KNIGHT-attack1")
  audio:load_sound("KNIGHT-attack2")
  audio:load_sound("KNIGHT-attack-hit")
  audio:load_sound("KNIGHT-destroyed")

  audio:load_sound("FOUNTAIN-destroyed")

  audio:load_sound("BOMB-dropped")

  -- start music
  audio:play_music("loop", 0.1)

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
