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

local input = {}
for i = 1, MAX_PLAYERS do
  input[i] = { x = 0, y = 0, confirm = false, confirm_prev = false, confirm_trigger = 0}
end

if USE_GAMEPADS then
	for i = 1, MAX_PLAYERS do
		input[i].keyConfirm = function () return love.joystick.isDown(i, 1) end
		input[i].keyCancel = function () return love.joystick.isDown(i, 2) end
		input[i].keyWest = function () return love.joystick.isDown(i, 3) end
		input[i].keyNorth = function () return love.joystick.isDown(i, 4) end
	end
else
	input[1].keyLeft = function () return love.keyboard.isDown("left") end
	input[1].keyRight = function () return love.keyboard.isDown("right") end
	input[1].KeyUp = function () return love.keyboard.isDown("up") end
	input[1].keyDown = function () return love.keyboard.isDown("down") end
	input[1].keyStart = function () return love.keyboard.isDown("return") end
	input[1].keyConfirm = function () return love.keyboard.isDown("rctrl") end
	input[1].keyCancel = function () return love.keyboard.isDown("escape") end

	input[2].keyLeft = function () return love.keyboard.isDown("a", "q") end
	input[2].keyRight = function () return love.keyboard.isDown("d") end
	input[2].KeyUp = function () return love.keyboard.isDown("w", "z") end
	input[2].keyDown = function () return love.keyboard.isDown("s") end
	input[1].keyStart = function () return love.keyboard.isDown("return") end
	input[2].keyConfirm = function () return love.keyboard.isDown("lctrl") end
	input[2].keyCancel = function () return love.keyboard.isDown("escape") end
end

function input:update(dt)
	for i = 1, MAX_PLAYERS do
		local p = self[i]
		
		if USE_GAMEPADS then
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
		end -- if USE_GAMEPADS
		
		-- confirm
		if p.keyConfirm then
			p.confirm = p.keyConfirm()
			if p.confirm then
				if not p.confirm_prev then
					p.confirm_trigger = 1
				else
					p.confirm_trigger = 0
				end
				p.confirm_prev = true
			else
				if p.confirm_prev then
					p.confirm_trigger = -1
				else
					p.confirm_trigger = 0
				end
				p.confirm_prev = false
			end
		end
		
	end -- for each pconfirmer

end


return input