-- Name: Ark of Humanity
-- Description: Hunt Exuari,
--- Upgrade your fleet,
--- Rule the system,
--- You are the Fate of Humanity.
--- Alpha 240802
-- Type: Custom
-- Setting[Fleet]: Configures the fleet with which the players will hunt
-- Fleet[Ark|Default]: A small carrier and 8 small fighters.
--- One to two carrier officers.
--- A single pilot per fighter.
-- Setting[Fighter Pilots]: Should reflect the number of human fighter pilots available.
-- Fighter Pilots[0]: No fighter pilots available. 
-- Fighter Pilots[1]: One fighter pilot available. 
-- Fighter Pilots[2|Default]: Two fighter pilots available.
-- Fighter Pilots[3]: Three fighter pilots available.
-- Fighter Pilots[4]: Four fighter pilots available.
-- Fighter Pilots[5]: Five fighter pilots available.
-- Fighter Pilots[6]: Six fighter pilots available.
-- Fighter Pilots[7]: Seven fighter pilots available.
-- Fighter Pilots[8]: Eight fighter pilots available.

require("utils_carrier.lua")
require("SynSym/SynSymShipTools.lua")
require("SynSym/SynSymShipAI.lua")
require("SynSym/utils_timer.lua")
require("SynSym/SynSymShipLimits.lua")

local cheatFighterN = 9
local fighterPilots = tonumber(getScenarioSetting("Fighter Pilots"))
local rng = {
	r1a = -100000, r1b = 100000, -- determines the size of the 1st "circle"
	r2a = -200000, r2b = 200000, -- determines the size of the 2nd "circle"
	r3a = -300000, r3b = 300000, -- determines the size of the 3rd "circle"
	r4a = -400000, r4b = 400000, -- determines the size of the 4th "circle"
	r5a = -500000, r5b = 500000, -- determines the size of the 5th "circle"
	r6a = -600000, r6b = 600000, -- determines the size of the 6th "circle"
	r7a = -700000, r7b = 700000, -- determines the size of the 7th "circle"
	rNeb = 89, 	  rAst =89		-- the nebula, and astroid multipliers
}
local debugMode = "Off"
local storage = getScriptStorage()

--[[ < - - - - - - - Init - - - - - - - > ]]

function init() -- init is run when the scenario is started. Create your initial world.
	local debugCounter = storage:get("debug_counter")
	debugCounter = tonumber(debugCounter)
	print("< - - - - - - - " .. debugCounter .. " - - - - - - - >")
	debugCounter = debugCounter + 1
	storage:set("debug_counter", debugCounter)

 -- GM Button
	addGMFunction("Reset", function() setScenario("scenario_09_AoH.lua") end) -- resets scenario

 -- Blackhole
 	BlackHole():setPosition(0,0)

 -- init functions

	InitNebula()
	--print("InitNebula")
	InitAsteriod()
	--print("InitAsteriod")
	InitExuari()
	--print("InitExuari")
	InitNeutral()
	--print("InitNeutral")

	InitFleet()
	--print("InitFleet")

	InitUtilsCarrier()
	InitSynSymShipTools()
	InitSynSymShipAI()

	InitMission()
	if debugMode == true then print("< - - - - - - - function init() end - - - - - - - >") end
end

