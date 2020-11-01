--[[
Image
Draws an image. Just an image.
]]

local lib
local ui_base
local image

image = {
	image_color = {255, 255, 255},

	source = love.graphics.newImage(love.image.newImageData(2, 2)),

	draw = function(self)
		love.graphics.setColor(self.image_color)
		love.graphics.draw(self.source, self.x, self.y, 0,
			self.width / self.source:getWidth(), self.height / self.source:getHeight())
	end,

	_new = function(base, new, source, x, y, w, h)
		ui_base._new(base, new, x, y, w, h)
		new.source = source or base.source

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		ui_base = self:inherit(engine:lib_get(":ui.base"))
	end
}

return image