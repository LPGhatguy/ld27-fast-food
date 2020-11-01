local world
local game
local lib

world = {
	win_time = 3,
	win_elapsed = 0,
	winnable = true,

	map = nil,
	camera = nil,
	entities = {},

	draw = function(self, event)
		love.graphics.setColor(255, 255, 255)

		if (self.camera) then
			self.camera:apply()
		end

		if (self.map) then
			self.map:draw()
		end

		for key = 1, #self.entities do
			self.entities[key]:draw()
		end

		if (self.map) then
			self.map:post_draw()
		end
	end,

	tick = function(self, event)
		local enemies_alive = false

		for key = 1, #self.entities do
			local entity = self.entities[key]
			entity:tick(event)

			if (entity.kill_goal and entity.alive) then
				enemies_alive = true
			end
		end

		if (self.winnable and not enemies_alive) then
			self.win_elapsed = self.win_elapsed + event.delta

			if (self.win_elapsed >= self.win_time) then
				self.win_elapsed = 0
				self:win()
			end
		end
	end,

	lose = function(self)
		game.state:set_state("lose")
	end,

	win = function(self)
		game.state:set_state("win")
	end,

	sort_entities = function(self)
		table.sort(self.entities, function(first, second)
			return first.sort > second.sort
		end)
	end,

	get_entities = function(self, x, y)
		local entities = {}

		for key, value in pairs(self.entities) do
			if (value.x == x and value.y == y) then
				table.insert(entities, value)
			end
		end

		return entities
	end,

	get_map_meta = function(self, x, y)
		if (self.map) then
			return self.map.meta[y] and self.map.meta[y][x] or "error"
		end

		return ""
	end,

	collides_map = function(self, x, y)
		if (self.map) then
			return self.map.collide[y] and self.map.collide[y][x]
		end
	end,

	collides_entity = function(self, x, y, ignore)
		for key, value in pairs(self.entities) do
			if (ignore ~= value and value.collidable and value.x == x and value.y == y) then
				return true
			end
		end
	end,

	spawn = function(self, place, entity)
		table.insert(self.entities, entity)
		local possibilities = {}

		if (self.map) then
			local meta = self.map.meta
			possibilities = {}
			for y, metay in next, meta do
				for x, metayx in next, metay do
					if (metayx:match(place)) then
						table.insert(possibilities, {x, y})
					end
				end
			end

			if (#possibilities == 0) then
				possibilities = {{0, 0}}
			end
		else
			possiblities = {{0, 0}}
		end

		local choice = math.random(1, #possibilities)

		entity.x = possibilities[choice][1]
		entity.y = possibilities[choice][2]
	end,

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		lib.oop:objectify(self)
	end
}

return world