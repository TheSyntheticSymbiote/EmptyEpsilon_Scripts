--[[
Name: utils.synsShipTools

Version: 240802

Author: SynSym

Description:
Base functionality for all of Syn's Tools.

Instructions:
Call require ("utils.synsShipTools.lua") before all functions.
Equip tools with utils_synsShipTools.installTool(ship,"tool", "version"). Versions: "debug" 
Call utils_synsShipTools.update(ship) in update(delta).
If an asteroid is to be mined, one or more of the following must be the case:
	asteriod.hasIce = true
	asteriod.hasCarbon true
SynSymShipTools.partsDrop(ship, amount)

Tools:
"none"
"asteroid miner"
"ULRS"

]]--

require ("utils_customElements.lua")
require ("utils.lua")

local P = {}
SynSymShipTools = P

function P.installTool(ship,tool,version)
	if tool == "asteroid miner" then
		ship.tAM = true
	end
	if tool == "ULRS" then
		ship.tULRS = true
		--print("ULRS Installed")
	end
	if tool == "station prefab" then
		ship.tSP = true
		ship.cargoStationprefab = 1
	end
	if tool == "cargo bay" then
		ship.tCB = true
	end
	P.versionConfig(ship,tool,version)
end

function P.uninstallTool(ship,tool,version)
	if tool == "asteroid miner" then
		ship.tAM = nil
		ship.tAMRange = nil
		ship.tAMSpeed = nil
		ship.tAMDrain = nil
		ship.cargoCarbon = nil
		ship.cargoIce = nil
		ship.tAMOutput = nil
		ship:removeCustom("infoTAMOutput1")
		ship:removeCustom("infoTAMOutput2")
	end
	if tool == "ULRS" then
		ship.tULRS = nil
		ship.tULRSRange = nil
		ship.tULRSDrain = nil
		ship.tULRSWobble = nil
		ship.tULRSOutput2 = nil
		ship:removeCustom("ULRS")
		ship:removeCustom("infoTULRSOutput1")
	end
	if tool == "station prefab" then
		ship.tSP = false
		ship.cargoStationprefab = nil
	end
	if tool == "cargo bay" then
		ship.tCB = false
	end
	
end

function P.versionConfig(ship,tool,version)
	if tool == "asteroid miner" then
		if version == "debug" then
			ship.tAMRange = 500 
			ship.tAMSpeed = 1
			ship.tAMDrain = 1
			ship.cargoCarbon = 0
			ship.cargoIce = 0
			ship.tAMOutput = "Asteriod Miner Equiped"
			ship.beans = nil
		end
	end
	if tool == "ULRS" then
		if version == "debug" then
			ship.tULRSRange = 200*1000
			ship.tULRSDrain = 1100 --(add 1 for every unit of range, and 10 for every .01 of Wobble under 1)
			ship.tULRSWobble = .1 --(0-1, where 0 is not accurate at all, and 1 is perfectly accurate)
			ship.tULRSOutput2 = "ULRS"
			--print("ULRS Configured")
		end
	end
	if tool == "station prefab" then
		if version == "debug" then
			tSPconfigStatus = "version set"
		end
	end
	if tool == "cargo bay" then
		if version == "debug" then
			ship.cargoMax = 10000
			ship.cargoTotal = 0
			ship.tCBOutput = "Cargo Bay Equiped"
			ship.cargoIce = 0
			ship.cargoCarbon = 0
			ship.cargoParts = 0 
		end
	end
	
end

