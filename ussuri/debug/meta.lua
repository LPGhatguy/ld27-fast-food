--[[
Ussuri Meta
Gives information about the engine and its workings
]]

local lib
local meta

meta = {
	code = function(self, engine, dir, pattern)
		local pattern = pattern or ""
		local dir = dir or engine.config.path
		local file_count = 0
		local line_count = 0

		for key, filename in pairs(love.filesystem.enumerate(dir)) do
			local path = dir .. filename

			if (love.filesystem.isFile(path)) then
				if (filename:match(pattern)) then
					file_count = file_count + 1
					for line in love.filesystem.lines(path) do
						line_count = line_count + 1
					end
				end
			else
				local files, lines = self:code(engine, path .. "/", pattern)
				file_count = file_count + files
				line_count = line_count + lines
			end
		end

		return file_count, line_count
	end,

	init = function(self, engine)
		lib = engine.lib
	end
}

return meta