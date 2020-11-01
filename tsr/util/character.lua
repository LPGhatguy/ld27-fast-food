local character
local game
local lib

character = {
	world = nil,
	mobile = true,
	collidable = true,
	blocking = true,
	alive = true,

	sort = 0,
	x = 0,
	y = 0,
	offset_x = 0,
	offset_y = 0,

	direction = "up",
	frame = 1,
	anim = nil,
	quads = {},
	animation = {
		walk = {speed = 0.2, 1, 2, 3},
		run = {speed = 0.1, 1, 2, 3}
	},

	move = function(self, name, x, y)
		local anim_data = self.animation[name]
		if (not self.anim and anim_data and self.mobile) then
			self:point(x, y)

			if (self:check_collision(self.x + x, self.y + y)) then
				return false
			end

			self.frame = 1

			self.anim = {
				name = name,
				x = x,
				y = y,
				index = 1,
				elapsed = 0,
				anim_elapsed = 0,
				total = anim_data.speed * #anim_data,
				travel_speed = (game.tile_size * game.scale) / (anim_data.speed * #anim_data)
			}

			self.x = self.x + x
			self.y = self.y + y
			self.offset_x = -game.tile_size * game.scale * x
			self.offset_y = -game.tile_size * game.scale * y

			return true
		end
	end,

	point = function(self, x, y)
		if (x and y) then
			if (x > 0) then
				self.direction = "right"
			elseif (x < 0) then
				self.direction = "left"
			elseif (y > 0) then
				self.direction = "down"
			elseif (y < 0) then
				self.direction = "up"
			end
		end
	end,

	check_collision = function(self, x, y)
		if (self.world) then
			if (self.world:collides_map(x, y)) then
				return true
			end

			if (self.collidable and self.world:collides_entity(x, y)) then
				return true
			end
		end
	end,

	draw = function(self, event)
		local frameset = self.quads[self.direction]

		if (frameset) then
			local frame = frameset[self.frame]

			if (frame) then
				love.graphics.drawq(self.source, frame,
					(game.tile_size * game.scale * self.x + self.offset_x),
					(game.tile_size * game.scale * self.y + self.offset_y),
					0, game.scale, game.scale, 0, 0)
			end
		end
	end,

	tick = function(self, event)
		if (self.anim) then
			local anim = self.anim
			local anim_data = self.animation[anim.name]

			anim.elapsed = anim.elapsed + event.delta
			anim.anim_elapsed = anim.anim_elapsed + event.delta

			if (anim.elapsed >= anim.total) then
				self.offset_x = 0
				self.offset_y = 0
				self.frame = 1

				self.anim = nil

				if (anim.post) then
					anim.post(self)
				end
			else
				self.offset_x = (anim.travel_speed * anim.elapsed - (game.tile_size * game.scale)) * anim.x
				self.offset_y = (anim.travel_speed * anim.elapsed - (game.tile_size * game.scale)) * anim.y

				if (anim.anim_elapsed >= anim_data.speed) then
					anim.index = math.min(anim.index + 1, #anim_data)
					self.frame = self.animation[anim.name][anim.index]

					anim.anim_elapsed = anim.anim_elapsed - anim_data.speed
				end
			end
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
	end
}

return character