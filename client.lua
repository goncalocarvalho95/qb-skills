local QBCore = exports['qb-core']:GetCoreObject()
local isLoggedIn = LocalPlayer.state.isLoggedIn

local function FetchSkills()
    QBCore.Functions.TriggerCallback("qb-skills:fetchStatus", function(data)
		if data then
            for status, value in pairs(data) do
                if Config.Skills[status] then
                    Config.Skills[status]["Current"] = value["Current"]
                else
                    print("Removing: " .. status)
                end
            end
		end
        RefreshSkills()
    end)
end

local function SkillMenu()
    local skills = {}

	for k, v in pairs(Config.Skills) do
		table.insert(skills, {
			["label"] = k .. ': <span style="color:yellow">' .. v["Current"] .. "</span> %"
		})
	end
end

local function GetCurrentSkill(skill)
    return Config.Skills[skill]
end

local function round(num) 
    return math.floor(num+.5) 
end

local function RefreshSkills()
    for k, value in pairs(Config.Skills) do
        if value["Stat"] then
            StatSetInt(value["Stat"], round(value["Current"]), true)
        end
        SkillMenu()
    end
end

local function UpdateSkill(skill, amount)
    if not Config.Skills[skill] then return end
    local SkillAmount = Config.Skills[skill]["Current"]
    if SkillAmount + tonumber(amount) <= 0 then
        Config.Skills[skill]["Current"] = 0
    elseif SkillAmount + tonumber(amount) >= 100 then
        Config.Skills[skill]["Current"] = 100
    else
        Config.Skills[skill]["Current"] = SkillAmount + tonumber(amount)
    end
    RefreshSkills()
    if tonumber(amount) > 0 then
        QBCore.Functions.Notify('+'..amount .. '% ' .. skill, 'success')
    end
	TriggerServerEvent("qb-skills:server:update", json.encode(Config.Skills))
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    FetchSkills()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

CreateThread(function()
	while true do
		local seconds = Config.UpdateFrequency * 1000
		Wait(seconds)
		for skill, value in pairs(Config.Skills) do
			UpdateSkill(skill, value["RemoveAmount"])
		end
		TriggerServerEvent("qb-skills:server:update", json.encode(Config.Skills))
	end
end)

CreateThread(function()
	while true do
		Wait(25000)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped)
		if IsPedRunning(ped) then
			UpdateSkill("Stamina", 0.2)
		elseif IsPedInMeleeCombat(ped) then
			UpdateSkill("Strength", 0.5)
		elseif IsPedSwimmingUnderWater(ped) then
			UpdateSkill("Lung Capacity", 0.5)
		elseif IsPedShooting(ped) then
			UpdateSkill("Shooting", 0.5)
		elseif DoesEntityExist(vehicle) then
			local speed = GetEntitySpeed(vehicle) * 3.6
			if GetVehicleClass(vehicle) == 8 or GetVehicleClass(vehicle) == 13 and speed >= 5 then
				local rotation = GetEntityRotation(vehicle)
				if IsControlPressed(0, 210) then
					if rotation.x >= 25.0 then
						UpdateSkill("Wheelie", 0.5)
					end 
				end
			end
			if speed >= 80 then
				UpdateSkill("Driving", 0.2)
			end
		end
	end
end)