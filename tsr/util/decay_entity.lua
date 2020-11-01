local character
local game
local lib

character = {
	world = nil,
	alive = true,

	life_time = 0,
	life_elapsed = 0,

	sort = 0,
	x = 0,
	y = 0,
	offset_x = 0,
	offset_y = 0,
	source = nil,

	draw = function(self, event)
		if (self.alive) then
			love.graphics.draw(self.source,
				(game.tile_size * game.scale * self.x + self.offset_x),
				(game.tile_size * game.scale * self.y + self.offset_y),
				0, game.scale, game.scale, 0, 0)
		end
	end,

	tick = function(self, event)
		self.life_elapsed = self.life_elapsed + event.delta

		if (self.life_elapsed >= self.life_time) then
			self.alive = false
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