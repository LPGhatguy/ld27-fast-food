local map
local game
local lib

map = {
	quads = {},
	layers = {},
	sources = {},
	sheets = {},
	collide = {},
	meta = {},

	draw = function(self, event)
		for key = 1, #self.layers do
			if (not self.layers[key]["post"]) then
				love.graphics.draw(self.sheets[key])
			end
		end
	end,

	post_draw = function(self, event)
		for key = 1, #self.layers do
			if (self.layers[key]["post"]) then
				love.graphics.draw(self.sheets[key])
			end
		end
	end,

	render = function(self)
		for layer_id = 1, #self.layers do
			local layer = self.layers[layer_id]
			for y, layery in next, layer do
				if (type(layery) == "table") then
					for x, layeryx in next, layery do
						local tile = self.quads[layeryx]

						if (tile) then
							if (self.sheets[layer_id]) then
								self.sheets[layer_id]:addq(tile,
									game.tile_size * game.scale * (x),
									game.tile_size * game.scale * (y),
									0, game.scale, game.scale, 0, 0)
							else
								print("Can't find spritesheet", layer_id)
							end
						else
							print("Could not find tile at", x, y)
						end
					end
				end
			end
		end
	end,

	load = function(self, source, path)
		local layer_id
		local collision_mask = {}
		local meta_mask = {}

		for line in love.filesystem.lines(path) do
			local command, data = line:match("^(%a+)(.-)$")

			if (command == "layer") then
				lib.utility.table_deepmerge_strung(collision_mask, self.collide)
				lib.utility.table_deepmerge_strung(meta_mask, self.meta)

				layer_id = self:add_layer(source, data:find("post"))
				collision_mask = {}
				meta_mask = {}
			elseif (command == "d") then
				local row = {}
				local collide_row = {}
				local meta_row = {}
				local column = 0

				for item in data:gmatch("[^%s]+") do
					column = column + 1

					local tile = item:match("%d+")
					local meta = item:match("%a+")

					if (meta) then
						for index = 1, meta:len() do
							local char = meta:sub(index, index)

							if (char == "c") then
								collide_row[column] = true
							else
								if (meta_row[column]) then
									meta_row[column] = meta_row[column] .. char
								else
									meta_row[column] = char
								end
							end
						end
					end

					if (tonumber(tile) and tonumber(tile) ~= 0) then
						row[column] = tonumber(tile)
					end
				end

				table.insert(self.layers[layer_id], row)
				table.insert(collision_mask, collide_row)
				table.insert(meta_mask, meta_row)
			end
		end

		lib.utility.table_deepmerge_strung(collision_mask, self.collide)
		lib.utility.table_deepmerge_strung(meta_mask, self.meta)
	end,

	add_layer = function(self, source, post)
		local layer = {}
		local layer_id = #self.layers + 1
		self.layers[layer_id] = layer

		if (post) then
			self.layers[layer_id].post = true
		end

		self.sheets[layer_id] = love.graphics.newSpriteBatch(source, 1024)
		self.sources[layer_id] = source

		return layer_id
	end,

	_new = function(base, new, sources)
		if (sources) then
			for key = 1, #sources do
				new.sheets[key] = love.graphics.newSpriteBatch(sources[key], 1024)
				new.sources[key] = sources[key]
			end
		end

		return new
	end,

	init = function(self, engine)
		lib = engine.lib
		game = lib.tsr.game

		lib.oop:objectify(self)
	end
}

return map