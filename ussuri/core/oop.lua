--[[
Object Orientation
Enables instantation and inheritance of objects
]]

local lib, table_deepcopy, table_deepmerge
local oop

oop = {
	objectify = function(self, to)
		table_deepmerge(self.object, to)
	end,

	object = {
		inherit = function(self, from)
			if (from) then
				table_deepmerge(from, self, true, true)

				return from
			else
				print("Cannot inherit from nil!")
			end
		end,

		new = function(self, ...)
			if (self._new) then
				return self:_new(self:copy(), ...)
			else
				return self:copy()
			end
		end,

		copy = function(self)
			return table_deepcopy(self, {}, true)
		end
	},

	init = function(self, engine)
		lib = engine.lib
		table_deepcopy = lib.utility.table_deepcopy
		table_deepmerge = lib.utility.table_deepmerge

		self:objectify(engine)
	end
}

return oop