function P.update(ship)
STupdateStatus = "tAM"
	if ship.tAM == true then -- if the ship has a mining tool...
		customElements:addCustomInfo(ship, "Helms", "infoTAMOutput1", ship.tAMOutput, 0)
		if ship.beans == nil then ship.beans = getScenarioTime() + 1 end -- fires every 1 second
		if getScenarioTime() > ship.beans then ship.beans = nil
			for j, object in ipairs(ship:getObjectsInRange(ship.tAMRange)) do -- for each nearby object...
				if object.typeName == "Asteroid" then -- if that object is an asteroid...
					ship.tAMOutput = "Asteriod Miner Active"
					object:setSize(object:getSize() - ship.tAMSpeed) 		-- shrink the asteriod...
					ship:setEnergy(ship:getEnergy() - ship.tAMDrain) 		-- reduce the energy in the ship...
					if object.hasCarbon == true then
						carbonDensity = 2.26
						P.cargoLoad(ship, "Carbon", ship.tAMSpeed*carbonDensity)
						object:setSize(object:getSize() - ship.tAMSpeed*carbonDensity) 	-- shrink the asteriod...
						ship:setEnergy(ship:getEnergy() - ship.tAMDrain) 					-- reduce the energy in the ship...
					end
					if object.hasIce == true then
						iceDensity = 0.91
						P.cargoLoad(ship, "Ice", ship.tAMSpeed*iceDensity)
						object:setSize(object:getSize() - ship.tAMSpeed*iceDensity) 	-- shrink the asteriod...
						ship:setEnergy(ship:getEnergy() - ship.tAMDrain) 				-- reduce the energy in the ship...
					end
					if object:getSize() < 1 then 
						object:destroy()
					end
				else
					ship.tAMOutput = "Asteriod Miner Scanning"
				end
			end
		end
	end
STupdateStatus = "tULRS"
	if ship.tULRS == true then
	ULRSStatus = ("Energy Sensor")
		if ship:getEnergyLevel() >= ship.tULRSDrain then
			ship.tULRSOutput1 = "ULRS Ready"
		else
			ship.tULRSOutput1 = "Insufficient Energy"
		end
		ULRSStatus = ("Switch")
		customElements:addCustomButton(ship, "Science", "ULRS", ship.tULRSOutput1, function() 
			ULRSASStatus = ("Power Supply")
			if ship:getEnergyLevel() >= ship.tULRSDrain then
				ship:setEnergyLevel(ship:getEnergyLevel() - ship.tULRSDrain)
				ULRSASStatus = ("Radar")
				-- utils_getclosestObject(focal point, minRange, maxRange, function() end)
				for i, object in ipairs(ship:getObjectsInRange(ship.tULRSRange)) do
					if 	object.typeName == "CpuShip" or 
						object.typeName == "PlayerSpaceship" or
						object.typeName == "SpaceStation" then
						local d = distance(ship, object)
						if d > ship:getShortRangeRadarRange() then
							local closestDist = ship.tULRSRange
							if d < closestDist then
								closestDist = distance(ship, object)
								closestObje = object
							end
						end
					end
				end
				ULRSASStatus = ("Computer")
					-- ship.toolOutput = distance(ship, object) .. " " .. angleHeading(ship, object)
				if closestObje ~= nil then
				ULRSASStatus = ("Exact Location")
					local closestHead = angleHeading(ship, closestObje)
					x,y = closestObje:getPosition() 
					ULRSASStatus = ("Nebula Interfereance")
					for i, object in ipairs(closestObje:getObjectsInRange(5000)) do
						if object.typeName == "Nebula" then
							x,y = object:getPosition()
							xOffset,yOffset = vectorFromAngle(random(0,360),random (0,5000))
							x = x + xOffset
							y = y + yOffset
							break
						end
					end
					ULRSASStatus = ("Stablizer")
					xWobble,yWobble = vectorFromAngle(random(0,360), random (0,ship:getLongRangeRadarRange()*ship.tULRSWobble))
					x = x + xWobble
					y = y + yWobble
					displayBearing = math.floor(angleHeading(ship, x, y))
					displayHeading = math.floor(distance(ship, x, y)*
												random (1-ship.tULRSWobble, 1+ship.tULRSWobble) /10)/100
					--displaySector = x,y:getSectorName()
					ULRSASStatus = ("Display")
					ship.tULRSOutput2 = "Ping: " .. displayBearing .. "° " .. displayHeading .. "U " --.. displaySector
				else
					ship.tULRSOutput2 = "No Pings"
				end
			end
			ULRSASStatus = ("Switch Online")
		end,1)
		customElements:addCustomInfo(ship, "Science", "infoTULRSOutput1", ship.tULRSOutput2, 0)
	end
