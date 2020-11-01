local config
local game
local engine
local lib

config = {
	width = 400,
	height = 200,

	event = {
		["state_changed"] = function(self, event)
			print("config enter")
			love.graphics.setBackgroundColor(0, 0, 0)

			engine.event:display_update(self.width, self.height, false, true, 0)

			self.ok_button.font = game._c.font.config
		end,

		["state_changing"] = function(self, event)
			print("config leave")
			if (self.fullscreen_box.value) then
				local modes = love.graphics.getModes()
				local best

				for key = 1, #modes do
					if (not best or modes[key].width > best.width) then
						best = modes[key]
					end
				end

				engine.event:display_update(best.width, best.height, true, true, 0)
			else
				engine.event:display_update(1280, 720, false, true, 0)
			end
		end,

		["draw"] = function(self, event)
			self.ui:draw(event)
		end,

		["mousedown"] = function(self, event)
			self.ui:mousedown(event)
		end,

		["keydown"] = function(self, event)
			if (event.key == "return") then
				game.state:set_state("title")
			end
		end
	},

	init = function(self, g_engine)
		engine = g_engine
		lib = engine.lib
		game = lib.tsr.game

		self.ui = lib.ui.ui_container:new()

		local title = self.ui:add(lib.ui.text_label:new())
		title.text = "Settings"
		title.width = self.width
		title.height = 20
		title.padding_y = 4
		title.background_color = {0, 0, 0, 0}

		local ok_button = self.ui:add(lib.ui.text_button:new())
		self.ok_button = ok_button
		ok_button.text = "OK"
		ok_button.width = self.width - 8
		ok_button.height = 20
		ok_button.padding_y = 2
		ok_button.x = 4
		ok_button.y = self.height - ok_button.height - 4

		local fullscreen = self.ui:add(lib.ui.checkbox:new())
		self.fullscreen_box = fullscreen
		fullscreen.x = 8
		fullscreen.y = 40

		local fullscreen_label = self.ui:add(lib.ui.text_label:new())
		fullscreen_label.text = "Fullscreen"
		fullscreen_label.background_color = {0, 0, 0, 0}
		fullscreen_label.border_color = {0, 0, 0, 0}
		fullscreen_label.width = 60
		fullscreen_label.x = 50
		fullscreen_label.y = 40

		ok_button.event_mousedown_in:connect(function(event)
			game.state:set_state("title")
		end)
	end
}

return config