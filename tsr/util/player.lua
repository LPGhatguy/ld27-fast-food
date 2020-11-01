local player
local character
local game
local lib

player = {
	sort = 4,
	scary = true,
	burning = false,
	danger = false,
	flammable = true,

	danger_time = 10,
	danger_elapsed = 0,

	burn_shift_time = 0.4,
	burn_shift_elapsed = 0,

	loss_time = 6,
	loss_elapsed = 0,

	animation = {
		attack = {speed = 0.5, 4},
	},

	apply = function(self)
		love.graphics.translate(math.floor((-self.x * game.scale * game.tile_size) + game.dbind.width / 2 - self.offset_x),
			math.floor(((-self.y - 1) * game.scale * game.tile_size) + game.dbind.height / 2 - self.offset_y))
	end,

	move = function(self, ...)
		if (character.move(self, ...)) then
			self:do_danger()
		end
	end,

	attack = function(self)
		local anim_data = self.animation["attack"]
		if (not self.anim and anim_data and self.mobile) then
			local x, y

			if (self.direction == "up") then
				x = 0
				y = -1
			elseif (self.direction == "down") then
				x = 0
				y = 1
			elseif (self.direction == "left") then
				x = -1
				y = 0
			elseif (self.direction == "right") then
				x = 1
				y = 0
			end

			local attacking = self.world:get_entities(self.x + x, self.y + y)

			if (#attacking > 0) then
				local target
				for key, entity in next, attacking do
					if (entity.fleshy) then
						target = entity
						target:kill()
						break
					end
				end

				if (target) then
					self.frame = anim_data[1]

					self.anim = {
						name = "attack",
						x = x,
						y = y,
						index = 1,
						elapsed = 0,
						anim_elapsed = 0,
						total = anim_data.speed * #anim_data,
						travel_speed = (game.tile_size * game.scale) / (anim_data.speed * #anim_data),
						post = self.feast
					}

					self.x = self.x + x
					self.y = self.y + y
					self.offset_x = game.tile_size * game.scale * x
					self.offset_y = game.tile_size * game.scale * y

					if (self.direction == "down") then
						self.sort = target.sort + 1
					else
						self.sort = target.sort - 1
					end

					self.world:sort_entities()
					self:do_danger()

					game._c.sound.vlad_attack:play()
				end
			end
		end
	end,

	do_danger = function(self)
		local here = self.world:get_map_meta(self.x, self.y)

		if (here:find("g")) then
			self.danger = false
			self.danger_elapsed = 0
		else
			self.danger = true
		end
	end,

	burn = function(self)
		self.burning = true
		self.mobile = false
		self.anim = nil

		self.frame = 5
		game._c.sound.vlad_burn:play()
	end,

	feast = function(self)
		self.frame = 4
	end,

	lose = function(self)
		self.burning = false
		self.world:lose()
	end,

	draw = function(self, event)
		if (self.danger or self.burning) then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(120, 120, 120)
		end

		character.draw(self, event)

		love.graphics.setColor(255, 255, 255)
	end,

	tick = function(self, event)
		if (self.burning) then
			self.burn_shift_elapsed = self.burn_shift_elapsed + event.delta
			self.loss_elapsed = self.loss_elapsed + event.delta

			if (self.burn_shift_elapsed >= self.burn_shift_time) then
				self.burn_shift_elapsed = 0

				local direction = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}}
				self:point(unpack(direction[math.random(1, 4)]))
			end

			if (self.loss_elapsed >= self.loss_time) then
				self:lose()
			end
		else
			if (self.danger and self.flammable) then
				self.danger_elapsed = self.danger_elapsed + event.delta
				if (self.danger_elapsed >= self.danger_time) then
					self.danger_elapsed = 0
					self.danger = false
					self:burn()
				end
			end

			character.tick(self, event)
		end
	end,

	_new = function(base, new, world, source)
		new.world = world
		new.source = source

		return new
	end,

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		lib.oop:objectify(self)
		character = self:inherit(engine:lib_get("tsr.util.character"))
	end
}

return player