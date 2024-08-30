--[[
Name: SynSymShipLimits

Version: 240809

Author: SynSym

Description:
Additional ship limitations

Instructions:
require, call
]]--

require ("utils_customElements.lua")
require ("SynSym/SynSymShipScanners.lua")

local P = {}
SynSymShipLimits = P

local system_list = {"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"}
local system_names = {
	["reactor"] = "Reactor", 
	["beamweapons"] = "Beam Weapons", 
	["missilesystem"] = "Missile System", 
	["maneuver"] = "Maneuvering", 
	["impulse"] = "Impulse Engines", 
	["warp"] = "Warp Drive", 
	["jumpdrive"] = "Jump Drive", 
	["frontshield"] = "Front Shield G...", 
	["rearshield"] = "Rear Shield G..."}
local threshold_list = {0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0}
local beans = false

function P.scanSystems(ship)
	--print("scanning")
	for i, system in ipairs (system_list) do
		--print(system)
		local dSD = SynSymShipScanners.getDeltaSystemDamage(ship, system)
		--print(
			--ship:getCallSign() .. " " .. 
			--system .. " " .. 
			--dSD
		--)
		--print(dSD)
		if dSD < 0 then
			P.limitRepair(ship, system)
		end
	end
	P.repairButtons(ship)
end

function P.limitRepair(ship, system)
	for j, threshold in ipairs(threshold_list) do
		if ship:getSystemHealth(system) <= threshold and
		ship:getSystemHealthMax(system) > threshold then
			ship:setSystemHealthMax(system, threshold)
		end
	end
end
-- c1:setSystemHealthMax("beamweapons", 1) (use to repair to desired level)

function P.repairButtons(ship)
	for i, sys in ipairs(system_list) do
		if ship:hasSystem(sys) then
			ship:addCustomButton( "DamageControl", "repair" .. system_names[sys], "Repair " .. system_names[sys], function()
				P.repairButtonAction(ship, sys)
			end, i)
		end
	end
end

function P.repairButtonAction(ship, sys)
	if ship.cargoParts >= 1 and 
	ship:getSystemHealthMax(sys) < 1 then
		ship.cargoParts = ship.cargoParts - 1
		ship:setSystemHealthMax(sys, ship:getSystemHealthMax(sys) + .1)
		print("Parts: " .. ship.cargoParts)
	end
end