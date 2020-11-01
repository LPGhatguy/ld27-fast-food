local play
local engine
local game
local lib

play = {
	pass_time = 28,
	pass_elapsed = 0,
	stage = 1,
	steps = {{"walk", 0, 1}, {"walk", 0, 1}, {"walk", 1, 0}},

	free_cam = false,
	paused = false,

	event = {
		["state_changed"] = function(self, event)
			print("intro enter!")
			love.graphics.setBackgroundColor(0, 0, 0)

			local world = engine:lib_get("tsr.util.world"):new()
			self.world = world
			world.map = engine:lib_get("tsr.util.map"):new({})
			world.winnable = false

			local spriter = engine:lib_get("tsr.util.spriter"):new()
			world.map.quads = spriter:construct(game._c.tiles.tiles_1)

			world.map:load(game._c.tiles.tiles_1, "asset/map/test.map")
			world.map:render()

			local char_spriter = engine:lib_get("tsr.util.spriter"):new()
			char_spriter.indices = {"up", "down", "left", "right"}

			local player = engine:lib_get("tsr.util.player"):new(world, game._c.character.vlad)
			self.player = player
			player.quads = char_spriter:construct(game._c.character.vlad)

			world:spawn("p", player)

			self.player = player
			table.insert(world.entities, player)

			world.camera = player

			game.dbind:bind({player, "x"}, {world.camera, "x"})
			game.dbind:bind({player, "y"}, {world.camera, "y"})

			self.timer.font = game._c.font.timer

			game._c.sound.game_intro_music:play()
			game._c.sound.game_intro_mono:play()
		end,

		["state_changing"] = function(self, event)
			print("intro leave!")
			self.pass_elapsed = 0

			game._c.sound.game_intro_music:stop()
			game._c.sound.game_intro_mono:stop()
		end,

		["draw"] = function(self, event)
			love.graphics.push()
			self.world:draw(event)
			love.graphics.pop()

			love.graphics.setFont(game._c.font.menu_button)
			love.graphics.setColor(255, 255, 255)
			love.graphics.printf("Press space to skip", 0, game.dbind.height - 80, game.dbind.width, "center")
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf("Press space to skip", 2, game.dbind.height - 82, game.dbind.width, "center")
		end,

		["tick"] = function(self, event)
			self.pass_elapsed = self.pass_elapsed + event.delta

			if (self.pass_elapsed >= self.pass_time) then
				game.state:set_state("instructions")
			end

			if (self.pass_elapsed > 6 and self.stage == 1) then
				self.stage = 2
				self.player:point(0, 1)
			elseif (self.stage > 1) then
				if (self.pass_elapsed > self.stage + 6) then
					if (self.pass_elapsed < 9 + #self.steps) then
						self.stage = self.stage + 1
						self.player:move(unpack(self.steps[self.stage - 3] or {"walk", 0, 0}))
					elseif (self.stage == 3 + #self.steps) then
						self.stage = self.stage + 1
						self.player:move("run", 0, -2)
					elseif (self.stage == 7) then
						self.player:point(0, 1)
						self.stage = 8
					end
				end
			end

			self.world:tick(event)
		end,

		["keydown"] = function(self, event)
			if (event.key == " ") then
				game.state:set_state("instructions")
			end
		end
	},

	init = function(self, g_engine)
		engine = g_engine
		lib = engine.lib
		game = lib.tsr.game

		game.content:load(game.assets.tiles)
		game.content:load(game.assets.characters)
		game.content:load(game.assets.ui)

		local clock = engine:lib_get(":ui.image"):new()
		self.clock = clock
		clock.source = game._c.ui.clock
		clock.width = 64
		clock.height = 64
		clock.x = 8
		clock.y = 8

		local timer = engine:lib_get(":ui.text_label"):new()
		self.timer = timer
		timer.background_color = {0, 0, 0, 0}
		timer.border_color = {0, 0, 0, 0}
		timer.text_color = {0, 0, 0, 255}
		timer.text = "Safe"
		timer.width = 70
		timer.height = 32
		timer.x = 6
		timer.y = 24
	end
}

return play