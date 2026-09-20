RuralAnimals = { peds = {}, streams = {} }

local function removeListingPeds(listingKey)
    for animalId, entry in pairs(RuralAnimals.peds[listingKey] or {}) do
        if DoesEntityExist(entry.ped) then DeleteEntity(entry.ped) end
        RuralAnimals.peds[listingKey][animalId] = nil
    end
end

local function spawnAnimal(listingKey, animal)
    if RuralAnimals.peds[listingKey][animal.id] then return end
    local model = joaat(animal.model)
    RequestModel(model)
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(model) then return end
    local ped = CreatePed(28, model, animal.x, animal.y, animal.z, animal.heading or 0.0, false, false, 0, 0)
    if ped and ped ~= 0 then
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        RuralAnimals.peds[listingKey][animal.id] = { ped = ped }
    end
    SetModelAsNoLongerNeeded(model)
end

local function refreshStream(listingKey)
    local data = lib.callback.await('rural_system:server:getAnimalStream', false, listingKey)
    if not data then removeListingPeds(listingKey) return end
    RuralAnimals.peds[listingKey] = RuralAnimals.peds[listingKey] or {}
    local present = {}
    for _, animal in ipairs(data.animals or {}) do present[animal.id] = true; spawnAnimal(listingKey, animal) end
    for animalId, entry in pairs(RuralAnimals.peds[listingKey]) do
        if not present[animalId] then if DoesEntityExist(entry.ped) then DeleteEntity(entry.ped) end; RuralAnimals.peds[listingKey][animalId] = nil end
    end
end

function RuralAnimals.createPasturePoint(listing)
    if not listing.pasture or not listing.water then return end
    lib.points.new({ coords = vec3(listing.pasture.x, listing.pasture.y, listing.pasture.z), distance = Config.Animals.streamingRadius, listing = listing,
        nearby = function(point)
            if point.currentDistance < 2.0 then
                lib.showTextUI('[E] Alimentar os animais')
                if IsControlJustReleased(0, 0xCEFD9220) then TriggerServerEvent('rural_system:server:carePasture', listing.key, 'feed') end
            end
        end,
        onEnter = function() refreshStream(listing.key) end,
        onExit = function() lib.hideTextUI(); removeListingPeds(listing.key) end,
    })
    lib.points.new({ coords = vec3(listing.water.x, listing.water.y, listing.water.z), distance = 4.0, listing = listing,
        nearby = function(point)
            if point.currentDistance < 2.0 then
                lib.showTextUI('[E] Reabastecer o bebedouro')
                if IsControlJustReleased(0, 0xCEFD9220) then TriggerServerEvent('rural_system:server:carePasture', listing.key, 'water') end
            end
        end,
        onExit = function() lib.hideTextUI() end,
    })
end

CreateThread(function()
    while true do
        Wait(Config.Animals.streamingCheckMilliseconds)
        for listingKey in pairs(RuralAnimals.peds) do refreshStream(listingKey) end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for listingKey in pairs(RuralAnimals.peds) do removeListingPeds(listingKey) end
end)
