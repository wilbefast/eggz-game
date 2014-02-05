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

  	-- options
  	self.options = 
  	{
  		{
  			-- place carried or 'head' egg in the richest, safest location
  			name = "laying",
  			precond = function() 
  				return ((self.body.egg_ready >= 1)
  					or ((self.body.passenger ~= nil)
  						and (self.body.passenger.player == self.player)
  						and (not self.body.passenger:canEvolve()))) end,
  			execute = AI.planGoPlant,
  			recalculateUtility = AI.recalculateLayingUtility
  		},
  		{
  			name = "feeding",
  			precond = function() 
  				return (self.options.feeding.target ~= self.options.laying.target) end,
				execute = AI.planGoPickup,
				recalculateUtility = AI.recalculateFeedingUtility
  		},
  		{
  			name = "evolving",
  			execute = AI.planGoPickup,
  			recalculateUtility = AI.recalculateEvolvingUtility
  		},
  		{
  			name = "derocking",
  			execute = AI.planGoPickup,
  			recalculateUtility = AI.recalculateDerockingUtility
  		},
  		{
  			name = "convertor",
				precond = function() 
		  				return ((self.body.passenger ~= nil)
		  						and (self.body.passenger.player == self.player)
		  						and (self.body.passenger:canEvolve())) end,
  			execute = AI.planMakeConvertor,
  			recalculateUtility = AI.recalculateConvertorUtility
  		},
  		{
  			name = "turret",
				precond = function() 
  				return ((self.body.passenger ~= nil)
  						and (self.body.passenger.player == self.player)
  						and (self.body.passenger:canEvolve())) end,
  			execute = AI.planMakeTurret,
  			recalculateUtility = AI.recalculateTurretUtility
  		},
  		{
  			name = "rock",
  			precond = function() 
  				return ((self.body.passenger ~= nil) and self.body.passenger:isType("Rock")) end,
  			execute = AI.planGoPlant,
  			recalculateUtility = AI.recalculateRockUtility
  		}
  	}

  	-- we need to remember the order for debugging
  	self.option_names = {}

  	for i, option in ipairs(self.options) do
  		option.utility = -math.huge
  		self.options[option.name] = option
  		self.option_names[i] = option.name
  	end
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
	self:updateUtility(self.options.laying, utility, tile)
end

function AI:recalculateFeedingUtility(tile, distance)

	-- only interested in the contents of the tile
	if not tile.occupant then return end
	local plant = tile.occupant

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
	self:updateUtility(self.options.feeding, utility, plant)
end

function AI:recalculateEvolvingUtility(tile, distance)
	-- only interested in the contents of the tile
	if not tile.occupant then return end
	local plant = tile.occupant

	-- only consider friendly eggz which are not ready to evolve
	if (plant.player ~= self.player) 
		or (not plant:isType("Egg")) 
		or (not plant:canEvolve()) then
		return
	end

	-- subtract distance 
	local utility = 1 - distance

	-- best utility ?
	self:updateUtility(self.options.evolving, utility, plant)
end

function AI:recalculateDerockingUtility(tile, distance)
	-- only interested in the contents of the tile
	if not tile.occupant then return end
	local plant = tile.occupant

	-- stop juggling rocks doofus
	if tile == self.body.tile then
		return
	end

	-- only consider rocks
	if not plant:isType("Rock") then
		return
	end

	-- prefer close rocks with a lot of energy under them
	local utility = 0.5*tile.energy - distance - 1

	for i = 1, n_players do
		if i == self.player then
			utility = utility + tile.convertors[i]*6
												+ tile.defenders[i]*0.5
												- tile.vulnerabilities[i]*5
		else
			utility = utility - tile.convertors[i]*4
												- tile.defenders[i]*2
												+ tile.vulnerabilities[i]*0.5
		end
	end

	-- move eggz which are already on friendly territory less often
	if tile.owner == self.player then
		utility = utility - tile.convertors[self.player]*0.6
	end

	-- best utility ?
	self:updateUtility(self.options.derocking, utility, plant)
end

