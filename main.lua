--[[
:Fast :Food

Lucien Greathouse
Cassie Scheirer
"The Cocomotives"

Written in 72 hours for
Ludum Dare 27
8/23/2013 - 8/25/2013
]]

local ussuri = require("ussuri")

ussuri.start = function(engine, args)
	local lib = ussuri.lib

	local tsr = ussuri:lib_load("tsr")
	local game = tsr.game

	ussuri.event:event_hook_object(game)
	ussuri.event:event_hook_object(lib.debug.monitor)
end