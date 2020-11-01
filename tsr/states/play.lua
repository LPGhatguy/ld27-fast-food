local play
local engine
local game
local lib

play = {
	free_cam = false,
	paused = false,

	event = {
		["state_changed"] = function(self, event)
			print("play enter!")
			love.graphics.setBackgroundColor(0, 0, 0)

			local world = engine:lib_get("tsr.util.world"):new()
			self.world = world
			world.map = engine:lib_get("tsr.util.map"):new({})

			local spriter = engine:lib_get("tsr.util.spriter"):new()
			world.map.quads = spriter:construct(game._c.tiles.tiles_1)

			world.map:load(game._c.tiles.tiles_1, "asset/map/test.map")
			world.map:render()

			local char_spriter = engine:lib_get("tsr.util.spriter"):new()
			char_spriter.indices = {"up", "down", "left", "right"}

			local player = engine:lib_get("tsr.util.player"):new(world, game._c.character.vlad)
			self.player = player
			player.quads = char_spriter:construct(game._c.character.vlad)

			local collide_char = engine:lib_get("tsr.util.npc"):new(world, game._c.character.sideburns)
			collide_char.quads = char_spriter:construct(game._c.character.sideburns)
			collide_char.death_sound = game._c.sound.sideburns_death
			collide_char.surprise_sound = game._c.sound.sideburns_surprise

			local collide_char2 = engine:lib_get("tsr.util.npc"):new(world, game._c.character.toothpaste)
			collide_char2.quads = char_spriter:construct(game._c.character.toothpaste)
			collide_char2.death_sound = game._c.sound.toothpaste_death
			collide_char2.surprise_sound = game._c.sound.toothpaste_surprise

			local collide_char3 = engine:lib_get("tsr.util.npc"):new(world, game._c.character.bubblegum)
			collide_char3.quads = char_spriter:construct(game._c.character.bubblegum)
			collide_char3.death_sound = game._c.sound.bubblegum_death
			collide_char3.surprise_sound = game._c.sound.bubblegum_surprise

			local collide_char4 = engine:lib_get("tsr.util.npc"):new(world, game._c.character.farmer)
			collide_char4.quads = char_spriter:construct(game._c.character.farmer)
			collide_char4.death_sound = game._c.sound.farmer_death
			collide_char4.surprise_sound = game._c.sound.farmer_surprise

			world:spawn("p", player)
			world:spawn("w", collide_char)
			world:spawn("x", collide_char2)
			world:spawn("y", collide_char3)
			world:spawn("z", collide_char4)

			self.player = player
			table.insert(world.entities, player)

			world.camera = player

			game.dbind:bind({player, "x"}, {world.camera, "x"})
			game.dbind:bind({player, "y"}, {world.camera, "y"})

			self.timer.font = game._c.font.timer

			game._c.sound.game_music:setLooping(true)
			game._c.sound.game_music:play()
		end,

		["state_changing"] = function(self, event)
			print("play leave!")
			game._c.sound.game_music:stop()
		end,

		["draw"] = function(self, event)
			love.graphics.push()

			self.world:draw(event)

			love.graphics.pop()

			self.clock:draw()
			self.timer:draw()

			if (self.paused) then
				love.graphics.print("paused", 0, 0)
			end
		end,

		["tick"] = function(self, event)
			if (not self.paused) then
				--local move_type = love.keyboard.isDown("lshift") and "run" or "walk"
				local move_type = "walk"

				if (love.keyboard.isDown("d")) then
					self.player:move(move_type, 1, 0)
					game.dbind:rebind()
				elseif (love.keyboard.isDown("a")) then
					self.player:move(move_type, -1, 0)
					game.dbind:rebind()
				elseif (love.keyboard.isDown("w")) then
					self.player:move(move_type, 0, -1)
					game.dbind:rebind()
				elseif (love.keyboard.isDown("s")) then
					self.player:move(move_type, 0, 1)
					game.dbind:rebind()
				end

				self.world:tick(event)

				if (self.player.danger) then
					self.timer.text = math.ceil(self.player.danger_time - self.player.danger_elapsed)
					self.timer.align = "center"
				elseif (self.player.burning) then
					self.timer.text = "Fail"
				else
					self.timer.text = "Safe"
				end
			end
		end,

		["keydown"] = function(self, event)
			if (event.key == " ") then
				self.player:attack()
			elseif (event.key == "`") then
				self.player:burn()
			end

			if (self.free_cam) then
				if (event.key == "a") then
					self.world.camera:nudge(-32)
				elseif (event.key == "d") then
					self.world.camera:nudge(32)
				elseif (event.key == "w") then
					self.world.camera:nudge(0, -32)
				elseif (event.key == "s") then
					self.world.camera:nudge(0, 32)
				end
			end

			if (event.key == "f1") then
				self.free_cam = not self.free_cam
			elseif (event.key == "escape") then
				self.paused = not self.paused
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