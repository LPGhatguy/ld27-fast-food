local main_menu
local game
local lib

main_menu = {
	event = {
		["state_changed"] = function(self, event)
			print("main menu enter!")
			love.graphics.setBackgroundColor(0, 0, 0)
			self.play_button.font = game._c.font.menu_button
			self.quit_button.font = game._c.font.menu_button

			game.state:set_state("title")
			--game._c.sound.title_music:play()
		end,

		["state_changing"] = function(self, event)
			print("main menu leave!")
			game._c.sound.title_music:stop()
		end,

		["draw"] = function(self, event)
			self.ui:draw(event)
		end,

		["mousedown"] = function(self, event)
			self.ui:mousedown(event)
		end
	},

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		self.ui = lib.ui.ui_container:new()

		local play_button = self.ui:add(lib.ui.text_button:new())
		self.play_button = play_button
		play_button.text = "Play!"
		play_button.x = 40
		play_button.height = 40
		game.dbind:lock_percent(play_button, {"height", "y"}, 0.3)
		game.dbind:lock_percent(play_button, "width", 1, -80)

		local quit_button = self.ui:add(lib.ui.text_button:new())
		self.quit_button = quit_button
		quit_button.text = "Quit"
		quit_button.x = 40
		quit_button.height = 40
		game.dbind:lock_percent(quit_button, {"height", "y"}, 0.3, 50)
		game.dbind:lock_percent(quit_button, "width", 1, -80)

		play_button.event_mousedown_in:connect(function(event)
			game.state:set_state("game_intro")
		end)

		quit_button.event_mousedown_in:connect(function(event)
			engine:quit()
		end)
	end
}

return main_menu