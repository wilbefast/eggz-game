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
ARTIFICIAL INTELLIGENCE, A FAKE INPUT GENERATOR
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Initialisation
--]]--

local AI = Class
{
  init = function(self, overlord)

  	-- mind-body split
  	self.body = overlord
  	self.player = overlord.player

  	-- fake input
  	self.x, self.y = 0, 0
  	self.confirm =
  	{
  		pressed = false,
  		trigger = 0
  	}

  	-- plan, a list of instructions
  	self.plan = {}

    -- -- create the collision map
    -- for x = 1, game.grid.w do
    --   for y = 1, game.grid.h do
    --   	local t = game.grid.tiles[x][y]
    --   	if not t.utility then t.utility = {} end
    --   	t.utility[self] = 
    --   	{
    --   		predators = 0,
    --   		prey = 0
    --   	}
    --   end
    -- end
	end
}

--[[------------------------------------------------------------
Utility
--]]--

-- function AI:calculateUtility()
-- end

--[[------------------------------------------------------------
Navigation
--]]--

function AI:planGoto(tile)
	table.insert(self.plan, { method = self.doGoto, target = tile })
end

function AI:doGoto(tile)
	self.x, self.y = Vector.normalize(
		tile.x + 0.5*TILE_W - self.body.x, 
		tile.y + 0.5*TILE_H - self.body.y)

	-- are we there yet?
	return (self.body.tile == tile)
end

function AI:doStop()
	self.x, self.y = 0, 0
	self.confirm.pressed = false
	self.confirm.trigger = 0
end

--[[------------------------------------------------------------
Take-off and landing
--]]--

--[[------------------------------------------------------------
Laying
--]]--

function AI:getBestLayingTile()
		local best_tile, best_utility = nil, -math.huge

		game.grid:map(function(tile, x, y)

			-- ignore occupied tiles
			if tile.occupant then
				return
			end

			-- add the tile energy
			local utility = tile.energy

			-- bonus if the tile is our colour
			if tile.owner == self.player then
				utility = utility + tile.conversion*2
			end

			-- subtract utility for each defender
			for i = 1, n_players do
				if i ~= self.player then
					utility = utility - tile.defenders[1]*4
				end
			end

			-- prefer closer tiles
			utility = utility - 
				Vector.len(self.body.x - tile.x, self.body.y - tile.y) / MAP_SIZE

			-- best utility ?
			if utility > best_utility then
				best_utility = utility
				best_tile = tile
			end
		end)

		-- return the best tile
		return best_tile, best_utility
end

function AI:planGoLay(tile)
	table.insert(self.plan, { method = self.doGoLay, target = tile })
end

function AI:doGoLay(tile)
	-- can't lay in occupied tiles
	if not self.body:canPlant(tile) then
		-- rage quit >:'(
		return true
	end

	-- go to the tile
	if self:doGoto(tile) then
		self:doLay()
	end

	-- have we laid yet ?
	return (self.body.egg_ready < 1)
end

function AI:doLay()
	self.x, self.y = 0, 0
	if self.confirm.pressed then
		self.confirm.pressed = true
		self.confirm.trigger = 1
	else
		self.confirm.pressed = false
		self.confirm.trigger = -1
	end
end

--[[------------------------------------------------------------
Game loop
--]]--

function AI:update(dt)
	-- any previous plans ?
	if #(self.plan) > 0 then
		local step = self.plan[1]
		local finished = step.method(self, step.target)
		if finished then
			table.remove(self.plan, 1) -- yes, I know, this is slow
			self:doStop()
		end

	-- formulate new plans ?
	else
		-- do we have an egg ready ?
		if self.body.egg_ready >= 1 then
			local tile, utility = self:getBestLayingTile()
			if utility > 0 then
				self:planGoLay(tile)
			end
		end
	end

	
end

function AI:draw()
	-- draw all plans
	local stepx, stepy = self.body.x, self.body.y
	local n_steps = #(self.plan)
	for i, step in ipairs(self.plan) do
		player[self.player].bindTeamColour(255/n_steps*(n_steps - i + 1))
		love.graphics.line(stepx, stepy, step.target.x, step.target.y)
		stepx, stepy = step.target.x, step.target.y
	end
	love.graphics.setColor(255, 255, 255)
end

	

--[[---------------------------------------------------------------------------
Export
--]]--

return AI