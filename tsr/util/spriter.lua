local spriter
local lib

spriter = {
	width = 32,
	height = 32,
	indices = {},

	construct = function(self, image)
		local quads = {}
		local twidth, theight = image:getWidth(), image:getHeight()
		local maxw, maxh = twidth / self.width, theight / self.height

		for y = 1, maxh do
			for x = 1, maxw do
				local quad = love.graphics.newQuad(x * self.width - self.width, y * self.height - self.height,
					self.width, self.height, twidth, theight)

				if (self.indices[y]) then
					local index = self.indices[y]

					if (type(index) == "table") then
						index = index[x] or "unknown"
					end

					if (quads[index]) then
						if (type(quads[index]) == "table") then
							table.insert(quads[index], quad)
						else
							quads[index] = {quads[index], quad}
						end
					else
						quads[index] = quad
					end
				else
					table.insert(quads, quad)
				end
			end
		end

		return quads
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return spriter