STupdateStatus = "tSP"
	if ship.tSP == true then
		ship:addCustomInfo("Operations", "iSP", "Deployable Stations: " .. ship.cargoStationprefab, 10)
		ship:addCustomButton("Operations", "bSP", "Deploy Station", function()
			if ship.cargoStationprefab > 0 then
				local x1, y1 = ship:getPosition() 
				local x2, y2 = vectorFromAngle(ship:getHeading(), 1000, true)
				local x3 = x1 + x2 local y3 = y1 + y2
				fsShipyard = SpaceStation():setTemplate("Small Station"):setFaction(ship:getFaction()):setPosition(x3,y3):setCallSign("Fate Shipyard")
				fsShipyard:setCommsFunction(ShipYardOperator)
				ship.cargoStationprefab = ship.cargoStationprefab - 1
			end
		end,11)
	end
STupdateStatus = "tCB"
	if ship.tCB == true then
		-- Display
		ship.tCBOutput = "Cargo"
		if ship.cargoCarbon > 0 then
			ship.tCBOutput = ship.tCBOutput .. " C:" .. math.floor(ship.cargoCarbon)
		end
		if ship.cargoIce > 0 then
			ship.tCBOutput = ship.tCBOutput .. " Ice:" .. math.floor(ship.cargoIce)
		end
		if ship.cargoParts > 0 then
			ship.tCBOutput = ship.tCBOutput .. " Parts:" .. math.floor(ship.cargoParts)
		end
		customElements:addCustomInfo(ship, "Weapons", "infoTCBOutput", ship.tCBOutput, 1)
		-- Buttons
		customElements:addCustomButton(ship, "Weapons", "unloadCargo", "Unload All", function()
			if ship.cargoTotal > 0 then
				P.cargoUnload(ship, "Ice", ship.cargoIce)
				P.cargoUnload(ship, "Carbon", ship.cargoCarbon)
				P.cargoUnload(ship, "Parts", ship.cargoParts)
			end
		end, 2)
	end
STupdateStatus = "Success"	
end

function P.cargoLoad(ship, cargo, amount)
	if ship.tCB == true then
		if ship.cargoTotal + amount <= ship.cargoMax then
			if cargo == "Ice" then
				if ship.cargoIce == nil then
					ship.cargoIce = 0
				end
				ship.cargoIce = ship.cargoIce + amount
				ship.cargoTotal = ship.cargoTotal + amount
			else
				if cargo == "Carbon" then
					if ship.cargoCarbon == nil then
						ship.cargoCarbon = 0
					end
					ship.cargoCarbon = ship.cargoCarbon + amount
					ship.cargoTotal = ship.cargoTotal + amount
				else
					if cargo == "Parts" then
						if ship.cargoParts == nil then
							ship.cargoParts = 0
						end
						ship.cargoParts = ship.cargoParts + amount
						ship.cargoTotal = ship.cargoTotal + amount
					else
						print("cargo not recognized")
					end
				end	
			end	
		end
	else
		print(ship:getCallSign() .. " has no cargo bay.")
	end
	--SynSymShipTools.cargoLoad(c1, "Ice", 1)
end

