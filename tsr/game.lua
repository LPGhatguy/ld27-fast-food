local game
local lib

game = {
	scale = 2,
	tile_size = 32,

	DEBUG = true,

	init = function(self, engine)
		lib = engine.lib
		engine = engine

		love.graphics.setDefaultImageFilter("nearest", "nearest")

		lib.oop:objectify(self)

		self:inherit(engine:lib_get(":event.handler"))

		self.content = engine:lib_get("tsr.util.content"):new()
		self._c = self.content.content

		self.state = engine:lib_get(":misc.state_machine"):new()

		self.dbind = engine:lib_get("tsr.util.dbind")

		self.assets = engine:lib_get("tsr.assets")
		self.states = engine:lib_get("tsr.states")

		self.state.handlers = self.states

		self.content:load(self.assets.core)

		local events = {"draw", "tick", "mousedown", "mouseup", "keydown", "keyup"}

		self:event_create(events)
		self:event_hook_object(self.state, events)

		self:event_create("display_updated")
		self:event_hook_light({}, "display_updated", function(this, event)
			self.dbind.width = event.width
			self.dbind.height = event.height

			self.dbind:rebind()
		end)

		self:event_hook_light({}, "keydown", function(this, event)
			if ((event.key == "f4" and love.keyboard.isDown("lalt"))) then
				engine:quit()
			end
		end)

		self.state:set_state("config")
	end
}

return game