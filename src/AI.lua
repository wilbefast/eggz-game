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
			utility = utility - tile.defenders[i]*4
		end
	end

	-- best utility ?
	self:updateUtility(self.laying, utility, tile)
end

function AI:recalculateFeedingUtility(plant, distance)
	-- only consider friendly eggz which are not ready to evolve
	if (plant.player ~= self.player) 
		or (not plant:isType("Egg")) 
		or (plant:canEvolve()) then
		return
	end

	-- subtract the distance and tile and egg energy
	local utility = 2 - 4*plant.tile.energy - plant.energy - distance

	-- move eggz on friendly territory less often
	if plant.tile.owner == self.player then
		utility = utility - plant.tile.conversion*0.5
	end

	-- best utility ?
	self:updateUtility(self.feeding, utility, plant)
end

function AI:recalculateEvolvingUtility(plant, distance)

	-- only consider friendly eggz which are not ready to evolve
	if (plant.player ~= self.player) 
		or (not plant:isType("Egg")) 
		or (not plant:canEvolve()) then
		return
	end

	-- subtract distance 
	local utility = 1 - distance

	-- best utility ?
	self:updateUtility(self.evolving, utility, plant)
end

function AI:recalculateConvertorUtility(tile, distance)

	-- subtract distance 
	local utility = 1 - distance

	-- don't pick occupied tiles that can't easily be cleared
	if tile.occupant and (not self.body:canUproot(tile)) then
		return
	end

	-- conversion areas should not overlap, should not lie on turrets and rocks
	for _, t in ipairs(game.grid:getNeighbours4(tile), true) do
		-- two convertors working on the same territory is pointless
		if t.owner == self.player then
			utility = utility - t.conversion*2
		end

		-- a convertor next to a rock or turret is pointless
		if t.occupant then
			if t.occupant:isType("Turret") then
				utility = utility - 0.75
			elseif t.occupant:isType("Rock") then
				utility = utility - 0.5
			end
		end
	end

	-- subtract utility for each defender
	for i = 1, n_players do
		if i ~= self.player then
			utility = utility - tile.defenders[i]*4
		end
	end

	-- best utility ?
	self:updateUtility(self.convertor, utility, tile)
end

function AI:recalculateUtility()

		-- reset utility
		self.laying = { utility = -math.huge, target = nil }
		self.feeding = { utility = -math.huge, target = nil }
		self.evolving = { utility = -math.huge, target = nil }
		self.convertor = { utility = -math.huge, target = nil }

		game.grid:map(function(tile, x, y)

			-- generally prefer closer tiles
			local distance =
				Vector.len(self.body.x - tile.x, self.body.y - tile.y) / MAP_SIZE

			-- how good is this tile for laying ?
			self:recalculateLayingUtility(tile, distance)

			-- how good is this tile for building a convertor on ?
			self:recalculateConvertorUtility(tile, distance)

			-- anybody home ?
			if tile.occupant then

				-- does this egg need to be fed ?
				self:recalculateFeedingUtility(tile.occupant, distance)

				-- can this egg be evolved ?
				self:recalculateEvolvingUtility(tile.occupant, distance)

			end

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
end


--[[------------------------------------------------------------
Picking up and putting down
--]]--

function AI:planGoPickup(plant)
	table.insert(self.plan, { method = self.doGoPickup, target = plant })
end

function AI:doGoPickup(plant)
	-- if the plant still there ?
	if plant.purge or ((plant.transport and plant.transport ~= self.body)) then
		-- rage quit >:'(
		return true
	end

	-- go to the tile
	if self:doGoto(plant.tile) and self.body:canUproot() then
		-- grab the plant
		self.body:doUproot()
		return true
	else
		return false
	end
end

function AI:planGoPlant(tile)
	table.insert(self.plan, { method = self.doGoPlant, target = tile })
end

function AI:doGoPlant(tile)
	-- can't lay in occupied tiles
	if not self.body:canPlant(tile) then
		-- rage quit >:'(
		return true
	end

	-- go to the tile
	if self:doGoto(tile) then
		self.body:doPlant()
		return true
	else
		return false
	end
end

--[[------------------------------------------------------------
Building advanced structures : convertors, turrets and bombs
--]]--

function AI:planMakeConvertor(tile)
	table.insert(self.plan, { method = self.doMakeConvertor, target = tile })
end

function AI:doMakeConvertor(tile)
	-- go to target location and plant the carried egg
	local arrived = false
	if self.body:canPlant(tile) then
		-- plant the carried egg if the tile is free
		arrived = self:doGoPlant(tile)
	elseif self.body:canUproot(tile) then
		-- swap the carried egg for the tile contents if not
		arrived = self:doGoPickup(tile.occupant)
	else
		return true
	end
	-- evolve the placed egg
	if arrived then
		if self.body:canEvolve() then
			self.body:doEvolve(Convertor)
		end
		return true
	else
		return false
	end
end

--[[------------------------------------------------------------
Game loop
--]]--

function AI:update(dt)

	-- AI never skips grabs
	self.body.skip_next_grab = false

	-- any previous plans ?
	if #(self.plan) > 0 then
		-- what is the next step in the plan ?
		local step = self.plan[1]
		-- is this step finished ?
		local finished = step.method(self, step.target)
		if finished then
			-- pop the now finished step
			table.remove(self.plan, 1) -- yes, I know, this is slow
			self:doStop()
		end

	-- formulate new plans ?
	else

		-- recalculate utility map to base choices on
		self:recalculateUtility()

		-- are we carrying an egg ?
		if (self.body.passenger) then 
			-- is the egg mature ?
			local egg = self.body.passenger
			if egg:canEvolve() then
				-- make a convertor ?
				if self.convertor.utility > 0 then
					self:planMakeConvertor(self.convertor.target)
				end
			
			-- replant immature egg if possible
			elseif (self.laying.utility > 0) then
				self:planGoPlant(self.laying.target)
			end

		-- do we have an egg ready to lay ?
		elseif (self.body.egg_ready >= 1) and (self.laying.utility > 0) then
			self:planGoPlant(self.laying.target)

		-- are any on-map eggz ready to evolve ?
		elseif self.evolving.utility > 0 then
			self:planGoPickup(self.evolving.target)
		
		-- are any of our eggz hungry ?
		elseif self.feeding.utility > 0 and (self.feeding.target ~= self.laying.target) then
			self:planGoPickup(self.feeding.target)
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