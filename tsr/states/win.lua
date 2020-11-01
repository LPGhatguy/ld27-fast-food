local win
local game
local lib

win = {
	event = {
		["state_changed"] = function(self, event)
			print("win enter!")
			love.graphics.setBackgroundColor(0, 0, 0)
			self.win_label.font = game._c.font.menu_button
			self.continue.font = game._c.font.menu_button

			game._c.sound.game_win:play()
		end,

		["state_changing"] = function(self, event)
			print("win leave!")
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

		local win_label = self.ui:add(lib.ui.text_label:new())
		self.win_label = win_label
		win_label.background_color = {0, 0, 0, 0}
		win_label.border_color = {0, 0, 0, 0}
		win_label.text = "You Win!"
		game.dbind:lock_percent(win_label, {"height", "y"}, 0.5)
		game.dbind:lock_percent(win_label, "width", 1)

		local continue = self.ui:add(win_label:copy())
		self.continue = continue
		continue.text = "Press any key to return."
		game.dbind:lock_percent(continue, {"height", "y"}, 1, -40)
		game.dbind:lock_percent(continue, "width", 1)
	end
}

return win