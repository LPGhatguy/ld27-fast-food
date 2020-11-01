--[[
Horizontal Fill Bar
Acts as a progress bar or such.
]]

local fillbar
local lib
local rectangle

fillbar = {
	value = 0,
	max = 100,

	draw = function(self, event)
		rectangle.draw(self, event)
		love.graphics.rectangle("fill", self.x, self.y, (self.value / self.max) * self.width, self.height)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		rectangle = self:inherit(engine:lib_get(":ui.rectangle"))
	end
}

return fillbar