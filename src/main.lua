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
n_players = 2

DELAY_BEFORE_WIN = 10 -- seconds

N_TILES_ACROSS = 15
N_TILES_DOWN = 11
TILE_W = 64
TILE_H = 64

BORDER_SIZE = 16


--[[------------------------------------------------------------
GLOBAL RESOURCES
--]]------------------------------------------------------------

-- images
MENU_BG = love.graphics.newImage("assets/menu/menubackground.jpg")

-- font
FONT_SMALL = love.graphics.newFont("assets/font/akaDylan.ttf", 24)
FONT_NORMAL = love.graphics.newFont("assets/font/akaDylan.ttf", 32)
FONT_BIG = love.graphics.newFont("assets/font/akaDylan.ttf", 48)
FONT_HUGE = love.graphics.newFont("assets/font/akaDylan.ttf", 64)
FONT_MASSIVE = love.graphics.newFont("assets/font/akaDylan.ttf", 72)

--[[------------------------------------------------------------
GLOBAL FUNCTIONS
--]]------------------------------------------------------------

-- background
getBackgroundColorWithAlpha = 
  function (a)
    local r, g, b = love.graphics.getBackgroundColor()
    return r, g, b, a
  end

-- borders 
IMG_GRADIENT = love.graphics.newImage("assets/gradient_h.png")

function drawBorders()

  local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
  local w, h = MENU_BG:getWidth(), MENU_BG:getHeight()
  local x, y = (gw - w)/2, (gh - h)/2

  love.graphics.setColor(getBackgroundColorWithAlpha(255))
    -- left
    love.graphics.draw(IMG_GRADIENT, x, y, 0, BORDER_SIZE, h)
    -- right
    love.graphics.draw(IMG_GRADIENT, x+w, y, 0, -BORDER_SIZE, h)
    -- top
    love.graphics.draw(IMG_GRADIENT, x, y, math.pi/2, BORDER_SIZE, -w)
    -- bottom
    love.graphics.draw(IMG_GRADIENT, x, y+h, -math.pi/2, BORDER_SIZE, w)
    
  love.graphics.setColor(255, 255, 255, 255)
end

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

Camera = require("hump/camera")
GameState = require("hump/gamestate")
Class = require("hump/class")
Vector = require("hump/vector-light")

player = require("player")

language = require("language")
useful = require("unrequited/useful")
log = require("unrequited/log")
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

Egg.ICON = Plant.EVOLUTION_ICONS[2][1]
Bomb.ICON = Egg.EVOLUTION_ICONS[1][1]
Turret.ICON = Egg.EVOLUTION_ICONS[2][1]
Convertor.ICON = Egg.EVOLUTION_ICONS[3][1]

title = require("gamestates/title")
language_select = require("gamestates/language_select")
game = require("gamestates/game")
credits = require("gamestates/credits")
controls = require("gamestates/controls")
player_select = require("gamestates/player_select")


--[[------------------------------------------------------------
SINGLETON SETTINGS
--]]------------------------------------------------------------

audio.mute = DEBUG

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

  -- window title
  love.graphics.setCaption("Eggz")
  
  -- window icon
  --love.graphics.setIcon()  

  -- clear colour
  love.graphics.setBackgroundColor(3, 9, 3)

  -- load music/sound
  audio:load_music("loop_menu")
  audio:load_music("loop_game")

  audio:load_sound("EGG-pick", 0.5, 2)
  audio:load_sound("EGG-drop", 0.5, 2)
  audio:load_sound("EGG-hatch", 1, 4)
  audio:load_sound("EGG-destroyed", 2.3, 3)

  audio:load_sound("KNIGHT-attack1", 0.2, 4)
  audio:load_sound("KNIGHT-attack2", 0.3, 4)
  audio:load_sound("KNIGHT-attack-hit", 0.2, 4)
  audio:load_sound("KNIGHT-destroyed", 3.8, 4)

  audio:load_sound("FOUNTAIN-destroyed", 1, 4)

  audio:load_sound("BOMB-dropped", 2, 4)

  audio:load_sound("intro", 1, 1)

  audio:load_sound("tick", 0.8, 1)

  -- go to the initial gamestate
  GameState.switch(language_select)
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
  if key == "m" then -- music
    audio:toggle_music()
  elseif key == "c" and CHEATS then -- cheat
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
	
  input:update(dt, true)
  GameState.update(dt)
end

function love.draw()
  GameState.draw()

  if DEBUG then
    log:draw()
  end
end
