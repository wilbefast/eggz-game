--[[
(C) Copyright 2013 William Dyce

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
EGG GAMEOBJECT
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local Egg = Class
{
  type = GameObject.TYPE.new("Egg"),

  ENERGY_DRAW_SPEED = 0.3, 						-- per second
  ENERGY_CONSUME_SPEED = 0, 					-- per second
  ENERGY_DRAW_EFFICIENCY = 0.7, 				-- percent
  ENERGY_START = 0.1, 									--0.3
  MAX_W = 24,
  MAX_H = 24,

  EVOLUTION = { Bomb, Turret, Convertor},

  maturationTime = 15, -- seconds - after being recycled

  REGEN_EFFICIENCY = 1,

  ARMOUR = 0,

  wobble = 0,
  wobble_time = 0,

  init = function(self, tile, player)
    Plant.init(self, tile, player)

    self.view = AnimationView(Egg.ANIMS[self.player][1], 4, 1, 32, 50)
  end,
}
Egg:include(Plant)
Egg.class = Egg

--[[------------------------------------------------------------
Resources
--]]--

Egg.EVOLUTION_ICONS =
{
  { 
    love.graphics.newImage("assets/menu_bomb.png"), 
    love.graphics.newImage("assets/menu_bomb_hover.png")
  },
  {
    love.graphics.newImage("assets/menu_tower.png"),
    love.graphics.newImage("assets/menu_tower_hover.png")
  },
  {
    love.graphics.newImage("assets/menu_convert.png"),
    love.graphics.newImage("assets/menu_convert_hover.png")
  }
}

Egg.IMAGES = 
{
	-- RED
	{
		{ 
			love.graphics.newImage("assets/red_egg_a.png"), 
			love.graphics.newImage("assets/red_egg_pick_a.png")
		},
		{ 
			love.graphics.newImage("assets/red_egg_b.png"),
			love.graphics.newImage("assets/red_egg_pick_b.png")
		},
		{ 
			love.graphics.newImage("assets/red_egg_c.png"),
			love.graphics.newImage("assets/red_egg_pick_c.png")
		}
	},
	-- BLUE
	{
		{ 
			love.graphics.newImage("assets/blue_egg_a.png"), 
			love.graphics.newImage("assets/blue_egg_pick_a.png")
		},
		{ 
			love.graphics.newImage("assets/blue_egg_b.png"),
			love.graphics.newImage("assets/blue_egg_pick_b.png")
		},
		{ 
			love.graphics.newImage("assets/blue_egg_c.png"),
			love.graphics.newImage("assets/blue_egg_pick_c.png")
		}
	},
	-- YELLOW
	{
		{ 
			love.graphics.newImage("assets/yellow_egg_a.png"), 
			love.graphics.newImage("assets/yellow_egg_pick_a.png")
		},
		{ 
			love.graphics.newImage("assets/yellow_egg_b.png"),
			love.graphics.newImage("assets/yellow_egg_pick_b.png")
		},
		{ 
			love.graphics.newImage("assets/yellow_egg_c.png"),
			love.graphics.newImage("assets/yellow_egg_pick_c.png")
		}
	},
	-- PURPLE
	{
		{ 
			love.graphics.newImage("assets/purple_egg_a.png"), 
			love.graphics.newImage("assets/purple_egg_pick_a.png")
		},
		{ 
			love.graphics.newImage("assets/purple_egg_b.png"),
			love.graphics.newImage("assets/purple_egg_pick_b.png")
		},
		{ 
			love.graphics.newImage("assets/purple_egg_c.png"),
			love.graphics.newImage("assets/purple_egg_pick_c.png")
		}
	},

	OUTLINE = love.graphics.newImage("assets/egg_outline.png"),
	FILL = love.graphics.newImage("assets/egg_full.png")
}

Egg.ANIMS = {}
-- for each player
for i = 1, #Egg.IMAGES do
	Egg.ANIMS[i] = {}
	local evolution_images = Egg.IMAGES[i]
	-- for each evolution level
	for j = 1, #evolution_images do
  	Egg.ANIMS[i][j] = Animation(Egg.IMAGES[i][j][1], 64, 64, 6)
	end
end

--[[------------------------------------------------------------
Evolve
--]]--

function Egg:canEvolve()
	return (Plant.canEvolve(self) and self.energy == 1)
end

--[[------------------------------------------------------------
Take damage
--]]--

function Egg:die()
	Plant.die(self)
  audio:play_sound("EGG-destroyed")
end


--[[------------------------------------------------------------
Pick up and put down
--]]--

function Egg:plant(tile)
	Plant.plant(self, tile)
	audio:play_sound("EGG-drop")
end

function Egg:uproot(tile)
	Plant.uproot(self, tile)
	audio:play_sound("EGG-pick")
end

--[[------------------------------------------------------------
Accessors
--]]--

function Egg:getEvolution()
	local evolution = 1
	if self.energy > 0.5 then
		if self.energy == 1 then
			evolution = 3
		else
			evolution = 2
		end
	end
	return evolution
end

--[[------------------------------------------------------------
Game loop
--]]--

function Egg:update(dt)
	Plant.update(self, dt)

	self.view.speed = 5 + 5*self.eat.amount
	self.view:update(dt)

	local evo = self:getEvolution()
	self.view.anim = Egg.ANIMS[self.player][evo]

	self.ARMOUR = (evo - 1)*0.75

  if evo == 3 then
	  self.wobble_time = self.wobble_time + 15*dt
	  if self.wobble_time > 2*math.pi then
	  	self.wobble_time = self.wobble_time - 2*math.pi
	  end
		self.wobble = 0.2*math.cos(self.wobble_time)
	end
end

function Egg:draw(x, y)
		x, y = x or self.x, y or self.y

		if self.transport then
			return
		end

		local ev = self:getEvolution()
		-- love.graphics.draw(Egg.IMAGES[self.player][ev][1],
		-- 	x, 
		-- 	y,
		-- 	self.wobble,
		-- 	1, 1, 32, 50)
		self.view:draw(self, x, y, self.wobble)

		-- stun overlay
	  if self.stunned then
	  	local size = 0.8 + (ev-1)*0.2
    	love.graphics.draw(Plant.IMG_STUN, x, y, 0, size, -size, 32, 30 - (ev-1)*5)
    end
		
		-- eat overlay
		--love.graphics.draw(Plant.IMG_EAT, self.x, self.y)
		love.graphics.setColor(155, 255, 200, self.eat.amount*255)
			self.eat:draw(self)

		-- reset
		love.graphics.setColor(255, 255, 255)

		-- draw overlay
		Plant.draw(self)
end

function Egg:drawTransported(x, y)
	x, y = x or self.x, y or self.y
		love.graphics.draw(Egg.IMAGES[self.player][self:getEvolution()][2],
			x, 
			y,
			0,
			1, 1, 26, 55)
end


--[[------------------------------------------------------------
Export
--]]--

return Egg