function P.cargoUnload(ship, cargo, amount)
	if ship.tCB == true then
		if cargo == "Ice" then
			if ship.cargoIce == nil then
				ship.cargoIce = 0
			end
			if ship.cargoIce >= amount then
				ship.cargoIce = ship.cargoIce - amount
				if ship:getDockingState() == 2 then
					local dock = ship:getDockedWith()
					if dock.cargoIce == nil then
						dock.cargoIce = 0
					end
					dock.cargoIce = dock.cargoIce + amount
				else
					-- determine drop location
					local x1, y1 = ship:getPosition()
					local x2, y2 = vectorFromAngle(ship:getHeading(), 1000, true)
					local x3 = x1 + x2 local y3 = y1 + y2
					-- determine drop atributes
					local drop = Artifact():setCallSign(cargo .. " " .. amount):setFaction(ship:getFaction()):setPosition(x3,y3)
					--drop:setModel("various/debris-blob")
					drop:allowPickup(true)
					drop:onPickUp(function(artifact, player)
						string.format("")
						player.cargoIce = player.cargoIce + amount
						artifact:destroy()
					end)
				end
			end
		else
			if cargo == "Carbon" then
				if ship.cargoCarbon == nil then
					ship.cargoCarbon = 0
				end
				if ship.cargoCarbon >= amount then
					ship.cargoCarbon = ship.cargoCarbon - amount
					if ship:getDockingState() == 2 then
						local dock = ship:getDockedWith()
						if dock.cargoCarbon == nil then
							dock.cargoCarbon = 0
						end
						dock.cargoCarbon = dock.cargoCarbon + amount
					else
						-- determine drop location
						local x1, y1 = ship:getPosition()
						local x2, y2 = vectorFromAngle(ship:getHeading(), 1000, true)
						local x3 = x1 + x2 local y3 = y1 + y2
						-- determine drop atributes
						local drop = Artifact():setCallSign(cargo .. " " .. amount):setFaction(ship:getFaction()):setPosition(x3,y3)
						--drop:setModel("various/debris-blob")
						drop:allowPickup(true)
						drop:onPickUp(function(artifact, player)
							string.format("")
							
							player.cargoCarbon = player.cargoCarbon + amount
							
							artifact:destroy()
						end)
					end
				end
			else
				if cargo == "Parts" then
					if ship.cargoParts == nil then
						ship.cargoParts = 0
					end
					if ship.cargoParts >= amount then
						ship.cargoParts = ship.cargoParts - amount
						if ship:getDockingState() == 2 then
							local dock = ship:getDockedWith()
							if dock.cargoParts == nil then
								dock.cargoParts = 0
							end
							dock.cargoParts = dock.cargoParts + amount
						else
							-- determine drop location
							local x1, y1 = ship:getPosition()
							local x2, y2 = vectorFromAngle(ship:getHeading(), 1000, true)
							local x3 = x1 + x2 local y3 = y1 + y2
							-- determine drop atributes
							local drop = Artifact():setCallSign(cargo .. " " .. amount):setFaction(ship:getFaction()):setPosition(x3,y3)
							--drop:setModel("various/debris-blob")
							drop:allowPickup(true)
							drop:onPickUp(function(artifact, player)
								string.format("")
								
								player.cargoParts = player.cargoParts + amount
								
								artifact:destroy()
							end)
						end
					end
				else
					print("cargo not recognized")
				end
			end
		end
	else
		print(ship:getCallSign() .. " has no cargo bay.")
	end
	--SynSymShipTools.cargoUnload(c1, "Ice", 1)
end

function P.cargoConsume(ship, cargo, amount)
	if ship.tCB == true then
		if cargo == "Ice" then
			ship.cargoIce = ship.cargoIce - amount
		end
		if cargo == "Carbon" then
			ship.cargoCarbon = ship.cargoCarbon - amount
		end
		if cargo == "Parts" then
			ship.cargoParts = ship.cargoParts - amount
		end 
	end
end

function P.partsDrop(ship, amount)
	local x1, y1 = ship:getPosition()
	local x2, y2 = vectorFromAngle(ship:getHeading(), 0, true)
	local x3 = x1 + x2 local y3 = y1 + y2
	-- determine drop atributes
	local drop = Artifact():setCallSign("Parts " .. amount):setFaction("Human Navy"):setPosition(x3,y3)
	--drop:setModel("various/debris-blob")
	drop:allowPickup(true)
	drop:onPickUp(function(artifact, player)
		string.format("")
		player.cargoParts = player.cargoParts + amount
		artifact:destroy()
	end)
end