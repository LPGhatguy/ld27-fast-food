--[[
UI Drag Handle
An object that defines a dragger area
]]

local lib
local rectangle
local draggable

draggable = {
	dragging = false,
	target_sx = 0,
	target_sy = 0,

	mousedown_in = function(self, event)
		self.dragging = true

		self.target_sx = self.target.x - event.abs_x
		self.target_sy = self.target.y - event.abs_y
	end,

	mouseup = function(self, event)
		self.dragging = false
	end,

	tick = function(self, event)
		if (self.dragging) then
			self.target.x = self.target_sx + love.mouse.getX()
			self.target.y = self.target_sy + love.mouse.getY()
		end
	end,

	_new = function(base, new, target, x, y, w, h)
		rectangle._new(base, new, x, y, w, h)

		new.target = target or new

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		rectangle = self:inherit(engine:lib_get(":ui.rectangle"))
	end
}

return draggable