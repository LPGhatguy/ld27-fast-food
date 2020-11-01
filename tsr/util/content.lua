local content
local lib

content = {
	content = {},
	root_directory = "asset/",

	loaders = {
		["image"] = function(self, path)
			local item = love.graphics.newImage(path)

			return item
		end,

		["image_data"] = function(self, path)
			local item = love.image.newImageData(path)

			return item
		end,

		["sound_effect"] = function(self, path)
			local item = love.sound.newSoundData(path)

			return item
		end,

		["sound"] = function(self, path)
			local item = love.audio.newSource(path)

			return item
		end,

		["font"] = function(self, path)
			local fonts = {}

			for line in love.filesystem.lines(path) do
				local items = {}

				for item in line:gmatch("[^%s]+") do
					table.insert(items, item)
				end

				if (#items >= 2) then
					if (#items >= 3) then
						fonts[items[1]] = love.graphics.newFont(items[3], tonumber(items[2]))
					else
						fonts[items[1]] = love.graphics.newFont(tonumber(items[2]))
					end
				end
			end

			return fonts
		end
	},

	file_types = {
		["bmp"] = "image_data",
		["png"] = "image",
		["ogg"] = "sound",
		["wav"] = "sound",
		["lfnt"] = "font"
	},

	load = function(self, path, under)
		if (type(path) == "table") then
			for key = 1, #path do
				self:load(unpack(path[key]))
			end
		else
			if (love.filesystem.isFile(self.root_directory .. path)) then
				local name, extension = path:match("([%w_-]*)%.(%w*)$")
				local loader_name = self.file_types[extension]

				if (loader_name) then
					local loader = self.loaders[loader_name]

					if (loader) then
						under = under or loader_name

						local location = lib.utility.table_nav(self.content, under, true)
						location[name] = loader(self, self.root_directory .. path)
					else
						print("Missing loader definition for content type", loader_name)
					end
				else
					print("Could not find file loader definition for file of type", extension)
				end
			else
				print("Could not load asset at", path)
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return content