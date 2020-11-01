local title
local engine
local game
local lib

title = {
	event = {
		["state_changed"] = function(self, event)
			print("title enter!")
			love.graphics.setBackgroundColor(0, 0, 0)

			game.content:load(game.assets.title)
			game.content:load(game.assets.sound)

			local width, height = love.graphics.getMode()

			self.image.source = game.content.content.image["title"]

			self.key_text.font = game._c.font.title
			self.key_text.width, self.key_text.height = width, height
			self.key_text.y = height - 20

			game._c.sound.title_music:play()
		end,

		["state_changing"] = function(self, event)
			print("title leave!")
			game._c.sound.title_music:stop()
		end,

		["keydown"] = function(self, event)
			game.state:set_state("game_intro")

			if (event.key == "escape") then
				engine:quit()
			end
		end,

		["mousedown"] = function(self, event)
			game.state:set_state("game_intro")
		end,

		["draw"] = function(self, event)
			self.ui:draw(event)
		end,
	},

	init = function(self, g_engine)
		engine = g_engine
		lib = engine.lib
		game = lib.tsr.game

		self.ui = lib.ui.ui_container:new()

		self.image = self.ui:add(lib.ui.image:new())
		game.dbind:lock_percent(self.image, "width", 1)
		game.dbind:lock_percent(self.image, "height", 1)

		local key_text = self.ui:add(lib.ui.text_label:new())
		self.key_text = key_text
		key_text.border_color = {0, 0, 0, 0}
		key_text.background_color = {0, 0, 0, 0}
		key_text.text = "Press any key to continue or escape to quit."
	end
}

return title