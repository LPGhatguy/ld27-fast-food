--[[
Button
Exposes click functionality
]]

local lib
local button

button = {
	mousedown_in = function(self, event)
		self.event_mousedown_in(event)
	end,

	mouseup_in = function(self, event)
		self.event_mouseup_in(event)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(engine:lib_get(":ui.rectangle"))

		self.event_mousedown_in = lib.event.functor:new()
		self.event_mouseup_in = lib.event.functor:new()
	end,
}

return button