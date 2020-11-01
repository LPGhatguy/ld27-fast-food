--[[
Timed Queue
Queues events to happen in sequence after time
]]

local lib
local queue

queue = {
	LOCKING = 1,
	LOCKABLE = 2,
	LOCKINGABLE = 3,

	lock = 0,
	stack = {},

	queue = function(self, time, lock, pre, post)
		if (not self.locked) then
			local locking = (lock == self.LOCKING or lock == self.LOCKINGABLE)
			local lockable = (lock == self.LOCKABLE or lock == self.LOCKINGABLE)

			if (not (self.lock ~= 0 and lockable)) then
				local stack = self.stack
				local queued = {
					time = time or 0,
					pre = pre,
					post = post,
					locking = locking,
					lockable = lockable
				}

				if (locking) then
					self.lock = self.lock + 1
				end

				if (#stack == 0) then
					stack[1] = false
					stack[2] = queued
					self:cycle()
				else
					stack[#stack + 1] = queued
				end
			end
		end
	end,

	cycle = function(self)
		local last = lib.utility.table_pop(self.stack)

		if (last) then
			if (last.post) then
				if (type(last.post) == "table") then
					lib.utility.table_pop(last.post)(unpack(last.post))
				else
					last.post()
				end
			end

			if (last.locking) then
				self.lock = math.max(self.lock - 1, 0)
			end
		end

		local current = self.stack[1]

		if (current and current.pre) then
			if (type(current.pre) == "table") then
				lib.utility.table_pop(current.pre)(unpack(current.pre))
			else
				current.pre()
			end
		end
	end,

	tick = function(self, event)
		local current = self.stack[1]

		if (current) then
			if (event.delta > current.time) then
				current.time = 0
				self:cycle()
			else
				current.time = current.time - event.delta
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end,
}

queue.event = {
	tick = queue.tick
}

return queue