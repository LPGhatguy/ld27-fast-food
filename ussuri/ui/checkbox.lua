--[[
Checkbox
A simple checkbox
]]

local lib
local rectangle
local checkbox

checkbox = {
	value = false,
	checked_color = {0, 80, 200},
	unchecked_color = {0, 10, 50},

	mousedown_in = function(self, event)
		self.value = not self.value

		self.background_color = self.value and self.checked_color or self.unchecked_color
	end,

	_new = function(base, new, value, x, y, w, h)
		new.value = value

		rectangle._new(base, new, x, y, w or 20, h or w or 20)

		new.background_color = value and new.checked_color or new.unchecked_color

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		rectangle = self:inherit(engine:lib_get(":ui.rectangle"))
	end
}

return checkbox