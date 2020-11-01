--[[
UI Base
The root of UI items
]]

local lib
local base

base = {
	x = 0,
	y = 0,
	width = 0,
	height = 0,
	visible = true,

	_new = function(base, new, x, y, w, h)
		new.x = x or 0
		new.y = y or 0
		new.width = w or 0
		new.height = h or 0

		return new
	end,

	draw = function(self)
		--abstract method
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return base