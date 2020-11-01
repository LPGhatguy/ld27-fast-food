--[[
Framework Unit Testing
Performs unit testing on parts of the engine
]]

local lib
local unit

unit = {
	test = function(self)
		local out = {}

		for name, test in next, self.tests do
			table.insert(out, "SUITE START\t" .. name:upper())
			table.insert(out, self:report_suite(name))
		end

		return table.concat(out, "\n")
	end,

	report_suite = function(self, suite_name)
		return self:generate_report(self:run_suite(suite_name))
	end,

	generate_report = function(self, out)
		local report = {}
		local success = lib.utility.table_pop(out)
		local test_count = 0
		local success_count = 0

		for name, result in next, out do
			test_count = test_count + 1
			if (result) then
				success_count = success_count + 1
			end

			table.insert(report, "\tTEST\t" .. name:upper() .. ":\t" .. (result and "SUCCESS" or "FAIL"))
		end

		table.insert(report, (success and "SUITE SUCCESS" or "SUITE FAIL") .. success_count .. "/" .. test_count)

		return table.concat(report, "\n")
	end,

	run_suite = function(self, suite_name)
		local suite = self.tests[suite_name]
		local out = {}

		if (suite) then
			local test_start = lib.utility.table_pop(suite, "start")
			local test_end = lib.utility.table_pop(suite, "end")

			if (test_start) then
				test_start()
			end

			for name, test in next, suite do
				out[name] = self:run_test(test)
			end

			out[1] = not lib.utility.table_contains(out, false)

			if (test_end) then
				test_end()
			end

			return out
		else
			return false
		end
	end,

	evaluate = function(self, test_component)
		if (test_component) then
			local safe_component = {unpack(test_component)}
			local first = safe_component[1]

			if (type(first) == "function") then
				lib.utility.table_pop(safe_component)
				local result = {pcall(first, unpack(safe_component))}

				if (lib.utility.table_pop(result)) then --checks for call success and removes it from the result table
					return result
				else
					return false
				end
			else
				return safe_component
			end
		else
			return false
		end
	end,

	run_test = function(self, test)
		local first = self:evaluate(test[1])
		local second = self:evaluate(test[2])

		if (first and second) then
			return lib.utility.table_equals(first, second)
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		local utility = lib.utility

		self.tests = {
			utility = {
				["string split single"] = {{utility.string_split, "a,b,c", ","}, {{"a", "b", "c"}}},
				["string split multi"] = {{utility.string_split, "XasdYasdZ", "asd"}, {{"X", "Y", "Z"}}},
				["table contains"] = {{utility.table_contains, {1, 2, 3}, 3}, {true}},
				["table not contains"] = {{utility.table_contains, {1, 2, 3}, 4}, {false}},
				["table equals"] = {{utility.table_equals, {1, 2, 3}, {1, 2, 3}}, {true}},
				["table not equals"] = {{utility.table_equals, {1, 2, 3}, {3, 2, 1}}, {false}},
				["table pop"] = {{utility.table_pop, {1, 2, 3}}, {1, {2, 3}}},
				["table pop numeric"] = {{utility.table_pop, {1, 2, 3}, 2}, {2, {1, 3}}},
				["table pop string"] = {{utility.table_pop, {a = 1, b = 2, c = 3}, "a"}, {1, {b = 2, c = 3}}},
				["table deep copy"] = {{utility.table_deepcopy, {1, 2, 3}}, {{1, 2, 3}}},
				["table deep copy to"] = {{utility.table_deepcopy, {1, 2, 3}, {4, 5, 6}}, {{1, 2, 3, 4, 5, 6}}},
				["table copy"] = {{utility.table_copy, {1, 2, 3}}, {{1, 2, 3}}},
				["table merge"] = {{utility.table_merge, {3, 3, 3, 4, 5}, {1, 2, 3}}, {{1, 2, 3, 4, 5}}},
				["table deep merge"] = {{utility.table_deepmerge, {3, 3, 3, 4, 5}, {1, 2, 3}}, {{1, 2, 3, 4, 5}}},
				["table size numeric"] = {{utility.table_size, {1, 2, 3}}, {3}},
				["table size hash"] = {{utility.table_size, {a = 1, b = 2, c = 3}}, {3}}
			}
		}
	end
}

return unit