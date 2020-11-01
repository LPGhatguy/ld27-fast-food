--[[
Frame Stepper
Performs an action a number of times per tick and disconnects after a set number of frames
]]

local lib
local frame_stepper

frame_stepper = {
	steps_per_tick = 1,
	steps_left = 0,

	tick = function(self, event)
		if (self.action and self.steps_left ~= 0) then
			for count = 1, self.steps_per_tick do
				self.steps_left = self.steps_left - 1

				if (self.steps_left ~= 0) then
					self:action(event)
				else
					break
				end
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end,
}

frame_stepper.event = {
	tick = frame_stepper.tick
}

return frame_stepper