function InitNebula()
	local countNebula = 0
	for nebula_counter=1,rng.rNeb do
		Nebula():setPosition(random(rng.r1a, rng.r1b), random(rng.r1a, rng.r1b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*1.2) do
		Nebula():setPosition(random(rng.r2a, rng.r2b), random(rng.r2a, rng.r2b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*1.4) do
		Nebula():setPosition(random(rng.r3a, rng.r3b), random(rng.r3a, rng.r3b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*1.6) do
		Nebula():setPosition(random(rng.r4a, rng.r4b), random(rng.r4a, rng.r4b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*1.8) do
		Nebula():setPosition(random(rng.r5a, rng.r5b), random(rng.r5a, rng.r5b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*2) do
		Nebula():setPosition(random(rng.r6a, rng.r6b), random(rng.r6a, rng.r6b))
		countNebula = countNebula + 1
	end
	for nebula_counter=1,(rng.rNeb*2.2) do
		Nebula():setPosition(random(rng.r7a, rng.r7b), random(rng.r7a, rng.r7b))
		countNebula = countNebula + 1
	end
	if debugMode == true then print ("function initNebula()")
	print(" countNebula = " .. countNebula) end
end

function InitAsteriod()
	local countAstroid = 0
	for asteroid_counter=1,rng.rAst do
		local ast = Asteroid():setPosition(random(rng.r1a, rng.r1b), random(rng.r1a, rng.r1b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r1a, rng.r1b), random(rng.r1a, rng.r1b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*2) do
		local ast = Asteroid():setPosition(random(rng.r2a, rng.r2b), random(rng.r2a, rng.r2b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r2a, rng.r2b), random(rng.r2a, rng.r2b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*3) do
		local ast = Asteroid():setPosition(random(rng.r3a, rng.r3b), random(rng.r3a, rng.r3b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r3a, rng.r3b), random(rng.r3a, rng.r3b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*4) do
		local ast = Asteroid():setPosition(random(rng.r4a, rng.r4b), random(rng.r4a, rng.r4b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r4a, rng.r4b), random(rng.r4a, rng.r4b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*5) do
		local ast = Asteroid():setPosition(random(rng.r5a, rng.r5b), random(rng.r5a, rng.r5b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r5a, rng.r5b), random(rng.r5a, rng.r5b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*6) do
		local ast = Asteroid():setPosition(random(rng.r6a, rng.r6b), random(rng.r6a, rng.r6b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r6a, rng.r6b), random(rng.r6a, rng.r6b))
		countAstroid = countAstroid + 1
	end
	for asteroid_counter=1,(rng.rAst*7) do
		local ast = Asteroid():setPosition(random(rng.r7a, rng.r7b), random(rng.r7a, rng.r7b))
		ast.hasCarbon = true
		ast.hasIce = true
		VisualAsteroid():setPosition(random(rng.r7a, rng.r7b), random(rng.r7a, rng.r7b))
		countAstroid = countAstroid + 1
	end
	if debugMode == true then print ("function initAsteriod()")
	print(" countAstroid = " .. countAstroid) end -- This is both the number of real astroids and the number of visual astroids.
end

function InitExuari()
	for exuari_counter=1,random(7,14) do
		local rx = random(rng.r7a, rng.r7b)
		local ry = random(rng.r7a, rng.r7b)
		local mainShip = CpuShip():setTemplate("Guard"):setFaction("Exuari"):setPosition(rx, ry):orderFlyTowards(random(rng.r4a, rng.r4b),random(rng.r4a, rng.r4b))
		for exuarifighter_counter = 1, random ((fighterPilots*0),(fighterPilots*.5)) do
			local fighter = CpuShip():setTemplate("Adder MK7"):setFaction("Exuari"):setPosition(rx, ry):orderDefendTarget(mainShip)
			fighter:onDestroyed(function()
			SynSymShipTools.partsDrop(fighter, math.floor(random(1,10)))
			end)
		end
	end
	for exuari_counter=1,random(7,14) do
		local rx = random(rng.r6a, rng.r6b)
		local ry = random(rng.r6a, rng.r6b)
		local mainShip = CpuShip():setTemplate("Sentinel"):setFaction("Exuari"):setPosition(rx, ry):orderFlyTowards(random(rng.r4a, rng.r4b),random(rng.r4a, rng.r4b))
		for exuarifighter_counter = 1, random ((fighterPilots*.5),(fighterPilots*1)) do
			local fighter = CpuShip():setTemplate("Adder MK7"):setFaction("Exuari"):setPosition(rx, ry):orderDefendTarget(mainShip)
			fighter:onDestroyed(function()
				SynSymShipTools.partsDrop(fighter, math.floor(random(1,10)))
			end)
		end
	end
	for exuari_counter=1,random(7,14) do
		local rx = random(rng.r5a, rng.r5b)
		local ry = random(rng.r5a, rng.r5b)
		local mainShip = CpuShip():setTemplate("Warden"):setFaction("Exuari"):setPosition(rx,ry):orderFlyTowards(random(rng.r4a, rng.r4b),random(rng.r4a, rng.r4b))
		for exuarifighter_counter = 1, random ((fighterPilots*1),(fighterPilots*2)) do
			local fighter = CpuShip():setTemplate("Adder MK7"):setFaction("Exuari"):setPosition(rx, ry):orderDefendTarget(mainShip)
			fighter:onDestroyed(function()
				SynSymShipTools.partsDrop(fighter, math.floor(random(1,10)))
			end)
		end
	end
	if debugMode == true then print ("function initExuari()") end
end

function InitNeutral()
	ComSat = CpuShip():setTemplate("Small Station"):setFaction("Independent"):setPosition(-704000, 0):setCallSign("COMSAT"):setCanBeDestroyed(false)
	ComSat:setCommsFunction(ComSatComms)
	if debugMode == true then print ("function initNeutral()") end
end

function InitFleet()
	if getScenarioSetting("Fleet") == "Ark" then -- spawns the ark fleet.
		ArkFleet = {}
		ArkFleet.C1 = PlayerSpaceship():setTemplate("Kiriya"):setFaction("Human Navy") -- Ark Carrier
		
		--for i = 1, 8, 1 do
			--ArkFleet["D .. i"] = 1
		--end
		InitSetCarrier(ArkFleet.C1)
		ArkFleet.C1:setPosition(-700000,    0):setCallSign("Fate of Humanity"):setEnergyLevel(1500)
		InitFighters()
	end
end

function ArkFleet()

end

function InitFighters()
	for i = 1, 4, 1 do
		_ENV["F" .. i] = PlayerSpaceship():setTemplate("MP52 Hornet"):setFaction("Human Navy")
		--InitSetFighter(_ENV["F" .. i])
		InitSetHornet(_ENV["F" .. i])

	end
	for i = 5, 8, 1 do
		_ENV["F" .. i] = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy")
		--InitSetFighter(_ENV["F" .. i])
		InitSetLindworm(_ENV["F" .. i])
	end
	F1:setPosition(-699750, -500):setCallSign("Fate One		") InitSetFighter(F1)
	F2:setPosition(-699250, -250):setCallSign("Fate Two		") InitSetFighter(F2)
	F3:setPosition(-699250,  250):setCallSign("Fate Three	") InitSetFighter(F3)
	F4:setPosition(-699750,  500):setCallSign("Fate Four	") InitSetFighter(F4)
	F5:setPosition(-700250,  500):setCallSign("Fate Five	") InitSetFighter(F5)
	F6:setPosition(-700750,  250):setCallSign("Fate Six		") InitSetFighter(F6)
	F7:setPosition(-700750, -250):setCallSign("Fate Seven	") InitSetFighter(F7)
	F8:setPosition(-700250, -500):setCallSign("Fate Eight	") InitSetFighter(F8)
end

function InitUtilsCarrier()
	utils_carrier.init()
	utils_carrier.addCarrierType("Ark")
	utils_carrier.addFighterType("Ark Hornet")
	utils_carrier.addFighterType("Ark Lindworm")
	onNewPlayerShip(utils_carrier.onNewPlayerShip)
	utils_carrier.onNewPlayerShip(ArkFleet.C1)
 -- Debug Check
	if debugMode == true then print ("function initUtilsCarrier()") end
end

function InitSynSymShipTools()
	SynSymShipTools.installTool	(ArkFleet.C1, "ULRS", "debug")
	SynSymShipTools.installTool	(ArkFleet.C1, "station prefab", "shipyard")
	SynSymShipTools.installTool	(ArkFleet.C1, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(ArkFleet.C1, "Parts", 100)

	SynSymShipTools.installTool	(F1, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F1, "Parts", 10)

	SynSymShipTools.installTool	(F2, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F2, "Parts", 10)

	SynSymShipTools.installTool	(F3, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F3, "Parts", 10)

	SynSymShipTools.installTool	(F4, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F4, "Parts", 10)

	SynSymShipTools.installTool	(F5,"asteroid miner", "debug")
	SynSymShipTools.installTool	(F5, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F5, "Parts", 10)

	SynSymShipTools.installTool	(F6,"asteroid miner", "debug")
	SynSymShipTools.installTool	(F6, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F6, "Parts", 10)

	SynSymShipTools.installTool	(F7,"asteroid miner", "debug")
	SynSymShipTools.installTool	(F7, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F7, "Parts", 10)

	SynSymShipTools.installTool	(F8,"asteroid miner", "debug")
	SynSymShipTools.installTool	(F8, "cargo bay", "debug")
	SynSymShipTools.cargoLoad	(F8, "Parts", 10)
if debugMode == true then print ("function initSynSymShipTools()") end
end

function InitSynSymShipAI()
	SynSymShipAI.installAstroMech(ArkFleet.C1, "PM-C1")
	--SynSymShipAI.installAI(c1, "complete")
end

function InitMission()
--	comSat:sendCommsMessage(c1, [[You are one of few Arks sent out from a dying Earth to colonize the universe. Protect your carrier, and elimate those who would destroy it. You are the Fates of Humanity.]])
 -- Debug Check
	if debugMode == true then print ("function setMission()") end
end

function InitSetCarrier(ship)
 -- Identity
	ship:setTypeName("Ark")
	:setDescription(_("The Ark is a specialized version of the Kiriya, built for deep space colonization. The warp drive runs cool and efficient, but the Ark should not enter combat. System power management is automated, but doesn't work well in combat. You'll find additional controls in power management. Suggested crew: Tactical and Operations"))
 -- Radar
	ship:setLongRangeRadarRange(28000):setShortRangeRadarRange(7000)
 -- Engineer AI
	:setCanSelfDestruct(false)
	:setAutoCoolant(true)

	:setEnergyLevelMax(1500)
	:setSystemPowerFactor("reactor", -75) -- (-25 default)
	:setSystemHeatRate("warp", 0.06) --	setSystemPower
 -- Engine Tweaks :setAcceleration() (8,8) :setImpulseMaxSpeed() (60, 60)
	:setImpulseMaxSpeed(167,167)
	:setAcceleration(3,3)
	:setWarpSpeed(3010) -- (750) 3000 -> 900 
	:setCanCombatManeuver(false)
 -- Parts
	ship.cargoParts = 100
 -- Communication
 --	c1:setCommsFunction(carrierComms)
	if debugMode == true then print ("function initSetCarrier(ship)") end
end

function InitSetFighter(ship)
 -- Science Nerf
	ship:setCanHack(false):setCanLaunchProbe(false)
 -- Engineer AI
	:setCanSelfDestruct(false):setAutoCoolant(true):setEnergyLevelMax(400)
 -- Command
	print()
	ship:commandDock(ArkFleet.C1)
end

function InitSetHornet(ship)
 -- Identity
	ship:setTypeName("Ark Hornet"):setDescription(_("The Ark Hornet is a slightly modified version of MP52 Hornet. Fast and maneuverable, but not particularly powerful, this ship has a long range rader. It is best suited to scouting and close combat. Suggested crew: Single Pilot/ Power Management/ Science"))
 -- Ranges
	ship:setLongRangeRadarRange(16000):setShortRangeRadarRange(4000)
 -- Beams
	ship:setBeamWeapon(0, 45, 15, 1000.0, 4.0, 2.5):setBeamWeapon(1, 45, -15, 1000.0, 4.0, 2.5)--(index, arc, direction, range, cycle_time, damage)
 -- Tubes
	ship:setWeaponTubeCount	   (4		 ) -- (amount)
	ship:setWeaponStorage	   ("HVLI", 0) -- ({EMissileWeapons}, amount)
	ship:setWeaponStorageMax   ("HVLI", 3)
	ship:setTubeSize		   (0,"Small")
	ship:setTubeSize		   (1,"Small")
	ship:setTubeSize		   (2,"Small")
	ship:setWeaponTubeDirection(3,	  180)

	if debugMode == true then print ("initSetHornet(ship)") end
end

function InitSetLindworm(ship)
	ship:setHull(50):setShields(20)
	ship:setImpulseMaxSpeed(100,50)
 -- Identity
	ship:setTypeName("Ark Lindworm"):setDescription(_("The Ark Lindworm is a slightly modified version of the ZX-Lindworm. Focusing on fire power instead of speed, this ship is best suited for use as a long range bomber and miner. Suggested crew: Single Pilot/ Power Management"))
 -- Ranges
	ship:setLongRangeRadarRange(6000):setShortRangeRadarRange(6000)
 -- Tubes
	--Anti Default
	ship:setWeaponTubeCount(4) --(amount)
	ship:weaponTubeDisallowMissle(0, "Homing"):weaponTubeDisallowMissle(0, "Mine")
	ship:weaponTubeDisallowMissle(1, "HVLI")
	ship:weaponTubeDisallowMissle(2, "HVLI")
	ship:setWeaponStorageMax("HVLI", 0)
	ship:setWeaponStorage("HVLI", 0)
	--Tube 0
	ship:setWeaponStorageMax   ("Nuke",1):setWeaponStorageMax  ("EMP",1)
	ship:setWeaponStorage	   ("Nuke",0):setWeaponStorage	   ("EMP",0)
	ship:setWeaponTubeDirection(0,	   0)
	ship:weaponTubeAllowMissle (0,"Nuke"):weaponTubeAllowMissle(0,"EMP")
	--Tubes 1,2
	ship:setWeaponStorageMax("Homing",12)
	ship:setWeaponStorage	("Homing", 0)
	ship:setWeaponTubeDirection	  (1, 	   45):setWeaponTubeDirection   (2,     310)
	ship:setWeaponTubeExclusiveFor(1,"Homing"):setWeaponTubeExclusiveFor(2,"Homing")
	--Tube 3
	ship:setWeaponStorageMax("Mine",1)
	ship:setWeaponStorage("Mine", 0)
	ship:setTubeSize(3, "Large")
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:setWeaponTubeDirection(3, 180)

	if debugMode == true then print ("initSetLindworm(ship)") end
end

--[[ < - - - - - - - Update - - - - - - - > ]]
function update(delta)
	if ArkFleet.C1:isValid() == false then 
		victory("Exuari")
		print("BOOM!")
	else
	 -- [[SynSymShipTools]]--
		SynSymShipTools.update(ArkFleet.C1)
		SynSymShipTools.update(F1)
		SynSymShipTools.update(F2)
		SynSymShipTools.update(F3)
		SynSymShipTools.update(F4)
		SynSymShipTools.update(F5)
		SynSymShipTools.update(F6)
		SynSymShipTools.update(F7)
		SynSymShipTools.update(F8)

	 -- [[utils_carrier]]--
		utils_carrier.update(delta)

	 -- [[SynSymShipAI]]
		SynSymShipAI.astroMechMotherboard(ArkFleet.C1)
		--SynSymShipAI.run(c1)

	 -- [[SynSymShipLimits]]
		SynSymShipLimits.scanSystems(ArkFleet.C1)
		SynSymShipLimits.scanSystems(F1)
		SynSymShipLimits.scanSystems(F2)
		SynSymShipLimits.scanSystems(F3)
		SynSymShipLimits.scanSystems(F4)
		SynSymShipLimits.scanSystems(F5)
		SynSymShipLimits.scanSystems(F6)
		SynSymShipLimits.scanSystems(F7)
		SynSymShipLimits.scanSystems(F8)
	end
end

function ComSatComms()
	setCommsMessage("Communication Satellite Online.")
	addCommsReply("Data Bank", function()
		setCommsMessage("Data Bank")
		addCommsReply("Mission Information", function()
			setCommsMessage("You are one of few Arks sent out from a dying Earth to colonize the universe. Protect your carrier, and elimate those who would destroy it. You are the Fates of Humanity.")
			addCommsReply("Back", ComSatComms)
		end)
		addCommsReply("Fleet Information", function()
			setCommsMessage("The Ark has eight Ark fighters to protect it and perform the work nessesary to your mission.")
			addCommsReply("Ark", function()
				setCommsMessage(ArkFleet.C1:getDescription())
				addCommsReply("Back", ComSatComms)
			end)
			addCommsReply("Ark Hornet", function()
				setCommsMessage(F1:getDescription())
				addCommsReply("Back", ComSatComms)
			end)
			addCommsReply("Ark Lindworm", function()
				setCommsMessage(F5:getDescription())
				addCommsReply("Back", ComSatComms)
			end)
			addCommsReply("Back", ComSatComms)
		end)
		addCommsReply("Back", ComSatComms)
	end)
	addCommsReply("Cheats", function()
		setCommsMessage("These options will only be available until there are legitemate ways to do these things.")
		addCommsReply("Repair Carrier Hull", function()
			ArkFleet.C1:setHull(ArkFleet.C1:getHullMax())
			ComSatComms()
		end)
		addCommsReply("Restock Probes", function()
			ArkFleet.C1:setScanProbeCount(ArkFleet.C1:getMaxScanProbeCount())
			ComSatComms()
		end)
		addCommsReply("Spawn Fighter", function()
			setCommsMessage("Go find it.")
			addCommsReply("Back", ComSatComms)
			local r = random(0,1)
			local cheatFighter = PlayerSpaceship()
			if r >= .5 then
				cheatFighter:setTemplate("MP52 Hornet"):setFaction("Human Navy"):setTypeName("Ark Hornet")
				cheatFighter:setPosition(random(rng.r7a, rng.r7b), random(rng.r7a, rng.r7b)):setCallSign("Fate " .. cheatFighterN)
				InitSetFighter(cheatFighter)
				InitSetHornet(cheatFighter)
			end
			if r <= .5 then
				cheatFighter:setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setTypeName("Ark Lindworm")
				cheatFighter:setPosition(random(rng.r7a, rng.r7b), random(rng.r7a, rng.r7b)):setCallSign("Fate " .. cheatFighterN)
				InitSetFighter(cheatFighter)
				InitSetLindworm(cheatFighter)
				SynSymShipTools.installTool(cheatFighter,"asteroid miner")
			end
			cheatFighterN = cheatFighterN + 1

		end)
		addCommsReply("Refill Ammo", function()
			ArkFleet.C1:setWeaponStorage("Homing",	ArkFleet.C1:getWeaponStorageMax("Homing"))
			ArkFleet.C1:setWeaponStorage("Nuke"	,	ArkFleet.C1:getWeaponStorageMax("Mine"	))
			ArkFleet.C1:setWeaponStorage("Mine"	,	ArkFleet.C1:getWeaponStorageMax("Mine"	))
			ArkFleet.C1:setWeaponStorage("EMP"	,	ArkFleet.C1:getWeaponStorageMax("EMP"	))
			ArkFleet.C1:setWeaponStorage("HVLI"	,	ArkFleet.C1:getWeaponStorageMax("HVLI"	))
			ComSatComms()
		end)
		addCommsReply("Back", ComSatComms)
	end)
end

-- [[ SHIP YARD COMMS ]] --
function ShipYardOperator()
	addCommsReply("Patch me to the COMSAT", function()
		if ComSat:isValid() == true then
			ComSatComms()
		else
			setCommsMessage("Sorry, we're recieving no reply.")
			addCommsReply("Nevermind.", ShipYardOperator)
		end
	end)
	if comms_source:isDocked(comms_target) then
		setCommsMessage("Hello, " .. comms_source:getCallSign() .. "\nWelcome to Fate Shipyard. Who'd you like to speak to?")
		addCommsReply("The lab please.", ShipYardLab)
	else
		setCommsMessage("Hello, " .. comms_source:getCallSign() .. "\nFate Shipyard reads you.")
		addCommsReply("The lab please.", function()
			setCommsMessage("You'll need to dock first.")
			addCommsReply("Should be docked now.", ShipYardOperator)
		end)
	end
end

function ShipYardLab()
	setCommsMessage("Shipyard lab here. What can we do for you?")
	addCommsReply("Please make me some coolant.", function()
		if comms_source.cargoIce ~= nil and comms_source.cargoCarbon ~= nil then
			if comms_source.cargoIce >= 57 and comms_source.cargoCarbon >= 2 then
				setCommsMessage("Nessesary materials confirmed. How much do you want?")
				addCommsReply("As much as you can make, please.", function()
					repeat
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + .5)
						comms_source.cargoIce = comms_source.cargoIce - 57
						comms_source.cargoCarbon = comms_source.cargoCarbon - 2
					until comms_source.cargoIce < 57 or comms_source.cargoCarbon < 2
				end)
			else
				setCommsMessage("Sorry, we'll need at least 57 liters of Ice and 2 liters of carbon.")
				addCommsReply("Nevermind.",	ShipYardLab)
			end
		else
			setCommsMessage("Looks like you're not set up to hold the nessesary materials.")
			addCommsReply("Nevermind.",	ShipYardLab)
		end
	end)
	addCommsReply("Get me the operator.", ShipYardOperator)
end
