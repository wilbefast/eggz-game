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


local n_pads = love.joystick.getNumJoysticks()

local input = {}
for i = 1, MAX_PLAYERS do
  input[i] = 
  { 
  	x = 0, 
  	y = 0, 

  	confirm = { pressed = false, previous = false, trigger = 0 },
  	start = { pressed = false, previous = false, trigger = 0 },
  	cancel = { pressed = false, previous = false, trigger = 0 },

  	gamepad = (n_pads >= i)
  }
end

for i = 1, n_pads do
	input[i].keyConfirm = function () return love.joystick.isDown(i, 1) end
	input[i].keyCancel = function () return love.joystick.isDown(i, 2) end
	input[i].keyWest = function () return love.joystick.isDown(i, 3) end
	input[i].keyNorth = function () return love.joystick.isDown(i, 4) end
	input[i].keyStart = function () return love.joystick.isDown(i, 1) end -- FIXME
end

if n_pads < MAX_PLAYERS then
	input[n_pads + 1].keyLeft = function () return love.keyboard.isDown("left") end
	input[n_pads + 1].keyRight = function () return love.keyboard.isDown("right") end
	input[n_pads + 1].KeyUp = function () return love.keyboard.isDown("up") end
	input[n_pads + 1].keyDown = function () return love.keyboard.isDown("down") end
	input[n_pads + 1].keyStart = function () return love.keyboard.isDown("return") end
	input[n_pads + 1].keyConfirm = function () return love.keyboard.isDown("rctrl") end
	input[n_pads + 1].keyCancel = function () return love.keyboard.isDown("backspace") end

	if n_pads < MAX_PLAYERS - 1 then
		input[n_pads + 2].keyLeft = function () return love.keyboard.isDown("a", "q") end
		input[n_pads + 2].keyRight = function () return love.keyboard.isDown("d") end
		input[n_pads + 2].KeyUp = function () return love.keyboard.isDown("w", "z") end
		input[n_pads + 2].keyDown = function () return love.keyboard.isDown("s") end
		input[n_pads + 2].keyStart = function () return love.keyboard.isDown("return") end
		input[n_pads + 2].keyConfirm = function () return love.keyboard.isDown("lctrl") end
		input[n_pads + 2].keyCancel = function () return love.keyboard.isDown("backspace") end
	end

	if n_pads < MAX_PLAYERS - 2 then
		input[n_pads + 3].keyLeft = function () return love.keyboard.isDown("f") end
		input[n_pads + 3].keyRight = function () return love.keyboard.isDown("h") end
		input[n_pads + 3].KeyUp = function () return love.keyboard.isDown("t") end
		input[n_pads + 3].keyDown = function () return love.keyboard.isDown("g") end
		input[n_pads + 3].keyStart = function () return love.keyboard.isDown("return") end
		input[n_pads + 3].keyConfirm = function () return love.keyboard.isDown("y") end
		input[n_pads + 3].keyCancel = function () return love.keyboard.isDown("backspace") end
	end

	if n_pads < MAX_PLAYERS - 3 then
		input[n_pads + 4].keyLeft = function () return love.keyboard.isDown("j") end
		input[n_pads + 4].keyRight = function () return love.keyboard.isDown("l") end
		input[n_pads + 4].KeyUp = function () return love.keyboard.isDown("i") end
		input[n_pads + 4].keyDown = function () return love.keyboard.isDown("k") end
		input[n_pads + 4].keyStart = function () return love.keyboard.isDown("return") end
		input[n_pads + 4].keyConfirm = function () return love.keyboard.isDown("o") end
		input[n_pads + 4].keyCancel = function () return love.keyboard.isDown("backspace") end
	end

end


function generateTrigger(key, key_accessor)
	key.pressed = key_accessor()
	if key.pressed == key.previous then
		key.trigger = 0
	elseif key.pressed then
		key.trigger = 1
	else		
		key.trigger = 0
	end
end

function input:update(dt)
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