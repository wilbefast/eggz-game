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

--[[------------------------------------------------------------
IMPORTS
--]]------------------------------------------------------------

--[[local Class      = require("hump/class")
local GameObject = require("GameObject")
local Animation = require("Animation")
local AnimationView = require("AnimationView")--]]

--[[------------------------------------------------------------
SPECIAL EFFECT CLASS
--]]------------------------------------------------------------

--[[------------------------------------------------------------
Constructor
--]]

local SpecialEffect = Class
{
  type = GameObject.TYPE.new("SpecialEffect"),
  
  init = function(self, x, y, anim, speed, offx, offy, follow)
      GameObject.init(self, x, y, 0, 0)
    self.view = AnimationView(anim, speed, 1, anim.frame_w/2 + (offx or 0), anim.frame_h/2 + (offy or 0))
    self.follow = follow
  end,
}
SpecialEffect:include(GameObject)

--[[------------------------------------------------------------
Game loop
--]]

function SpecialEffect:update(dt, level, view)

  if self.view:update(dt, level, view) then
    -- destroy at the end of the animation
    self.purge = true
  end
end

function SpecialEffect:draw(view)
  self.view:draw(self)
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return SpecialEffect