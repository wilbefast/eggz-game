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

local tutorial = { }

tutorial.get = function(p)
	return tutorial[player[p].tutorial]
end

tutorial.getMessage = function(p)
	return language[current_language].tutorial[tutorial.get(p).key]
end

tutorial.next = function(p)
	player[p].tutorial = player[p].tutorial + 1
end

-- lay an egg
tutorial[1] = 
{
	key = "lay",
	isPassed = 
		function(overlord)
			return (overlord.egg_ready == 0)
		end
}

-- pick up an egg
tutorial[2] = 
{
	key = "pick",
	isPassed = 
		function(overlord)
			return false
		end
}


return tutorial