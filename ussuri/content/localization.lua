--[[
Content Localization
Localizes content -- inspired by Android's localization scheme
]]

local lib
local localization

localization = {
	language = "default",
	string_bindings = {},
	string = {},
	strings = {},

	set_language = function(self, value)
		self.language = value
		self:rebind()
		self:rebind_strings()
	end,

	rebind_strings = function(self)
		for key, value in next, self.string_bindings do
			local id, target = value[1], value[2]

			target[1][target[2]] = self:get_string(id)
		end
	end,

	bind_string = function(self, id, target)
		table.insert(self.string_bindings, {id, target})

		target[1][target[2]] = self:get_string(id)
	end,

	load_strings_from_directory = function(self, directory, name_pattern)
		local name_pattern = name_pattern or "(%w+)"

		if (love.filesystem.isDirectory(directory)) then
			for key, filename in pairs(love.filesystem.enumerate(directory)) do
				local language = filename:match(name_pattern)

				local out = self.strings[language] or {}
				self.strings[language] = out

				for line in love.filesystem.lines(directory .. filename) do
					local id, as = line:match("([^:]+):%s*(.*)")
					out[id] = as
				end
			end
		end
	end,

	load_strings_from_file = function(self, filename, language)
		local language = language or self.language

		if (love.filesystem.isFile(filename)) then
			local out = self.strings[language] or {}
			self.strings[language] = out

			for line in love.filesystem.lines(filename) do
				local id, as = line:match("([^:]+):%s*(.*)")
				out[id] = as
			end
		end
	end,

	get_string = function(self, id, language)
		local language = language or self.language

		local repo = self.strings[language] or self.strings["default"]

		return repo and repo[id] or "nil"
	end,

	_new = function(base, new)
		setmetatable(new.string, {
			__index = function(self, key)
				return new:get_string(key)
			end
		})

		return new
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		self:inherit(lib.data.bindable)

		self.language = engine.config.author_language
	end
}

return localization