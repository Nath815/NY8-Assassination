ESX = nil
local missionStarted = false
local targetPed = nil
local guardPeds = {}
local missionBlip = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end

    RequestModel(Config.MissionGiver.model)
    while not HasModelLoaded(Config.MissionGiver.model) do Wait(1) end

    local ped = CreatePed(4, Config.MissionGiver.model, Config.MissionGiver.coords.x, Config.MissionGiver.coords.y, Config.MissionGiver.coords.z - 1.0, Config.MissionGiver.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = "start_assassination",
            icon = "fas fa-skull",
            label = "Mission Assassinat",
            onSelect = function()
                if missionStarted then
                    ESX.ShowNotification("Tu es déjà en mission.")
                else
                    TriggerServerEvent("assassination:startMission")
                end
            end
        }
    })
end)

RegisterNetEvent("assassination:spawnTargets", function(location)
    if missionStarted then return end
    missionStarted = true

    local pedModel = "s_m_y_blackops_01"
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(1) end

    -- Cible
    targetPed = CreatePed(4, pedModel, location.x, location.y, location.z, 0.0, true, true)
    SetEntityAsMissionEntity(targetPed, true, true)
    GiveWeaponToPed(targetPed, `weapon_pistol`, 100, true)
    TaskCombatHatedTargetsAroundPed(targetPed, 50.0)
    SetPedAsEnemy(targetPed, true)

    -- Garde x3
    for i = 1, 3 do
        local guard = CreatePed(4, pedModel, location.x + math.random(-4,4), location.y + math.random(-4,4), location.z, 0.0, true, true)
        SetEntityAsMissionEntity(guard, true, true)
        GiveWeaponToPed(guard, `weapon_smg`, 150, true)
        TaskCombatHatedTargetsAroundPed(guard, 50.0)
        SetPedAsEnemy(guard, true)
        table.insert(guardPeds, guard)
    end

    -- Blip
    missionBlip = AddBlipForEntity(targetPed)
    SetBlipColour(missionBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Cible à éliminer")
    EndTextCommandSetBlipName(missionBlip)

    -- Check mort
    CreateThread(function()
        while missionStarted do
            Wait(1000)
            if DoesEntityExist(targetPed) and IsEntityDead(targetPed) then
                TriggerServerEvent("assassination:giveReward", GetEntityCoords(targetPed))
                RemoveBlip(missionBlip)
                missionStarted = false
                break
            end
        end
    end)
end)

RegisterNetEvent("assassination:spawnBriefcase", function(coords)
    local prop = CreateObject(`prop_ld_case_01`, coords.x, coords.y, coords.z, true, true, true)
    PlaceObjectOnGroundProperly(prop)
    SetEntityAsMissionEntity(prop, true, true)

    exports.ox_target:addLocalEntity(prop, {
        {
            name = "pickup_briefcase",
            icon = "fas fa-suitcase",
            label = "Ramasser la mallette",
            onSelect = function()
                TriggerServerEvent("assassination:rewardPlayer")
                DeleteEntity(prop)
            end
        }
    })
end)

--------------------
--SRIPT DE NY8 DEV--
-------------------- 