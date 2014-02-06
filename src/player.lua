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

local player = {}


--[[---------------------------------------------------------------------------
PLAYER 1 - RED
--]]

player[1] = 
{
	-- red
	name = "Red",
	bindTeamColour = function (a) love.graphics.setColor(255, 0, 0, a or 255) end,
}


--[[---------------------------------------------------------------------------
PLAYER 2 - BLUE
--]]

player[2] = 
{
	-- blue
	name = "Blue",
	bindTeamColour = function (a) love.graphics.setColor(0, 120, 255, a or 255) end,
}


--[[---------------------------------------------------------------------------
PLAYER 3 - YELLOW
--]]

player[3] = 
{
	-- yellow
	name = "Yellow",
	bindTeamColour = function (a) love.graphics.setColor(255, 255, 0, a or 255) end,
}


--[[---------------------------------------------------------------------------
PLAYER 4 - PURPLE
--]]

player[4] = 
{
	-- purple
	name = "Purple",
	bindTeamColour = function (a) love.graphics.setColor(160, 0, 255, a or 255) end,
}


--[[---------------------------------------------------------------------------
ALL PLAYER
--]]

for i, p in ipairs(player) do

	p.ai_controlled = false -- by default

	p.pop_ups = { }

	p.update = function(dt)
		useful.map(p.pop_ups, function(pu, _, _) 
			pu.life = pu.life - dt
			if pu.life <= 0 then 
				pu.life, pu.purge = 0, true 
			elseif pu.life + dt >= 1 then
				pu.message = tostring(math.floor(p.total_conversion*100)) .. "%"
			end
		end)
	end

	p.draw = function()
		for _, pu in ipairs(p.pop_ups) do
			if pu.life <= 1 then
	      p.bindTeamColour(math.min(255, 2*pu.life*pu.life*255))
	      love.graphics.setFont(FONT_HUGE)
	      love.graphics.printf(pu.message, pu.x, pu.y - (1 - pu.life)*128, 0, "center")
	      love.graphics.setColor(255, 255, 255)
      end
  	end
	end

	p.show_conversion = function(x, y, force_life)
 		table.insert(p.pop_ups, { x = x, y = y, life = (force_life or 2) }) 
  end

  p.report_damage = function(attacker, defender)
  	if p.ai_controlled then
  		game.overlords[i].ai:attackedBy(attacker.player, defender)
  	end
	end
end

--[[---------------------------------------------------------------------------
EXPORT
--]]

return player