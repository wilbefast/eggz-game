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
	end
}

--[[------------------------------------------------------------
Utility
--]]--

function AI:planRecalculateUtility()
	table.insert(self.plan, { method = self.doRecalculateUtility, target = self })
end

function AI:doRecalculateUtility()
	self:recalculateUtility()
	return true
end

function AI:updateUtility(best, new_utility, new_target)
	if new_utility > best.utility then
		best.utility = new_utility
		best.target = new_target
	end
end

function AI:recalculateLayingUtility(tile, distance)
	-- ignore occupied tiles
	if tile.occupant then
		return
	end

	-- add the tile energy
	local utility = tile.energy

	-- subtract the tile distance
	utility = utility - distance

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

	-- best utility ?
	self:updateUtility(self.laying, utility, tile)
end

function AI:recalculateFeedingUtility(tile, distance)
	-- only consider friendly eggz which are not completely evolved
	if (not tile.occupant) 
		or (tile.occupant.player ~= self.player) 
		or (not tile.occupant:isType("Egg")) 
		or (tile.occupant:canEvolve()) then
		return
	end

	-- subtract the tile and egg energy
	local utility = 2 - 4*tile.energy - tile.occupant.energy

	-- best utility ?
	self:updateUtility(self.feeding, utility, tile.occupant)
end

function AI:recalculateUtility()

		-- reset utility
		self.laying = { utility = -math.huge, target = nil }
		self.feeding = { utility = -math.huge, target = nil }

		game.grid:map(function(tile, x, y)

			-- generally prefer closer tiles
			local distance =
				Vector.len(self.body.x - tile.x, self.body.y - tile.y) / MAP_SIZE

			-- how good is this tile for laying ?
			self:recalculateLayingUtility(tile, distance)

			-- how good is this tile for feeding ?
			self:recalculateFeedingUtility(tile, distance)
			
		end)

		-- return the best tile
		return best_tile, best_utility
end

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
Laying
--]]--

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
Feeding, ie. picking up and dropping off
--]]--

function AI:planGoPickup(egg)
	table.insert(self.plan, { method = self.doGoPickup, target = egg })
end

function AI:doGoPickup(egg)
	-- if the egg still there ?
	if egg.purge or ((egg.transport and egg.transport ~= self.body)) then
		-- rage quit >:'(
		return true
	end

	-- go to the tile
	if (not self.body.passenger) and self:doGoto(egg.tile) then
		self:doLay()
	end

	-- have we picked-up yet ?
	return (self.body.passenger ~= nil)
end

function AI:planGoDropoff(tile)
	table.insert(self.plan, { method = self.doGoDropoff, target = tile })
end

function AI:doGoDropoff(tile)
	-- can't lay in occupied tiles
	if not self.body:canPlant(tile) then
		-- rage quit >:'(
		return true
	end

	-- go to the tile
	if self:doGoto(tile) then
		self:doLay()
	end

	-- have we dropped-off yet ?
	return (self.body.passenger == nil)
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

		-- recalculate utility map to base choices on
		self:recalculateUtility()

		-- do we have an egg ready ?
		if (self.body.egg_ready >= 1) and (self.laying.utility > 0) then
			self:planGoLay(self.laying.target)
		
		-- are any of our eggz hungry ?
		elseif self.feeding.utility > 0 then
			self:planGoPickup(self.feeding.target)
			self:planGoDropoff(self.laying.target)
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