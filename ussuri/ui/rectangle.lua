--[[
UI Rectangle
Draws a rectangle
]]

local lib
local rectangle

rectangle = {
	background_color = {50, 50, 50, 255},
	border_color = {120, 120, 120, 255},

	border_width = 2,

	draw = function(self)
		love.graphics.setColor(self.background_color)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

		local border = self.border_width
		local half_border = border / 2

		love.graphics.setColor(self.border_color)
		love.graphics.setLineWidth(border)

		love.graphics.rectangle("line", self.x - half_border, self.y - half_border, self.width + border, self.height + border)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		self:inherit(engine:lib_get(":ui.base"))
	end
}

return rectangle