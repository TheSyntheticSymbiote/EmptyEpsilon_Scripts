--[[
Name: utils.timer

Version: 240802

Author: SynSym

Description:
Times events

Instructions:
Call    require ("utils_timer.lua")                               	   before all functions.
Call    utils_timer.inTimeDo(timer name, time(in seconds), function()) to function() after the seconds have elapsed.
Call    utils_timer.update(delta) in function update(delta) 		   so that the timers tick.
]]

local P = {}
utils_timer = P
timers = {}
local repeaters = {}

function P.repeater(name, interval, callback)
	repeaters[name] = {tick = 0.0, interval = interval, callback = callback}
end

function P.timer(name, interval, callback)
	timers[name] 	= {tick = 0.0, interval = interval, callback = callback}
end

function P.update(delta)
	for name, timer in pairs(timers) do 	-- for each timer by name,
		
		if timer.tick < timer.interval then -- if the timer is less then the interval,
		
			timers[name].tick = timer.tick + delta -- move the timer forward for the next iteration.
		else								-- if the timer is larger then the interval,
			timer.callback()				-- run the callback.
			timers[name] = nil				-- causes the timer to repeat.
		end
	end
	for name, repeater in pairs(repeaters) do 	  -- for each timer by name,
		if repeater.tick < repeater.interval then -- if the timer is less then the interval,
			repeater.tick = repeater.tick + delta -- move the timer forward for the next iteration.
		else									  -- if the timer is larger then the interval,
			repeater.callback()					  -- run the callback.
			repeater.tick = 0.0					  -- causes the timer to repeat.
		end
	end
end