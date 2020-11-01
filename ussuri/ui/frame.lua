--[[
UI Frame
Contains objects inside a rectangle
]]

local lib
local ui_container
local rectangle
local frame

frame = {
	draw = function(self, event)
		rectangle.draw(self, event)
		ui_container.draw(self, event)
	end,

	_new = function(base, new, x, y, w, h)
		ui_container._new(base, new)
		rectangle._new(base, new, x, y, w, h)

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		ui_container = self:inherit(engine:lib_get(":ui.ui_container"))
		rectangle = self:inherit(engine:lib_get(":ui.rectangle"))
	end,
}

frame.event = {
	draw = frame.draw
}

return frame