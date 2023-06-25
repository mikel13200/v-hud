-- if GetResourceState("qb-core") == "started" then
--     QBCore = exports["qb-core"]:GetCoreObject()
-- elseif GetResourceState("es_extended") == "started" then
--     ESX = exports["es_extended"]:getSharedObject()
-- end

loaded = false

local function loadHud()
    SendNUIMessage({
        displayUI = true
    })
    CreateThread(function()
        while loaded do
            local oldHealth = 0
            local oldArmour = 0
            local ped = PlayerPedId()
            local hp = GetEntityHealth(ped)
            local armour = GetPedArmour(ped)
            local talking = NetworkIsPlayerTalking(PlayerId())
            -- print("Looping Through"..hp.." Armor"..armour)
            if hp ~= oldHealth or armour ~= oldArmour then
                SendNUIMessage({
                    action = 'update',
                    health = hp,
                    armour = armour,
                    talking = talking
                })
                oldHealth = hp
                oldArmour = armour
                Wait(1000)
            end
        end
    end)
end

local function loadCarHud()
    CreateThread(function()
        while loaded do
            local ped = PlayerPedId()
            local isInVehicle = IsPedInAnyVehicle(ped, false)
            Wait(1000)
            if isInVehicle then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local fuel = GetVehicleFuelLevel(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                local speed = GetEntitySpeed(vehicle) * 2.237
                SendNUIMessage({
                    action = 'showUI',
                })
                SendNUIMessage({
                    action = 'updateVeh',
                    speed = speed,
                    fuel = fuel,
                    gear = gear,
                })
                Wait(0)
            else
                SendNUIMessage({
                    action = 'hideUI',
                })
            end
        end
    end)
end


-- QB MultiCharacter Fix
if GetResourceState("qb-core") == "started" then
    QBCore = exports["qb-core"]:GetCoreObject()
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        Wait(2000)
        -- local hudSettings = GetResourceKvpString('hudSettings')
        -- if hudSettings then loadSettings(json.decode(hudSettings)) end
        -- PlayerData = QBCore.Functions.GetPlayerData()
        loaded = true
        loadHud()
        loadCarHud()
        -- print("Done")
        Wait(3000)
        SetEntityHealth(PlayerPedId(), 200)
    end)
else
    loaded = true
    loadHud()
    loadCarHud()
end

RegisterCommand("loadUI", function()
    loaded = true
    loadHud()
    loadCarHud()
end)