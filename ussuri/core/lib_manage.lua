--[[
Library Manager
Manage libraries elegantly
]]

--[[
todo: use utility.table_nav instead of lib_nav_path
]]

local lib, lib_flat, path_dot
local lib_manage

lib_manage = {
	lib_nav_path = function(self, from, path, ensure)
		path = path:gsub(":", "")
		local split = lib.utility.string_split(path, ".")

		return lib.utility.table_nav(from, split, ensure)
	end,

	lib_get = function(self, paths)
		if (type(paths) == "table") then
			for key, path in next, paths do
				self:lib_get(path)
			end
		else
			local existing_lib = self:lib_nav_path(lib, paths)

			if (existing_lib) then
				return existing_lib
			else
				return self:lib_load(paths)
			end
		end
	end,

	lib_load = function(self, paths)
		if (type(paths) == "table") then
			for key, path in next, paths do
				self:lib_load(path)
			end
		else
			local abs_path = paths:gsub(":", path_dot)
			local slash_path = abs_path:gsub("%.", "/")

			if (love.filesystem.isFile(slash_path .. ".lua")) then
				return self:lib_file_load(paths)
			else
				if (love.filesystem.isDirectory(slash_path)) then
					return self:lib_folder_load(paths)
				end
			end
		end
	end,

	lib_folder_load = function(self, path)
		local slash_path = path:gsub(":", path_dot):gsub("%.", "/")
		local files = love.filesystem.enumerate(slash_path)

		for key, file_path in pairs(files) do
			self:lib_get(path .. "." .. file_path:gsub("/", "."):match("([^%.]+)%.?.*$"))
		end

		return self:lib_nav_path(lib, path)
	end,

	lib_file_load = function(self, path)
		local loaded = require(path:gsub(":", path_dot))

		if (type(loaded) == "table") then
			local load_location = self:lib_nav_path(lib, path:match("(.+)%..-$") or "", true)

			lib_flat[#lib_flat + 1] = loaded
			load_location[path:match("%.?([^%.]+)$")] = loaded

			if (type(loaded.init) == "function") then
				loaded:init(self)
			end
		end

		return loaded
	end,

	lib_batch_call = function(self, name)
		for key, library in next, lib_flat do
			if (library[name]) then
				library[name](library, self)
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib
		lib_flat = engine.lib_flat
		path_dot = engine.config.path_dot

		engine:inherit(self)

		engine:lib_load(engine.config.lib_aux)
	end,

	close = function(self, engine)
		for key, library in next, lib_flat do
			if (lib_flat.close) then
				lib_flat:close(engine)
			end
		end
	end
}

return lib_manage