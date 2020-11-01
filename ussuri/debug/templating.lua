--[[
Lua Templating Library
Assists in templating and mimicing of objects
THIS IS A CONCEPT IMPLEMENTATION‼
]]

local lib
local templating

local do_nothing = function()
end

templating = {
	compare = {
		type_match = function(object_type)
			return function(object)
				return type(object) == object_type
			end
		end
	},

	construct = {
		member = function(type, ...)
			return {["``"] = type, ...}
		end,

		all = function(...)
			local collection = {...}

			return {["``"] = "member",
				do_nothing,
				function(check)
					for key, value in next, collection do
						if (type(value) == "function") then
							if (not value(check)) then
								return false
							end
						elseif (type(value) == "table" and value["``"]) then
							if (not value[2](check)) then
								return false
							end
						else
							if (value ~= check) then
								return false
							end
						end
					end

					return true
				end
			}
		end,

		any = function(...)
			local collection = {...}

			return {["``"] = "member",
				do_nothing,
				function(check)
					for key, value in next, collection do
						if (type(value) == "function") then
							if (value(check)) then
								return true
							end
						elseif (type(value) == "table" and value["``"]) then
							if (value[2](check)) then
								return true
							end
						else
							if (value == check) then
								return true
							end
						end
					end

					return false
				end
			}
		end,

		type_any = function(...)
			local types = {...}

			return {["``"] = "member",
				do_nothing,
				function(check)
					for key, value in next, types do
						if (type(check) == value) then
							return true
						end
					end

					return false
				end
			}
		end,

		range = function(from, to)
			local from = from or -math.huge
			local to = to or math.huge

			return {["``"] = "member",
				function()
					return math.random(from, to)
				end,
				function(check)
					return (check >= from) and (check <= to)
				end
			}
		end,

		set = function(...)
			local items = {...}

			return {["``"] = "member",
				function()
					return items[math.random(1, #items)]
				end,
				function(check)
					return lib.utility.table_contains(items, check)
				end
			}
		end,

		boolean = function()
			return {["``"] = "member",
				function()
					return (math.random(0, 1) == 1)
				end,
				function(check)
					return (check == true) or (check == false)
				end
			}
		end,

		increment = function(value, by, max)
			local value = value or 0
			local by = by or 1
			local max = max or math.huge

			return {["``"] = "member",
				function()
					value = value + by

					if (value > max) then
						value = max
					end

					return value
				end,
				--I wonder if it's worth implementing this
				do_nothing
			}
		end,
	},

	verify_object = function(self, object, template, result)
		local result = result or {}

		for key, value in pairs(template) do
			if (type(value) == "table") then
				if (value["``"]) then
					local about = value["``"]

					if (about == "member") then
						local equiv = object[key]

						if (equiv) then
							local check = value[2]

							result[key] = check(equiv)
						else
							result[key] = false
						end
					end
				end
			else
				result[key] = (value == object[key])
			end
		end

		return result
	end,

	solidify_template = function(self, template)
		local out = {}

		for key, value in pairs(template) do
			if (type(value) == "table") then
				if (value["``"]) then
					local about = value["``"]

					if (about == "method") then
						out[key] = function()
							local serve = {}

							for key = 1, #value do
								local object = value[key]

								if (type(object) == "table") then
									if (object["``"] == "member") then
										table.insert(serve, object[1](out, select(3, unpack(value))))
									else
										return object
									end
								else
									return object
								end
							end

							return unpack(serve)
						end
					end
				else
					out[key] = self:solidify_template(value)
				end
			else
				out[key] = value
			end
		end

		return out
	end,

	construct_fabricant = function(self, template)
		local object = self:solidify_template(template)

		lib.oop:objectify(object)

		return object
	end,

	init = function(self, engine)
		lib = engine.lib
	end
}

return templating