function AI:recalculateConvertorUtility(tile, distance)

	-- subtract distance 
	local utility = 2 - 0.5*distance - 4*self.conversion

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

		-- bonus if a convertor here would 'cover' another convertor's weak points
		if (t ~= tile) and (t.convertors[self.player] == 0) then
			utility = utility + 4*t.vulnerabilities[self.player]
		end

		-- a convertor next to a rock or turret is pointless
		if t.occupant then
			if t.occupant:isPlantType("Turret") then
				utility = utility - 3
			elseif t.occupant:isType("Rock") then
				utility = utility - 1
			end
		end
	end

	-- conversion areas should not overlap, should not lie on turrets and rocks
	for _, t in ipairs(game.grid:getNeighboursX(tile)) do
		-- a convertor with a corner to a rock or turret is well defended
		if t.occupant then
			if t.occupant:isPlantType("Turret") and (t.occupant.player == self.player) then
				utility = utility + 1
			elseif t.occupant:isType("Rock") then
				utility = utility + 0.5
			end
		end
	end

	-- subtract utility for each enemy defender
	for i = 1, n_players do
		if i ~= self.player then
			utility = utility - tile.defenders[i]*16
		end
	end

	-- best utility ?
	self:updateUtility(self.options.convertor, utility, tile)
end

function AI:recalculateTurretUtility(tile, distance)

	-- subtract distance 
	local utility = 2*self.conversion - 0.5*distance - 1

	-- ignore tiles that can't be planted in or cleared
	if (not self.body:canPlant(tile)) and (not self.body:canUproot(tile)) then
		return
	end

	-- turrets should be placed in vulnerable areas
	for i = 1, n_players do
		if i == self.player then
			-- friend
			utility = utility + 2*tile.vulnerabilities[i]
		else
			-- foe
			utility = utility 
								+ 2*tile.vulnerabilities[i]*player[i].total_conversion 
								- tile.defenders[i] 
		end
	end

	-- turrets should cover as little friendly territory as possible
	for i, t in ipairs(game.grid:getNeighbours8(tile, true)) do
		for i = 1, n_players do
			if i == self.player then
				-- friend
				utility = utility - tile.defenders[i] - 0.5*tile.convertors[i]
			end
		end
	end

	-- best utility ?
	self:updateUtility(self.options.turret, utility, tile)
end

function AI:recalculateRockUtility(tile, distance)
	-- ignore tiles that can't be planted in for whatever reason
	if (not self.body:canPlant(tile)) then
		return
	end

	-- subtract distance 
	local utility = 8 - 5*distance - tile.energy

	-- don't place in own territory
	utility = utility - 6*tile.convertors[self.player]
	utility = utility - 2*tile.defenders[self.player]

	-- protect own vulnerabilities, not enemy ones
	for i = 1, n_players do
		if i == self.player then
			utility = utility + 2*tile.vulnerabilities[i]
		else
			utility = utility - tile.vulnerabilities[i]
			utility = utility + 0.5*tile.defenders[i]
		end
	end

	-- best utility ?
	self:updateUtility(self.options.rock, utility, tile)
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

	-- normalised conversion amount
	if game.total_conversion == 0 then
		self.conversion = 0
	else 
		self.conversion = player[self.player].total_conversion / game.total_conversion
	end

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
		for _, option in ipairs(self.options) do
			option.utility = -math.huge
			option.target = nil
		end
		game.grid:map(function(tile, x, y)
			-- generally options will 'prefer' closer tiles
			local distance =
				Vector.len(self.body.x - tile.x, self.body.y - tile.y) / MAP_SIZE
			-- otherwise each option 'prefers' different tiles
			for _, option in ipairs(self.options) do
				option.recalculateUtility(self, tile, distance)
			end
		end)

		-- sort options by their utility
		table.sort(self.options, function(a, b) 
			return (a.utility > b.utility) end)

		-- pick out the best option that is possible
		for i, best_option in ipairs(self.options) do
			if (not best_option.precond) or best_option.precond() then
				best_option.execute(self, best_option.target)
				log:write("executing routine '" .. best_option.name .. "'")
				break
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

	-- draw utilities
	local x, y = 280, 32 --self.body.x, self.body.y
	love.graphics.print("ROUTINE", x, y)
	love.graphics.print("UTILITY", x + 128, y)
	love.graphics.print("PREDICATE", x + 256, y)
	for i, name in ipairs(self.option_names) do
		y = y + 16
		local option = self.options[name]
		love.graphics.print(option.name, x, y)
		local utility = tostring(math.floor(option.utility*100))
		love.graphics.print(utility, x + 128, y)
		if option.precond then
			love.graphics.print(tostring(option.precond()), x + 256, y)
		end
	end
end

	

--[[---------------------------------------------------------------------------
Export
--]]--

return AI