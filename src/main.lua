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

DEBUG = true
CHEATS = DEBUG
MAX_PLAYERS = 4
n_players = 4 -- TODO - set in menu

LANGUAGE = "EN" -- TODO - set in menu

MENU_BG = love.graphics.newImage("assets/menu/menubackground.jpg")


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
  Turret.EVOLUTION = { nil, Egg, nil}
  Convertor.EVOLUTION = { nil, Egg, nil}
Cocoon = require("gameobjects/Cocoon")
  Cocoon.EVOLUTION = { nil, Egg, nil }
Overlord = require("gameobjects/Overlord")

title = require("gamestates/title")
game = require("gamestates/game")
credits = require("gamestates/credits")
controls = require("gamestates/controls")


--[[------------------------------------------------------------
SINGLETON SETTINGS
--]]------------------------------------------------------------

audio.mute = true

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
    if love.graphics.setMode(m.width, m.height, (not DEBUG)) then
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

  -- font
  font = love.graphics.newImageFont("assets/GUI/GUI-digits.png", "0123456789%")
  love.graphics.setFont(font)
  

  -- window title
  love.graphics.setCaption("Eggz")
  
  -- window icon
  --love.graphics.setIcon()  

  -- clear colour
  love.graphics.setBackgroundColor(3, 9, 3)

  -- load music/sound
  audio:load_music("loop")

  audio:load_sound("EGG-pick", 0.5, 2)
  audio:load_sound("EGG-drop", 0.5, 2)
  audio:load_sound("EGG-hatch", 1, 4)
  audio:load_sound("EGG-destroyed", 2.3, 3)

  audio:load_sound("KNIGHT-attack1", 0.2, 4)
  audio:load_sound("KNIGHT-attack2", 0.3, 4)
  audio:load_sound("KNIGHT-attack-hit", 0.2, 4)
  audio:load_sound("KNIGHT-destroyed", 3.8, 4)

  audio:load_sound("FOUNTAIN-destroyed", 1, 4)

  audio:load_sound("BOMB-dropped", 2, 2)

  audio:load_sound("intro", 1, 1)

  -- start music
  audio:play_music("loop", 0.06)

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

  -- toggle music
  if key == "backspace" then -- music
    audio:toggle_music()
  elseif key == "c" and CHEATS then -- fast
    Egg.ENERGY_DRAW_EFFICIENCY = 100
    Cocoon.MATURATION_SPEED = 100
    Overlord.EGG_PRODUCTION_SPEED = 100
  end


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
