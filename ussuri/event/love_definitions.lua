--[[
Event Definitions
Implements LÖVE events into the standard Ussuri event stack
Monkey-patches engine.event
]]

local definitions

definitions = {
	display_update = function(self, ...)
		love.graphics.setMode(...)
		self:fire_display_updated(...)
	end,

	fire_keydown = function(self, key, code)
		return self:event_fire("keydown", {
			key = key,
			code = code
		})
	end,

	fire_keyup = function(self, key)
		return self:event_fire("keyup", {
			key = key
		})
	end,

	fire_mousedown = function(self, x, y, button)
		return self:event_fire("mousedown", {
			ox = 0,
			x = x,
			abs_x = x,
			oy = 0,
			y = y,
			abs_y = y,
			button = button
		})
	end,

	fire_mouseup = function(self, x, y, button)
		return self:event_fire("mouseup", {
			ox = 0,
			x = x,
			abs_x = x,
			oy = 0,
			y = y,
			abs_y = y,
			button = button
		})
	end,

	fire_joydown = function(self, joystick, button)
		return self:event_fire("joydown", {
			joystick = joystick,
			button = button
		})
	end,

	fire_joyup = function(self, joystick, button)
		return self:event_fire("joyup", {
			joystick = joystick,
			button = button
		})
	end,

	fire_focus = function(self, focus)
		return self:event_fire("focus", {
			focus = focus
		})
	end,

	fire_tick = function(self, delta)
		return self:event_fire("tick", {
			delta = delta
		})
	end,

	fire_draw = function(self)
		return self:event_fire("draw", {
			ox = 0,
			oy = 0
		})
	end,

	fire_quit = function(self)
		return self:event_fire("quit", {})
	end,

	fire_display_updating = function(self, width, height, fullscreen, vsync, fsaa)
		return self:event_fire("display_updating", {
			width = width,
			height = height,
			fullscreen = fullscreen,
			vsync = vsync
		})
	end,

	fire_display_updated = function(self, width, height, fullscreen, vsync, fsaa)
		return self:event_fire("display_updated", {
			width = width,
			height = height,
			fullscreen = fullscreen,
			vsync = vsync
		})
	end,

	init = function(self, engine)
		engine:lib_get(":event.handler")

		local engine_event = engine.event

		engine_event:event_create({"tick", "draw", "quit", "focus",
			"keydown", "keyup", "joydown", "joyup", "mousedown", "mouseup",
			"display_updating", "display_updated"})

		engine_event:inherit(self)

		love.handlers = setmetatable({
			keypressed = function(b, u)
				engine_event:fire_keydown(b, u)
			end,

			keyreleased = function(b)
				engine_event:fire_keyup(b)
			end,

			mousepressed = function(x, y, b)
				engine_event:fire_mousedown(x, y, b)
			end,

			mousereleased = function(x, y, b)
				engine_event:fire_mouseup(x, y, b)
			end,

			joystickpressed = function(j, b)
				engine_event:fire_joydown(j, b)
			end,

			joystickreleased = function(j, b)
				engine_event:fire_joyup(j, b)
			end,

			focus = function(f)
				engine_event:fire_focus(f)
			end,

			quit = function()
				return
			end
			},
			{
			__index = function(self, name)
				error("Unknown event: " .. name)
			end
			}
		)
	end,

	close = function(self, engine)
		engine.event:fire_quit()
	end
}

return definitions