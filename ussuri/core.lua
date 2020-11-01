--[[
Ussuri Core
Provides the underlying functionality of Ussuri!
]]

local lib, lib_flat, lib_core = {}, {}, {}
local config
local core

local path = debug.getinfo(1).short_src:match("(.*/).*$")
local path_dot = path:gsub("/", ".")

local version_meta = {
	__tostring = function(self)
		return ("%d.%d.%d %q"):format(unpack(self))
	end
}

local batch_load = function(batch)
	for key, path in next, batch do
		local name = path:match("%w+$")
		local library = require(path:gsub("^:", config.path_dot))

		lib[name] = library
		lib_core[name] = library

		if (type(library) == "table") then
			if (library.init) then
				library:init(core)
			end
		end
	end
end

core = {
	lib = lib,
	lib_flat = lib_flat,
	lib_core = lib_core,

	start = function()
	end,

	init = function(self)
		config = require(path_dot .. "config")
		self.config = config

		if (config.path) then
			config.path_dot = config.path:gsub("/", ".")
		else
			config.path = path
			config.path_dot = path_dot
		end

		setmetatable(config.version, version_meta)

		batch_load(config.lib_core)
	end,

	close = function(self)
		for key, library in pairs(self.lib_core) do
			if ((type(library) == "table") and library.close) then
				library:close(self)
			end
		end
	end,

	quit = function(self)
		love.event.push("quit")
	end
}

setmetatable(lib_flat, {__mode = "v"})

return core