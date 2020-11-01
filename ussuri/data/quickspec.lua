--[[
QuickSpec/Object Definition Assistant
A prototype library to assist in speedy object declarations
]]

local quickspec
local utility
local lib

quickspec = {
	source = {},

	class = function(base_path, spec)
		local out = {}

		local retrieved = utility.table_nav(self.source, base_path)

		if (retrieved) then
			utility.table_deepcopy(retrieved, out)
		end

		utility.table_deepcopy(spec, out)

		lib.oop:objectify(out)

		return out
	end,

	object = function(base_path, spec)
		local out
		local retrieved = utility.table_nav(self.source, base_path)

		if (retrieved) then
			if (retrieved.new) then
				out = retrieved:new()
			else
				out = {}
			end
		end

		utility.table_deepcopy(spec, out)

		return out
	end,

	init = function(self, engine)
		lib = engine.lib
		utility = lib.utility

		self.source = lib
	end
}

return quickspec