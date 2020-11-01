local instructions
local game
local lib

instructions = {
	event = {
		["state_changed"] = function(self, event)
			print("instructions enter!")
			love.graphics.setBackgroundColor(0, 0, 0)
			self.instructions_label.font = game._c.font.menu_button
			self.continue.font = game._c.font.menu_button
		end,

		["state_changing"] = function(self, event)
			print("instructions leave!")
		end,

		["draw"] = function(self, event)
			self.ui:draw(event)
		end,

		["mousedown"] = function(self, event)
			game.state:set_state("play")
		end,

		["keydown"] = function(self, event)
			game.state:set_state("play")
		end
	},

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		self.ui = lib.ui.ui_container:new()

		local instructions_label = self.ui:add(lib.ui.text_label:new())
		self.instructions_label = instructions_label
		instructions_label.background_color = {0, 0, 0, 0}
		instructions_label.border_color = {0, 0, 0, 0}
		instructions_label.text = "Use WASD to move\nUse SPACE to attack!\n\nWatch the clock, you can stay in the sun for\n10 seconds!"
		game.dbind:lock_percent(instructions_label, {"height", "y"}, 0.5, -120)
		game.dbind:lock_percent(instructions_label, "width", 1)

		local continue = self.ui:add(instructions_label:copy())
		self.continue = continue
		continue.text = "Press any key to continue."
		game.dbind:lock_percent(continue, {"height", "y"}, 1, -40)
		game.dbind:lock_percent(continue, "width", 1)
	end
}

return instructions