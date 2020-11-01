--[[
Text Button
Patched in for LD27
]]

local text_button
local lib

text_button = {
	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(engine:lib_get(":ui.text_label"))
		self:inherit(engine:lib_get(":ui.button"))
	end
}

return text_button