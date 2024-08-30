--[[Syn's Engineering AI
Version: 240802

Author: SynSym

Description:
Automated Engineering

Instructions:
Call require ("utils_synsEngineeringAI.lua") before all functions.
Call utils_synsEngineeringAI.update(ship) in update(delta), once per effected ship.

In order to make any given systemAI available in a given ship, 
call utils_synsEngineeringAI.installAI(ship, ESystem AI). 
Setting AI to "complete" will install AI for every Esystem present on the ship when it is called.
Setting AI to "alert" will install the alert AI.
Setting AI to "sheild" will install the shield AI.
Setting AI to "debug" results in all nine systems being installed. 
The AI for a system that isn't present will still be allowed to be installed.
]]

--require("utils_customElements.lua")

local P = {}
SynSymShipAI = P
local xSwitchPosition = "PowerManagement"
local AIversion = 1
local system_list = {
	"reactor",
	"beamweapons",
	"missilesystem",
	"maneuver",
	"impulse",
	"warp",
	"jumpdrive",
	"frontshield",
	"rearshield"
}
local system_overheat = {
	reactor = nil,
	beamweapons = nil,
	missilesystem = nil,
	maneuver = nil,
	impulse = nil,
	warp = nil,
	jumpdrive = nil,
	frontshield = nil,
	rearshield = nil
}

function P.installAstroMech(ship, astromech)
	ship.astroMech = {}
	if astromech == "PM-C1" then
		ship.astroMech["model"] = "PM-C1"
	else
		print("Invalid AstroMech: " .. ship:getCallSign() .. " - " .. astromech)
	end
	P.configureAstroMech(ship)
end

function P.configureAstroMech(ship)
 -- Download
	local model = ship.astroMech.model
	--print(model)
 -- Configure
	if model == "PM-C1" then
		ship.astroMech["station"] = "PowerManagement"
	end
	P.astroMechSensors(ship)
	P.astroMechComputer(ship)
	ship.astroMech["greeting"] = false 
	P.astroMechUI(ship)
end

function P.astroMechMotherboard(ship)
	P.astroMechSensors(ship)
	P.astroMechComputer(ship)
	P.astroMechUI(ship)
end

--[[ Sensors ]]

function P.astroMechSensors(ship)
 -- Download
	local station = ship.astroMech.station 
	--print(station)
	local oldEnergyLevel = ship.astroMech.oldEnergyLevel 
	--print(oldEnergyLevel)
	
 -- Scan
	if station == "PowerManagement" then
		ship.astroMech["energyLevel"] = ship:getEnergyLevel()
		ship.astroMech["energyLevelMax"] = ship:getEnergyLevelMax()
		P.astroMechEnergyCalculator(ship)

		ship.astroMech["coolantMax"] = ship:getMaxCoolant()

		P.astroMechSystemSensorArray(ship)
		P.astroMechHeatCalculator(ship)
	end
end

function P.astroMechEnergyCalculator(ship)
	local energyLevel = ship.astroMech.energyLevel
	local oldEnergyLevel = ship.astroMech.oldEnergyLevel
	--print(energyLevel)
	if oldEnergyLevel ~= nil then
		ship.astroMech["energyDelta"] = (energyLevel - oldEnergyLevel)*60
	end
	ship.astroMech["oldEnergyLevel"] = energyLevel
end

function P.astroMechSystemSensorArray(ship)
	ship.astroMech.systemPower = {}
	ship.astroMech.systemCoolant = {}
	ship.astroMech.systemHeat = {}
	for i, system in ipairs(system_list) do
		ship.astroMech.systemPower[system] = ship:getSystemPower(system)
		ship.astroMech.systemCoolant[system] = ship:getSystemCoolant(system)
		ship.astroMech.systemHeat[system] = ship:getSystemHeat(system)
	end
end

function P.astroMechHeatCalculator(ship)
	local reactorHeat = ship.astroMech.systemHeat.reactor
	local beamweaponsHeat = ship.astroMech.systemHeat.beamweapons
	local missilesystemHeat = ship.astroMech.systemHeat.missilesystem
	local maneuverHeat = ship.astroMech.systemHeat.maneuver
	local impulseHeat = ship.astroMech.systemHeat.impulse
	local warpHeat = ship.astroMech.systemHeat.warp
	local jumpdriveHeat = ship.astroMech.systemHeat.jumpdrive
	local frontshieldHeat = ship.astroMech.systemHeat.frontshield
	local rearshieldHeat = ship.astroMech.systemHeat.rearshield
	
