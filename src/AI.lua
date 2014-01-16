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
	-- ignore tiles that can't be planted in for whatever reason
	if (not self.body:canPlant(tile)) then
		return
	end

	-- add the tile energy
	local utility = tile.energy*2

	-- subtract the tile distance
	utility = utility - distance

	for i = 1, n_players do
		if i ~= self.player then
			-- subtract utility for each defender
			utility = utility - tile.defenders[i]*4

			-- penalty if the tile is not our colour
			utility = utility - tile.convertors[i]
		else
			-- bonus if the tile is our colour
			utility = utility + tile.convertors[i]*0.5
		end
	end

	-- best utility ?
	self:updateUtility(self.laying, utility, tile)
end

function AI:recalculateFeedingUtility(plant, distance)
	-- stop juggling eggz doofus
	if plant.tile == self.body.tile then
		return
	end

	-- only consider friendly eggz which are not ready to evolve
	if (plant.player ~= self.player) 
		or (not plant:isType("Egg")) 
		or (plant:canEvolve()) then
		return
	end

	-- subtract the distance and tile and egg energy
	local utility = 2 - 4*plant.tile.energy - plant.energy - 0.3*distance

	-- move eggz which are already on friendly territory less often
	if plant.tile.owner == self.player then
		utility = utility - plant.tile.convertors[self.player]*0.6
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

function AI:recalculateDerockingUtility(rock, distance)
	local tile = rock.tile

	-- stop juggling rocks doofus
	if tile == self.body.tile then
		return
	end

	-- only consider rocks
	if not rock:isType("Rock") then
		return
	end

	-- prefer close rocks with a lot of energy under them
	local utility = 0.5*tile.energy - distance - 1

	for i = 1, n_players do
		if i == self.player then
			utility = utility + tile.convertors[i]*8
			utility = utility + tile.defenders[i]*3
			utility = utility - tile.vulnerabilities[i]*5
		else
			utility = utility - tile.convertors[i]*4
			utility = utility - tile.defenders[i]*2
			utility = utility + tile.vulnerabilities[i]*0.5
		end
	end

	-- move eggz which are already on friendly territory less often
	if tile.owner == self.player then
		utility = utility - tile.convertors[self.player]*0.6
	end

	-- best utility ?
	self:updateUtility(self.derocking, utility, rock)
end

function AI:recalculateConvertorUtility(tile, distance)

	-- subtract distance 
	local utility = 1 - distance

	-- ignore tiles that can't be planted in or cleared
	if (not self.body:canPlant(tile)) and (not self.body:canUproot(tile)) then
		return
	end

	-- conversion areas should not overlap, should not lie on turrets and rocks
	for _, t in ipairs(game.grid:getNeighbours4(tile), true) do
		-- two convertors working on the same territory is pointless

		for i = 1, n_players do
			if i == self.player then
				-- penalty if the tile is our colour
				utility = utility - 10*tile.convertors[i]
			else
				-- penalty if the tile is not our colour
				utility = utility - 2*tile.convertors[i]
			end
		end

		if (t ~= tile) and (t.convertors[self.player] == 0) then
			utility = utility + 4*t.vulnerabilities[self.player]
		end

		-- a convertor next to a rock or turret is pointless
		if t.occupant then
			if t.occupant:isType("Turret") then
				utility = utility - 2
			elseif t.occupant:isType("Rock") then
				utility = utility - 1
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

function AI:recalculateTurretUtility(tile, distance)

	-- subtract distance 
	local utility = 1 - distance

	-- ignore tiles that can't be planted in or cleared
	if (not self.body:canPlant(tile)) and (not self.body:canUproot(tile)) then
		return
	end

	-- turrets should be placed in vulnerable areas
	for i = 1, n_players do
		if i == self.player then
			utility = utility - tile.defenders[i]
			utility = utility + 2*tile.vulnerabilities[i]
		else
			utility = utility - tile.defenders[i]
			utility = utility + 5*tile.vulnerabilities[i]
		end
	end

	-- best utility ?
	self:updateUtility(self.turret, utility, tile)
