--[[
Event Functor
A drop-in replacement for functions with multiple bodies
]]

local functor, meta

functor = {
	handlers = {},

	call = function(self, ...)
		if (self.pre) then
			self:pre(...)
		end

		for key, value in next, self.handlers do
			value(...)
		end

		if (self.post) then
			self:post(...)
		end
	end,

	connect = function(self, method)
		table.insert(self.handlers, method)
	end,

	_new = function(base, new, method)
		new:connect(method)

		return new
	end,

	init = function(self, engine)
		engine.lib.oop:objectify(self)
	end
}

setmetatable(functor, {
	__call = functor.call,
	__add = functor.connect
})

return functor