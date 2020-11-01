--[[
UI Container
Holds UI objects and passes calls to them
]]

local lib
local container
local ui_base
local ui_container

ui_container = {
	clip_children = false,

	auto_hook = {
		["draw"] = true, ["tick"] = true,
		["mousedown"] = true, ["mousedown_in"] = true, ["mousedown_out"] = true,
		["mouseup"] = true, ["mouseup_in"] = true, ["mouseup_out"] = true
	},

	draw = function(self, event)
		local handlers = self.events["draw"]
		local event_data = handlers.data
		event_data:update(event)
		event_data:add(self)

		local flags = event_data.flags
		local ox = event.ox + self.x
		local oy = event.oy + self.y

		event_data.ox = ox
		event_data.oy = oy

		love.graphics.push()
		love.graphics.translate(ox, oy)

		if (self.clip_children) then
			love.graphics.setScissor(ox, oy, self.width, self.height)
		end

		for key = 1, #handlers do
			local handler = handlers[key]

			handler[2](handler[1], event_data)

			if (flags.event_unhook) then
				handlers[key] = nil
				flags.event_unhook = false
			end

			if (flags.event_cancel) then
				break
			end
		end

		love.graphics.setScissor()
		love.graphics.pop()

		return event_data
	end,

	positional_event = function(self, event_name, event)
		self:event_fire(event_name, event)

		local ox = (event.ox or 0) + self.x
		local oy = (event.oy or 0) + self.y

		local x = event.abs_x - ox
		local y = event.abs_y - oy


		local handlers = self.events[event_name .. "_out"]
		local event_data = handlers.data
		event_data:update(event)
		event_data:add(self)
		event_data.x, event_data.y = x, y
		event_data.ox, event_data.oy = ox, oy

		local flags = event_data.flags

		for key = 1, #handlers do
			local handler = handlers[key]
			local object = handler[1]

			if (x < object.x or y < object.y or
			 x > (object.x + object.width) or y > (object.y + object.height)) then
				handler[2](handler[1], event_data)
			end

			if (flags.event_unhook) then
				handlers[key] = nil
				flags.event_unhook = false
			end

			if (flags.event_cancel) then
				break
			end
		end

		if (not self.clip_children) then
			local handlers = self.events[event_name .. "_in"]
			local event_data = handlers.data
			event_data:update(event)
			event_data:add(self)
			event_data.x, event_data.y = x, y
			event_data.ox, event_data.oy = ox, oy

			local flags = event_data.flags

			for key = 1, #handlers do
				local handler = handlers[key]
				local object = handler[1]

				if (x > object.x and y > object.y and
				 x < (object.x + object.width) and y < (object.y + object.height)) then
					handler[2](handler[1], event_data)
				end

				if (flags.event_unhook) then
					handlers[key] = nil
					flags.event_unhook = false
				end

				if (flags.event_cancel) then
					break
				end
			end
		end
	end,

	positional_event_in = function(self, event_name, event)
		if (self.clip_children) then
			local handlers = self.events[event_name .. "_in"]
			local event_data = handlers.data
			event_data:update(event)
			event_data:add(self)

			local ox = event.ox + self.x
			local oy = event.oy + self.y

			local x = event.abs_x - ox
			local y = event.abs_y - oy

			event_data.x, event_data.y = x, y
			event_data.ox, event_data.oy = ox, oy

			local flags = event_data.flags

			for key = 1, #handlers do
				local handler = handlers[key]
				local object = handler[1]

				if (x > object.x and y > object.y and
				 x < (object.x + object.width) and y < (object.y + object.height)) then

					handler[2](handler[1], event_data)
				end

				if (flags.event_unhook) then
					handlers[key] = nil
					flags.event_unhook = false
				end

				if (flags.event_cancel) then
					break
				end
			end

			return event_data
		end
	end,

	mousedown = function(self, event)
		self:positional_event("mousedown", event)
	end,

	mousedown_in = function(self, event)
		self:positional_event_in("mousedown", event)
	end,

	mouseup = function(self, event)
		self:positional_event("mouseup", event)
	end,

	mouseup_in = function(self, event)
		self:positional_event_in("mouseup", event)
	end,

	_new = function(base, new, x, y, w, h)
		container._new(base, new)
		ui_base._new(base, new, x, y, w, h)

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		container = self:inherit(engine:lib_get(":event.container"))
		ui_base = self:inherit(engine:lib_get(":ui.base"))
	end
}

ui_container.event = {
	draw = ui_container.draw,
	mousedown = ui_container.mousedown,
	mousedown_in = ui_container.mousedown_in,
	mouseup = ui_container.mouseup,
	mouseup_in = ui_container.mouseup_in
}

return ui_container