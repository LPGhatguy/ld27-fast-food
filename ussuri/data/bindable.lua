--[[
Bindable Object
Abstract class denoting that this object can bind its own values to other objects
Streamlined interface almost identical to data.binding
]]

local lib
local bindable

bindable = {
	bindings = {},

	rebind = function(self)
		for key, value in next, self.bindings do
			local key, target = value[1], value[2]

			if (type(target) == "table") then
				target[1][target[2]] = self[key]
			elseif (type(target) == "function") then
				target(self, key, self[key])
			end
		end
	end,

	bind = function(self, key, target)
		table.insert(self.bindings, {key, target})

		if (type(target) == "table") then
			target[1][target[2]] = self[key]
		else
			target(self, key, self[key])
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return bindable