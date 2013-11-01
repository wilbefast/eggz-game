--[[
"Unrequited", a Löve 2D extension library
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

local input = {}

function input:reset()
	self.n_pads = love.joystick.getNumJoysticks()

	-- rebuild input object
	for i = 1, MAX_PLAYERS do
	  self[i] = 
	  { 
	  	x = 0, 
	  	y = 0, 

	  	confirm = { pressed = false, previous = true, trigger = 0 },
	  	start = { pressed = false, previous = true, trigger = 0 },
	  	cancel = { pressed = false, previous = true, trigger = 0 },

	  	gamepad = (self.n_pads >= i),

	  	keyname = {},

	  	drawButton = function(self, buttonName, x, y)
	  		-- nothing for gamepads (for the moment)
	  		if self.gamepad then return end

	  		-- convert button name
	  		buttonName = self.keyname[buttonName]

	  		-- if it's a letter, draw it
	  		if (string.len(buttonName) == 1) then
	  			-- take layouts into account
	  			if language[current_language].keyboard_layout == "azerty" then
	  				if buttonName == "a" then 
	  					buttonName = "q" 
	  				elseif buttonName == "w" then 
	  					buttonName = "z" 	
	  				end
	  			end
	  			-- just print the letter
	  			love.graphics.setColor(love.graphics.getBackgroundColor())
	  				useful.printf(buttonName, x+2, y+2)
	  			love.graphics.setColor(255, 255, 255)
	  				useful.printf(buttonName, x-2, y-2)

	  		-- up, down, left, right
	  		elseif (buttonName == "up") 
  			or (buttonName == "down") 
  			or (buttonName == "left") 
  			or (buttonName == "right") then
  				local angle = 0
  				if (buttonName == "down") then angle = math.pi end
  				if (buttonName == "left") then angle = math.pi*0.5 end
  				if (buttonName == "right") then angle = -math.pi*0.5 end
  				local im, imw, imh = Plant.ICON_PICKUP, Plant.ICON_PICKUP:getWidth()*0.5, Plant.ICON_PICKUP:getHeight()*0.5
  				love.graphics.setColor(love.graphics.getBackgroundColor())
  					scaled_draw(im, x+2, y-46, angle, 0.4, 0.4, imw, imh)
				love.graphics.setColor(255, 255, 255)
  					scaled_draw(im, x-2, y-50, angle, 0.4, 0.4, imw, imh)

	  		end	
		end
	  }
	end


	-- gamepads 
	for i = 1, self.n_pads do
		local inp = self[i]
		inp.keyConfirm = function () return love.joystick.isDown(i, 1) end
		inp.keyCancel = function () return love.joystick.isDown(i, 2) end
		inp.keyWest = function () return love.joystick.isDown(i, 3) end
		inp.keyNorth = function () return love.joystick.isDown(i, 4) end
		inp.keyStart = function () return love.joystick.isDown(i, 1) end -- FIXME
	end

	-- keyboard 1
	if self.n_pads < MAX_PLAYERS then
		local inp = self[self.n_pads + 1]
		inp.keyname.left = "left"
		inp.keyname.right = "right"
		inp.keyname.up = "up"
		inp.keyname.down = "down" 
		inp.keyname.confirm = "lctrl" 
			inp.keyname.altconfirm = "lshift"
	end

	-- keyboard 2
	if self.n_pads < MAX_PLAYERS - 1 then
		local inp = self[self.n_pads + 2]
		inp.keyname.left = "a" 
			inp.keyname.altleft = "q"
		inp.keyname.right = "d"
		inp.keyname.up = "w"
			inp.keyname.altup = "z"
		inp.keyname.down = "s" 
		inp.keyname.confirm = "lctrl"
			inp.keyname.altconfirm = "lshift"
	end

	-- keyboard 3
	if self.n_pads < MAX_PLAYERS - 2 then
		local inp = self[self.n_pads + 3]
		inp.keyname.left = "f"
		inp.keyname.right = "h"
		inp.keyname.up = "t"
		inp.keyname.down = "g"
		inp.keyname.confirm = "y"
	end

	-- keyboard 4
	if self.n_pads < MAX_PLAYERS - 3 then
		local inp = self[self.n_pads + 4]
		inp.keyname.left = "j"
		inp.keyname.right = "l"
		inp.keyname.up = "i"
		inp.keyname.down = "k"
		inp.keyname.confirm = "o"
	end

	-- keyboards
	for i = self.n_pads + 1, MAX_PLAYERS do
		local inp = self[i]

		function checkKey(key, altkey) 
			return useful.tri(altkey, 
				function() return love.keyboard.isDown(key, altkey) end, 
				function() return love.keyboard.isDown(key) end) 
		end

		inp.keyLeft = checkKey(inp.keyname.left, inp.keyname.altleft)
		inp.keyRight = checkKey(inp.keyname.right)
		inp.KeyUp = checkKey(inp.keyname.up, inp.keyname.altup)
		inp.keyDown = checkKey(inp.keyname.down)
		inp.keyConfirm = checkKey(inp.keyname.confirm, inp.keyname.altconfirm)
		inp.keyStart = checkKey("return")
		inp.keyCancel = checkKey("backspace")
	end
end


local generateTrigger = function(key, key_accessor)
	key.previous = key.pressed
	key.pressed = key_accessor()
	if key.pressed == key.previous then
		key.trigger = 0
	elseif key.pressed then
		key.trigger = 1
	else		
		key.trigger = -1
	end
end

function input:update(dt, bink)

	if not bink then print(a.b) end

	for i = 1, MAX_PLAYERS do
		local p = self[i]
		
		if p.gamepad then
			p.x = love.joystick.getAxis(i, 1)
			if math.abs(p.x) < 0.5 then
				p.x = 0
			end
			p.y = love.joystick.getAxis(i, 2)
			if math.abs(p.y) < 0.5 then
				p.y = 0
			end
		else
			p.x, p.y = 0, 0

			--left
			if p.keyLeft and p.keyLeft() then
				p.x = p.x - 1 
			end
			--right
			if p.keyRight and p.keyRight() then
				p.x = p.x + 1 
			end
			-- up
			if p.KeyUp and p.KeyUp() then
				p.y = p.y - 1 
			end
			-- down
			if p.keyDown and p.keyDown() then 
				p.y = p.y + 1 
			end
		end -- if p.gamepad
		
		-- confirm
		generateTrigger(p.confirm, p.keyConfirm)
		
		-- start
		generateTrigger(p.start, p.keyStart)

		-- cancel
		generateTrigger(p.cancel, p.keyCancel)

	end -- for each p

end


return input