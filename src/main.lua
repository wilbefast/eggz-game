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

CHEATS = DEBUG
MIN_PLAYERS = 2
MAX_PLAYERS = 4
n_players = 2
n_bots = 0

DELAY_BEFORE_WIN = 10 -- seconds

N_TILES_ACROSS = 19
N_TILES_DOWN = 12
TILE_W = 64
TILE_H = 64
MAP_W = TILE_W*N_TILES_ACROSS
MAP_H = TILE_H*N_TILES_DOWN
MAP_SIZE = math.sqrt(MAP_W*MAP_W + MAP_H*MAP_H)

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
Rock = require("gameobjects/Rock")
Turret = require("gameobjects/Turret")
Convertor = require("gameobjects/Convertor")
Bomb = require("gameobjects/Bomb")
Egg = require("gameobjects/Egg")
  Turret.EVOLUTION = { nil, Egg, nil}
  Convertor.EVOLUTION = { nil, Egg, nil}
Cocoon = require("gameobjects/Cocoon")
  Cocoon.EVOLUTION = { nil, Egg, nil }
AI = require("AI")
Overlord = require("gameobjects/Overlord")

Egg.ICON = Plant.EVOLUTION_ICONS[2][1]
Bomb.ICON = Egg.EVOLUTION_ICONS[1][1]
Turret.ICON = Egg.EVOLUTION_ICONS[2][1]
Convertor.ICON = Egg.EVOLUTION_ICONS[3][1]

title = require("gamestates/title")
language_select = require("gamestates/language_select")
game = require("gamestates/game")
credits = require("gamestates/credits")
player_select = require("gamestates/player_select")
controls = require("gamestates/controls")
howtoplay = require("gamestates/howtoplay")

tutorial = require("tutorial")


--[[------------------------------------------------------------
SINGLETON SETTINGS
--]]------------------------------------------------------------

audio.mute = DEBUG

--[[------------------------------------------------------------
DEAL WITH DIFFERENT RESOLUTIONS (scale images)
--]]------------------------------------------------------------

DEFAULT_W, DEFAULT_H, SCALE_X, SCALE_Y, SCALE_MIN, SCALE_MAX = 1280, 720, 1, 1, 1, 1

function scaled_draw(img, x, y, rot, sx, sy, ox, oy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.draw(img, x*SCALE_MIN + DEFAULT_W*(SCALE_X-SCALE_MIN)/2, 
                          y*SCALE_MIN + DEFAULT_H*(SCALE_Y-SCALE_MIN)/2, 
                          rot, 
                          sx*SCALE_MIN, 
                          sy*SCALE_MIN,
                          ox,
                          oy)
end

function scaled_drawq(img, quad, x, y, rot, sx, sy)
  x, y, rot, sx, sy = (x or 0), (y or 0), (rot or 0), (sx or 1), (sy or 1)
  love.graphics.drawq(img, quad, x*SCALE_MIN, --+ DEFAULT_W*(SCALE_X-SCALE_MIN)/2, 
                                  y*SCALE_MIN, --+ DEFAULT_H*(SCALE_Y-SCALE_MIN)/2, 
                                  rot, 
                                  sx*SCALE_MIN, 
                                  sy*SCALE_MIN,
                                  ox,
                                  oy)
end

function scaled_print(text, x, y)
  love.graphics.push()
    love.graphics.scale(SCALE_MIN, SCALE_MIN)
    love.graphics.translate(x, y)
    love.graphics.print(text, 0, 0)
  love.graphics.pop()
end

function scaled_printf(text, x, y, angle, maxwidth, align)
  love.graphics.push()
    love.graphics.scale(SCALE_MIN, SCALE_MIN)
    love.graphics.translate(x, y)
    if angle then
      love.graphics.rotate(angle)
    end
    love.graphics.printf(text, 0, 0, maxwidth, align)
  love.graphics.pop()
end

local function setBestResolution()
  
  -- get and sort the available screen modes from best to worst
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) 
    return ((a.width*a.height > b.width*b.height)
          and (a.width <= DEFAULT_W) and a.height <= DEFAULT_H) end)
       
  -- try each mode from best to worst
  for i, m in ipairs(modes) do

    if DEBUG then
      if #modes > 1 then
        m = modes[#modes - 1]
      else
        m = { width = 640, height = 480 }
      end
    end
    
    -- try to set the resolution
    local success = love.window.setMode(m.width, m.height, { fullscreen = (not DEBUG) })
    if success then
      SCALE_X, SCALE_Y = m.width/DEFAULT_W, m.height/DEFAULT_H
      SCALE_MIN, SCALE_MAX = math.min(SCALE_X, SCALE_Y), math.max(SCALE_X, SCALE_Y)
      return true -- success!
    
    end
  end
  return false -- failure!
end


--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)
    
  if not setBestResolution() then
    print("Failed to set video mode")
    love.event.push("quit")
  end

  -- initialise random
  math.randomseed(os.time())

    -- no mouse
  love.mouse.setVisible(false)

  -- window title
  love.window.setTitle("Eggz")
  
  -- window icon
  --love.graphics.setIcon()  

  -- initialise input
  input:reset()

  -- clear colour
  love.graphics.setBackgroundColor(3, 9, 3)

  -- load music/sound
  audio:load_music("loop_menu")
  audio:load_music("loop_game")

  audio:load_sound("EGG-pick", 0.4, 2)
  audio:load_sound("EGG-drop", 0.4, 2)
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

  -- check for joysticks
  if love.joystick.getJoystickCount() ~= input.n_pads then
    input:reset()
  end

  -- collect garbage
  collectgarbage("collect")
end

function love.draw()
  GameState.draw()

  if DEBUG then
    log:draw()
  end
end
