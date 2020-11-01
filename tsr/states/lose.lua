local lose
local game
local lib

lose = {
	event = {
		["state_changed"] = function(self, event)
			print("lose enter!")
			love.graphics.setBackgroundColor(0, 0, 0)
			self.lose_label.font = game._c.font.menu_button
			self.continue.font = game._c.font.menu_button

			game._c.sound.game_over:play()
		end,

		["state_changing"] = function(self, event)
			print("lose leave!")
		end,

		["draw"] = function(self, event)
			self.ui:draw(event)
		end,

		["mousedown"] = function(self, event)
			game.state:set_state("main_menu")
		end,

		["keydown"] = function(self, event)
			game.state:set_state("main_menu")
		end
	},

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		self.ui = lib.ui.ui_container:new()

		local lose_label = self.ui:add(lib.ui.text_label:new())
		self.lose_label = lose_label
		lose_label.background_color = {0, 0, 0, 0}
		lose_label.border_color = {0, 0, 0, 0}
		lose_label.text = "Game Over"
		game.dbind:lock_percent(lose_label, {"height", "y"}, 0.5)
		game.dbind:lock_percent(lose_label, "width", 1)

		local continue = self.ui:add(lose_label:copy())
		self.continue = continue
		continue.text = "Press any key to return."
		game.dbind:lock_percent(continue, {"height", "y"}, 1, -40)
		game.dbind:lock_percent(continue, "width", 1)
	end
}

return lose