ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("assassination:startMission")
AddEventHandler("assassination:startMission", function()
    local src = source
    local randomLocation = Config.TargetLocations[math.random(1, #Config.TargetLocations)]
    TriggerClientEvent("assassination:spawnTargets", src, randomLocation)
end)

RegisterServerEvent("assassination:giveReward")
AddEventHandler("assassination:giveReward", function(coords)
    TriggerClientEvent("assassination:spawnBriefcase", source, coords)
end)

RegisterServerEvent("assassination:rewardPlayer")
AddEventHandler("assassination:rewardPlayer", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('money', Config.MissionReward)
end)

--------------------
--SRIPT DE NY8 DEV--
-------------------- 