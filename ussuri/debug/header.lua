--[[
Debug Header
Intercepts Keystrokes to assist in speedy debugging
]]

local engine, lib
local header

header = {
	trigger_key_meta = {"lctrl", "rctrl"},
	trigger_key = "tab",
	log_save_key = "lshift",

	event = {
		keydown_priority = -503,
		keydown = function(self, event)
			if (love.keyboard.isDown(unpack(self.trigger_key_meta))) then
				if (event.key == self.trigger_key) then
					event.flags.cancel = true

					if (love.keyboard.isDown(self.log_save_key)) then
						engine.config.log.autosave = true
						engine.log:write(lib.utility.table_tree(engine))
					end

					engine:quit()
				end
			end
		end
	},

	init = function(self, g_engine)
		engine = g_engine
		lib = engine.lib
	end
}

return header