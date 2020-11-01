--[[
Event Handler
Creates and passes events to objects that have registred.
]]

local lib
local table_copy
local event_handler
local event_prop_meta

local handler_compare = function(first, second)
	return first[3] < second[3]
end

event_handler = {
	auto_hook = {},
	event = {},
	events = {},

	event_create = function(self, event_names)
		if (type(event_names) == "table") then
			for key, event_name in pairs(event_names) do
				if (not self.events[event_name]) then
					self.events[event_name] = {data = self.event_data:new()}
					self:event_handler_make(event_name)
				end
			end
		else
			if (not self.events[event_names]) then
				self.events[event_names] = {data = self.event_data:new()}
				self:event_handler_make(event_names)
			end
		end
	end,

	event_handler_make = function(self, event_name)
		if (rawget(self.event, event_name)) then
			return rawget(self.event, event_name)
		else
			local handler = function(this, ...)
				self:event_fire(event_name, ...)
			end

			self.event[event_name] = handler

			return handler
		end
	end,

	event_hook_object = function(self, object, event_names)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				self:event_hook_object(object, event_name)
			end
		elseif (event_names) then
			local event = self.events[event_names]
			local object_events = object.event

			if (event and object_events) then
				local method = object_events[event_names]

				if (method) then
					local priority = object_events[event_names .. "_priority"]

					event[#event + 1] = {object, method, priority or 0}
				end
			end
		else
			local object_events = object.event
			local hooked = {}

			if (object_events) then
				for event_name, method in next, object_events do
					if (type(method) == "function" or type(method) == "table") then
						local event = self.events[event_name]

						if (event) then
							hooked[event_name] = true
							local priority = object_events[event_name .. "_priority"]

							event[#event + 1] = {object, method, priority or 0}
						end
					end
				end
			end

			for event_name, enabled in pairs(self.auto_hook) do
				local event = self.events[event_name]
				local method = object[event_name]

				if (event and method and (not hooked[event_name])) then
					local priority = object[event_name .. "_priority"]

					event[#event + 1] = {object, method, priority or 0}
				end
			end
		end
	end,

	event_hook_light = function(self, object, event_names, method, priority)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				self:event_hook_light(object, event_name, method, priority)
			end
		else
			local event = self.events[event_names]

			if (event) then
				event[#event + 1] = {object or {}, method, priority or 0}
			end
		end
	end,

	event_unhook_by_object = function(self, event_name, object)
		local event = self.events[event_name]

		if (event) then
			for key = 1, #event do
				local entry = event[key]

				if (entry[1] == object) then
					table.remove(event, key)
				end
			end
		end
	end,

	event_unhook_by_method = function(self, event_name, method)
		local event = self.events[event_name]

		if (event) then
			for key = 1, #event do
				local entry = event[key]

				if (entry[2] == method) then
					table.remove(event, key)
				end
			end
		end
	end,

	event_sort = function(self, event_names)
		if (type(event_names) == "table") then
			for key, event_name in pairs(event_names) do
				local event = self.events[event_name]

				if (event) then
					table.sort(event, handler_compare)
				end
			end
		elseif (event_names) then
			local event = self.events[event_names]

			if (event) then
				table.sort(event, handler_compare)
			end
		else
			for event_name, event in next, self.events do
				table.sort(event, handler_compare)
			end
		end
	end,

	event_fire = function(self, event_name, data)
		local event = self.events[event_name]

		if (event) then
			local event_data = event.data
			event_data:update(data)
			event_data:add(self)

			local flags = event_data.flags

			for key = 1, #event do
				local handler = event[key]

				handler[2](handler[1], event_data)

				if (flags.event_unhook) then
					event[key] = nil
					flags.event_unhook = false
				end

				if (flags.event_cancel) then
					break
				end
			end

			return event_data
		else
			print("WARNING: Attempt to call event '" .. tostring(event_name) .. "' (an undefined event)")
		end
	end,

	_new = function(base, new)
		for key, flag in pairs(new.auto_hook) do
			new:event_create(key)
		end

		return new
	end,

	event_data = {
		stack = {},
		flags = {},

		update = function(self, data)
			for key, value in pairs(self) do
				if (type(value) == "table") then
					self[key] = {}
				elseif (type(value) ~= "function") then
					self[key] = nil
				end
			end

			if (data) then
				for key, value in pairs(data) do
					if (type(value) == "table") then
						self[key] = table_copy(value)
					else
						self[key] = value
					end
				end
			end
		end,

		reset = function(self)
			self.stack = {}
			self.flags = {}
		end,

		add = function(self, item)
			self.stack[#self.stack + 1] = item
		end,

		parent = function(self)
			return self.stack[#self.stack]
		end
	},

	init = function(self, engine)
		lib = engine.lib

		table_copy = lib.utility.table_copy

		lib.oop:objectify(self)
		lib.oop:objectify(self.event_data)

		engine.event = self:new()
	end
}

return event_handler