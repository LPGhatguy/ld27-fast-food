local npc
local character
local game
local lib

npc = {
	death_sound = nil,
	surprise_sound = nil,

	kill_goal = true,
	scared = false,
	fleshy = true,
	sort = 5,

	sight_elapsed = 0,
	sight_frequency = 0.1,
	sight_quality = 8,

	repoint_elapsed = 0,
	repoint_frequency = 1,
	repoint_at = 1,
	repoint_trend = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}},

	calm_elapsed = 0,
	calm_time = 16,
	
	trend = {},

	gaze = function(self)
		if (self.direction == "up") then
			self:look(0, -1, self.sight_quality)
			self:look(1, -1, self.sight_quality)
			self:look(-1, -1, self.sight_quality)
		elseif (self.direction == "down") then
			self:look(0, 1, self.sight_quality)
			self:look(1, 1, self.sight_quality)
			self:look(-1, 1, self.sight_quality)
		elseif (self.direction == "left") then
			self:look(-1, 0, self.sight_quality)
			self:look(-1, 1, self.sight_quality)
			self:look(-1, -1, self.sight_quality)
		elseif (self.direction == "right") then
			self:look(1, 0, self.sight_quality)
			self:look(1, 1, self.sight_quality)
			self:look(1, -1, self.sight_quality)
		end
	end,

	look = function(self, x, y, steps)
		if (self.world) then
			for step = 1, steps do
				local stop = false
				local check_x, check_y = self.x + (x * step), self.y + (y * step)
				local seen = self.world:get_entities(check_x, check_y)
				local meta = self.world:get_map_meta(check_x, check_y)
				local before_scare = self.scared

				if (#seen > 0) then
					for key, item in next, seen do
						if (item.blocking) then
							stop = true
						end

						if (item.scary) then
							self.scared = true

							if (x ~= 0) then
								self.trend = {{-x, 0}, {0, 1}, {0, -1}}
							elseif (y ~= 0) then
								self.trend = {{0, -y}, {1, 0}, {-1, 0}}
							end
						end
					end
				end

				if (meta) then
					if (meta:find("o")) then
						stop = true
					elseif (meta:find("s")) then
						self.scared = true
					end
				end

				if (not before_scare and self.scared) then
					if (self.surprise_sound) then
						self.surprise_sound:play()
					end
				end

				if (stop) then
					break
				end
			end
		end
	end,

	kill = function(self)
		self.alive = false
		self.mobile = false
		self.collidable = false
		self.blocking = false
		self.fleshy = false
		self.scared = false
		self.scary = true
		self.anim = nil

		self.direction = "up"
		self.frame = 4

		if (self.death_sound) then
			self.death_sound:play()
		end
	end,

	tick = function(self, event)
		if (self.alive) then
			self.sight_elapsed = self.sight_elapsed + event.delta
			self.repoint_elapsed = self.repoint_elapsed + event.delta

			if (self.scared) then
				self.calm_elapsed = self.calm_elapsed + event.delta

				if (self.calm_elapsed >= self.calm_time) then
					self.calm_elapsed = 0
					self.scared = false
				end
			end

			if (not self.scared and self.repoint_elapsed >= self.repoint_frequency) then
				self.repoint_elapsed = 0
				self.repoint_at = self.repoint_at + 1

				if (self.repoint_at > #self.repoint_trend) then
					self.repoint_at = 1
				end
				self:point(unpack(self.repoint_trend[self.repoint_at] or {}))
			end

			if (self.sight_elapsed >= self.sight_frequency) then
				self.sight_elapsed = 0
				self:gaze()
			end

			if (self.scared and not self.anim) then
				self:move("run", unpack(self.trend[math.random(1, math.max(#self.trend, 1))] or {}))
			end
		end

		character.tick(self, event)
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

return npc