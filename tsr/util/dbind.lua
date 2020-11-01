local dbind
local lib

dbind = {
	width = 0,
	height = 0,

	lock_percent = function(self, item, property, percent, offset, min, max)
		local from = property
		local to = property

		if (type(property) == "table") then
			from = property[1]
			to = property[2]
		end

		return self:bind({self, from}, function()
			item[to] = math.max(math.min(((self[from] or 0) * percent) + (offset or 0), max or math.huge), min or -math.huge)
		end)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.data.binder)
	end
}

return dbind