--Heat Management
 
	if reactorHeat ~= nil and
	beamweaponsHeat	~= nil and
	missilesystemHeat ~= nil and
	maneuverHeat ~= nil and
	impulseHeat ~= nil and
	warpHeat ~= nil and
	jumpdriveHeat ~= nil and
	frontshieldHeat ~= nil and
	rearshieldHeat ~= nil then

	--Hottest System
		local hottestHeat = 0
		local hottestSystem = nil
		for i, system in ipairs(system_list) do
			if ship.astroMech.systemHeat[system] > hottestHeat then
				hottestHeat = ship.astroMech.systemHeat[system]
				hottestSystem = system
			end
		end
		ship.astroMech["hottestSystem"] = hottestSystem
		ship.astroMech["hottestHeat"] = hottestHeat
		--print(ship.astroMech.hottestSystem) print(ship.astroMech.hottestHeat)
	
	--Average Heat
		local numberOfSystems = 0
		for i, system in ipairs(system_list) do
			if ship:hasSystem(system) == true then
				numberOfSystems = numberOfSystems + 1
			end
		end
		local averageHeat = (reactorHeat + beamweaponsHeat + missilesystemHeat +
							maneuverHeat + impulseHeat + warpHeat + jumpdriveHeat +
							frontshieldHeat + rearshieldHeat) / numberOfSystems
		ship.astroMech["averageHeat"] = averageHeat

	--System Overheat
		for i, system in ipairs(system_list) do
			if ship.astroMech.systemHeat[system] > .9 then
				ship.astroMech.systemOverheat[system] = true
			end
		end
	end
end

--[[ Computer ]]

function P.astroMechComputer(ship)
--Download
	local energyLevel = ship.astroMech.energyLevel
	local energyLevelMax = ship.astroMech.energyLevelMax

	local reactorHeat = ship.astroMech.systemHeat.reactor
	local beamweaponsHeat = ship.astroMech.systemHeat.beamweapons
	local missilesystemHeat = ship.astroMech.systemHeat.missilesystem
	local maneuverHeat = ship.astroMech.systemHeat.maneuver
	local impulseHeat = ship.astroMech.systemHeat.impulse
	local warpHeat = ship.astroMech.systemHeat.warp
	local jumpdriveHeat = ship.astroMech.systemHeat.jumpdrive
	local frontshieldHeat = ship.astroMech.systemHeat.frontshield
	local rearshieldHeat = ship.astroMech.systemHeat.rearshield
	local averageHeat = ship.astroMech.averageHeat

--Sanity Check
	local sanityMax = 3
	if energyLevel <= 100 then
		sanityMax = .5
	end
	if averageHeat > .5 then
		sanityMax = .5
	end

