--[[
Text Label
Displays text in a rectangle
]]

local lib
local rectangle
local text_label

text_label = {
	font = nil,
	text_color = {255, 255, 255},

	padding_x = 0,
	padding_y = 0,
	align = "center",

	text = "",
	auto_y = false,
	auto_x = false,

	draw = function(self, event)
		rectangle.draw(self, event)

		if (self.font) then
			love.graphics.setFont(self.font)
		end

		love.graphics.setColor(self.text_color)
		love.graphics.printf(self.text, self.x + self.padding_x, self.y + self.padding_y, self.width, self.align)
	end,

	_new = function(base, new, text, x, y, w, h)
		new.text = text

		rectangle._new(base, new, x, y, w, h)

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		rectangle = self:inherit(engine:lib_get(":ui.rectangle"))
	end
}

return text_label