end

function AI:recalculateRockUtility(tile, distance)
	-- ignore tiles that can't be planted in for whatever reason
	if (not self.body:canPlant(tile)) then
		return
	end

	-- subtract distance 
	local utility = 7 - 4*distance - tile.energy

	-- don't place in own territory
	utility = utility - 4*tile.convertors[self.player]

	-- protect own vulnerabilities, not enemy ones
	for i = 1, n_players do
		if i == self.player then
			utility = utility + tile.vulnerabilities[i]
		else
			utility = utility - tile.vulnerabilities[i]
		end
	end

	-- best utility ?
	self:updateUtility(self.rock, utility, tile)
end

function AI:recalculateUtility()

		-- reset utility
		self.laying = { utility = -math.huge, target = nil }
		self.feeding = { utility = -math.huge, target = nil }
		self.evolving = { utility = -math.huge, target = nil }
		self.derocking = { utility = -math.huge, target = nil }

		self.convertor = { utility = -math.huge, target = nil }
		self.turret = { utility = -math.huge, target = nil }
		self.rock = { utility = -math.huge, target = nil }

		game.grid:map(function(tile, x, y)

			-- generally prefer closer tiles
			local distance =
				Vector.len(self.body.x - tile.x, self.body.y - tile.y) / MAP_SIZE

			-- how good is this tile for laying ?
			self:recalculateLayingUtility(tile, distance)

			-- how good is this tile for building a convertor on ?
			self:recalculateConvertorUtility(tile, distance)

			-- how good is this tile building a turret on ?
			self:recalculateTurretUtility(tile, distance)

			-- how good is this tile for dropping a rock on ?
			self:recalculateRockUtility(tile, distance)

			-- anybody home ?
			if tile.occupant then

				-- does this plant need to be fed ?
				self:recalculateFeedingUtility(tile.occupant, distance)

				-- can this plant be evolved ?
				self:recalculateEvolvingUtility(tile.occupant, distance)

				-- is this plant a rock that should be moved ?
				self:recalculateDerockingUtility(tile.occupant, distance)

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

function AI:doMake(tile, evolution)
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
			self.body:doEvolve(evolution)
		end
		return true
	else
		return false
	end
end

function AI:planMakeConvertor(tile)
	table.insert(self.plan, { method = self.doMakeConvertor, target = tile })
end
function AI:doMakeConvertor(tile)
	return self:doMake(tile, Convertor)
end

function AI:planMakeTurret(tile)
	table.insert(self.plan, { method = self.doMakeTurret, target = tile })
end
function AI:doMakeTurret(tile)
	return self:doMake(tile, Turret)
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

		-- are we carrying a plant ?
		if (self.body.passenger) then 
			local plant = self.body.passenger
			-- are we carrying an egg ?
			if plant:isType("Egg") then
				-- is the egg mature ?
				local plant = self.body.passenger
				if plant:canEvolve() then
					-- make a convertor ?
					if (self.convertor.utility > 0) 
					and (self.convertor.utility > self.turret.utility) then
						self:planMakeConvertor(self.convertor.target)
					elseif (self.turret.utility > 0) then
						self:planMakeTurret(self.turret.target)
					end
				-- replant immature egg if possible
				elseif (self.laying.utility > 0) then
					self:planGoPlant(self.laying.target)
				end
			elseif plant:isType("Rock") then
				if (self.rock.utility > 0) then
					self:planGoPlant(self.rock.target)
				end
			end

		-- do we have an egg ready to lay ?
		elseif (self.body.egg_ready >= 1) and (self.laying.utility > 0) then
			self:planGoPlant(self.laying.target)

		-- are there any rocks which need to be moved ?
		elseif self.derocking.utility > 0 then
			self:planGoPickup(self.derocking.target)

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