--Reactor
	local reactorMax = 3
	print(reactorMax)
	local reactorMin = .3
	print(reactorMin)
	print(reactorHeat)
	print(warpHeat)
	--breaks after reactor heats up, fixes once reactor cools down

	if reactorHeat < .9 and warpHeat < .9 then
		if energyLevel <= 100 then
			reactorMin = 2
		end
	else
		reactorMax = .3
	end
	if reactorHeat >= 1 then
		reactorMax = 0
		reactorMin = 0
	end

 -- Beam Weapons
	local beamweaponsMax = sanityMax
	local beamweaponsMin = .3
	if beamweaponsHeat > .9 or warpHeat > .9 then
		beamweaponsMax = .3
	end
	if beamweaponsHeat >= 1 then
		beamweaponsMax = 0
		beamweaponsMin = 0
	end

 -- Missile System
	local missilesystemMax = sanityMax
	local missilesystemMin = .3
	if missilesystemHeat > .9 or warpHeat > .9 then
		missilesystemMax = .3
	end
	if missilesystemHeat >= 1 then
		missilesystemMax = 0
		missilesystemMin = 0
	end

 -- Maneuvering
 	local maneuverMax = sanityMax
 	local maneuverMin = .3
	if maneuverHeat > .9 or warpHeat > .9 then
		maneuverMax = .3
	end
	if maneuverHeat >= 1 then
		maneuverMax = 0
		maneuverMin = 0
	end

 -- Impulse
 	local impulseMax = sanityMax
 	local impulseMin = .3
	if impulseHeat > .9 or warpHeat > .9 then
		impulseMax = .3
	end
	if impulseHeat >= 1 then
		impulseMax = 0
		impulseMin = 0
	end

 -- Warp Drive
	local warpMax = sanityMax
	local warpMin = .3
	if warpHeat > .8 then
		warpMax = 1
		warpMin = .3
		system_overheat.warp = true
		if warpHeat > .9 then
			warpMax = .3
			warpMin = .3
		end
	end
	if warpHeat >= 1 then
		warpMax = 0
		warpMin = 0
	end
	if system_overheat.warp == true and
	warpHeat < .5 and
	ship.astroMech.systemPower.warp < 1 then
		warpMin = 1
		system_overheat.warp = false
	end

 -- Jump Drive
 	local jumpdriveMax = sanityMax
	local jumpdriveMin = .4
	if jumpdriveHeat > .9 or warpHeat > .9 then
		jumpdriveMax = .3
	end
	if jumpdriveHeat >= 1 then
		jumpdriveMax = 0
		jumpdriveMin = 0
	end

 -- Front Shield Generator
 	local frontshieldMax = sanityMax
 	local frontshieldMin = .3
	if frontshieldHeat > .9 or warpHeat > .9 then
		frontshieldMax = .3
	end
	if frontshieldHeat > 1 then
		frontshieldMax = 0
		frontshieldMin = 0
	end

 -- Rear Shield Generator
 	local rearshieldMax = sanityMax
 	local rearshieldMin = .3
	if rearshieldHeat > .9 or warpHeat > .9 then
		rearshieldMax = .3
	end
	if rearshieldHeat > 1 then
		rearshieldMax = 0
		rearshieldMin = 0
	end

 -- Upload
	ship.astroMech.power_max = {
		["reactor"		] = reactorMax,
		["beamweapons"	] = beamweaponsMax,
		["missilesystem"] = missilesystemMax,
		["maneuver"		] = maneuverMax,
		["impulse"		] = impulseMax,
		["warp"			] = warpMax,
		["jumpdrive"	] = jumpdriveMax,
		["frontshield"	] = frontshieldMax,
		["rearshield"	] = rearshieldMax
	}
	ship.astroMech.power_min = {
		["reactor"		] = reactorMin,
		["beamweapons"	] = beamweaponsMin,
		["missilesystem"] = missilesystemMin,
		["maneuver"		] = maneuverMin,
		["impulse"		] = impulseMin,
		["warp"			] = warpMin,
		["jumpdrive"	] = jumpdriveMin,
		["frontshield"	] = frontshieldMin,
		["rearshield"	] = rearshieldMin
	}
	P.astroMechActuator(ship)
end

function P.astroMechActuator(ship)	
 -- Download
	local max = ship.astroMech.power_max
	local min = ship.astroMech.power_min

 -- Act
	if ship.astroMech.greeting == true then
		for i, system in pairs(system_list) do
			if ship:hasSystem(system) then
				if ship:getSystemPower(system) > max[system] then
					ship:commandSetSystemPowerRequest(system, max[system])
				end
				if ship:getSystemPower(system) < min[system] then
					ship:commandSetSystemPowerRequest(system, min[system])
				end
			end
		end
	end
end

--[[ UI ]]

function P.astroMechUI(ship)
 -- Greeting
	if ship.astroMech.greeting == false then
		ship:addCustomMessageWithCallback(
			ship.astroMech.station, 
			"AstroMechGreeting", 
			"Hello, I'm the ship astromech, model " .. ship. astroMech.model .. ". I'll be trying to: \n - prevent system meltdown by lowering power when nessesary, \n - prevent ship shutdown by raising reactor power if energy goes critical, and \n - prevent distraction by keeping all systems at a minimum of 30%. \nOtherwise, the station is yours. I'll get started once you've closed this message.", 
			function() ship.astroMech.greeting = true
		end)
	end
 -- Switches
	--ship:addCustomButton(ship.astroMech.station, "AstroMech", )
end