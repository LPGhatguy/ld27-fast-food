--[[
Data Binding Service
Binds data entries in objects to other data entries
]]

local lib
local binder

binder = {
	bindings = {},

	rebind = function(self)
		for key, value in next, self.bindings do
			local source, target = value[1], value[2]

			if (type(target) == "table") then
				target[1][target[2]] = source[1][source[2]]
			elseif (type(target) == "function") then
				target(source[2], source[1][source[2]])
			end
		end
	end,

	bind = function(self, source, target)
		table.insert(self.bindings, {source, target})

		if (type(target) == "table") then
			target[1][target[2]] = source[1][source[2]]
		end

		return source[1][source[2]]
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return binder