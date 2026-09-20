AnimalService = {}

local function getListing(key)
    for _, listing in ipairs(Config.RanchListings) do if listing.key == key then return listing end end
end

local function randomSpawn(pasture, animalId)
    local angle = (animalId * 137.508) % 360
    local radius = math.min(tonumber(pasture.radius) * 0.65, 12.0)
    return { x = tonumber(pasture.x) + math.cos(math.rad(angle)) * radius, y = tonumber(pasture.y) + math.sin(math.rad(angle)) * radius, z = tonumber(pasture.z) }
end

function AnimalService.initializeRanch(ranchId, listingKey, ownerCharacterId)
    local listing = getListing(listingKey)
    if not listing or not listing.pasture or not listing.water then return false, 'Listagem sem infraestrutura animal.' end
    local pastureId = MySQL.insert.await([[INSERT INTO ranch_pastures (ranch_id, name, x, y, z, radius, capacity)
        VALUES (?, 'Pasto principal', ?, ?, ?, ?, ?)]], { ranchId, listing.pasture.x, listing.pasture.y, listing.pasture.z, listing.pasture.radius, listing.pasture.capacity })
    if not pastureId then return false, 'Não foi possível criar o pasto.' end
    local waterId = MySQL.insert.await([[INSERT INTO ranch_water_sources (ranch_id, pasture_id, x, y, z, capacity, current_amount)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], { ranchId, pastureId, listing.water.x, listing.water.y, listing.water.z, listing.water.capacity, listing.water.capacity })
    if not waterId then return false, 'Não foi possível criar a fonte de água.' end
    for item, quantity in pairs(Config.Animals.starterSupplies) do
        MySQL.insert.await('INSERT INTO ranch_inventory (ranch_id, item_key, quantity) VALUES (?, ?, ?)', { ranchId, item, quantity })
    end
    for _, animal in ipairs(Config.Animals.initialAnimals[listingKey] or {}) do
        AnimalService.createAnimal(ranchId, pastureId, animal)
    end
    RuralAudit.write(ranchId, ownerCharacterId, 'animals.ranch_initialize', 'pasture', pastureId, { waterId = waterId })
    return true
end

function AnimalService.createAnimal(ranchId, pastureId, definition)
    local species = Config.AnimalSpecies[definition.species]
    if not species then return false, 'Espécie inválida.' end
    if not RuralUtils.contains(species.allowedSexes, definition.sex) then return false, 'Sexo inválido para a espécie.' end
    local breed = definition.breed and Config.AnimalBreeds[definition.breed]
    if breed and breed.species ~= definition.species then return false, 'Raça incompatível com a espécie.' end
    local pasture = AnimalRepository.getPastureByRanch(ranchId)
    if not pasture or tonumber(pasture.id) ~= tonumber(pastureId) then return false, 'Pasto inválido.' end
    if AnimalRepository.countAnimalsByPasture(pastureId) >= tonumber(pasture.capacity) then return false, 'O pasto atingiu sua capacidade.' end
    local weight = tonumber(definition.weight) or species.matureWeight * 0.35
    if weight <= 0 or weight > species.matureWeight * 1.5 then return false, 'Peso inválido.' end
    local firstId = MySQL.insert.await([[INSERT INTO ranch_animals (ranch_id, pasture_id, species_key, breed_key, sex, name, born_at, weight, genetics_json, x, y, z)
        VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?)]], { ranchId, pastureId, definition.species, definition.breed, definition.sex, RuralUtils.trim(definition.name) or species.label, weight, json.encode((breed and breed.genetics) or {}), pasture.x, pasture.y, pasture.z })
    if not firstId then return false, 'Não foi possível registrar o animal.' end
    local spawn = randomSpawn(pasture, firstId)
    MySQL.update.await('UPDATE ranch_animals SET x = ?, y = ?, z = ? WHERE id = ?', { spawn.x, spawn.y, spawn.z, firstId })
    RuralAudit.write(ranchId, nil, 'animal.create', 'animal', firstId, { species = definition.species, breed = definition.breed })
    return true, firstId
end

function AnimalService.getStreamData(characterId, listingKey)
    local ranch = RanchRepository.findByListingKey(listingKey)
    if not ranch or not RanchService.hasPermission(characterId, ranch.id, 'animals.view') then return nil end
    local pasture = AnimalRepository.getPastureByRanch(ranch.id)
    if not pasture then return nil end
    local animals = AnimalRepository.getAnimalsByRanch(ranch.id)
    local visible = {}
    for index, animal in ipairs(animals) do
        if index > Config.Animals.maxVisiblePerPasture then break end
        local species = Config.AnimalSpecies[animal.species_key]
        if species then visible[#visible + 1] = { id = animal.id, model = species.model, x = tonumber(animal.x), y = tonumber(animal.y), z = tonumber(animal.z), heading = (tonumber(animal.id) * 43) % 360 } end
    end
    return { ranchId = ranch.id, pasture = pasture, animals = visible }
end

function AnimalService.carePasture(source, listingKey, careType)
    local listing = getListing(listingKey)
    if not listing or (careType ~= 'feed' and careType ~= 'water') then return false, 'Ação inválida.' end
    local player, err = RuralVorp.getCharacter(source)
    if not player then return false, err end
    local ranch = RanchRepository.findByListingKey(listingKey)
    if not ranch or not RanchService.hasPermission(player.id, ranch.id, 'animals.manage') then return false, 'Sem permissão para cuidar dos animais.' end
    local point = careType == 'feed' and listing.pasture or listing.water
    if not RuralSecurity.near(source, point, Config.ActionDistance) then return false, 'Aproxime-se da estação correta.' end
    AnimalSimulation.runRanch(ranch.id)
    local animals = AnimalRepository.getAnimalsByRanch(ranch.id)
    if #animals == 0 then return false, 'Não há animais nesta propriedade.' end
    local itemKey, amount = careType == 'feed' and 'hay' or 'water', careType == 'feed' and Config.Animals.feedAmountPerAnimal * #animals or Config.Animals.waterAmountPerAnimal * #animals
    if careType == 'feed' then
        local updated = MySQL.update.await('UPDATE ranch_inventory SET quantity = quantity - ? WHERE ranch_id = ? AND item_key = ? AND quantity >= ?', { amount, ranch.id, itemKey, amount })
        if updated ~= 1 then return false, 'Não há feno suficiente no armazém.' end
        MySQL.update.await('UPDATE ranch_animals SET hunger = GREATEST(0, hunger - 30), happiness = LEAST(100, happiness + 4), version = version + 1 WHERE ranch_id = ? AND state = ?', { ranch.id, 'pasture' })
    else
        local water = AnimalRepository.getWaterByRanch(ranch.id)
        if not water then return false, 'Fonte de água não encontrada.' end
        local updated = MySQL.update.await('UPDATE ranch_water_sources SET current_amount = current_amount - ? WHERE id = ? AND current_amount >= ?', { amount, water.id, amount })
        if updated ~= 1 then return false, 'Não há água suficiente no bebedouro.' end
        MySQL.update.await('UPDATE ranch_animals SET thirst = GREATEST(0, thirst - 35), happiness = LEAST(100, happiness + 3), version = version + 1 WHERE ranch_id = ? AND state = ?', { ranch.id, 'pasture' })
    end
    MySQL.insert.await('INSERT INTO ranch_animal_care_log (ranch_id, actor_character_id, action_type, item_key, quantity) VALUES (?, ?, ?, ?, ?)', { ranch.id, player.id, careType, itemKey, amount })
    RuralAudit.write(ranch.id, player.id, 'animal.care.' .. careType, 'pasture', AnimalRepository.getPastureByRanch(ranch.id).id, { quantity = amount })
    return true, amount
end

AddEventHandler('rural_system:server:ranchCreated', function(ranchId, listingKey, ownerCharacterId)
    local ok, err = AnimalService.initializeRanch(ranchId, listingKey, ownerCharacterId)
    if not ok then print(('[rural_system] Falha ao inicializar animais do rancho %s: %s'):format(ranchId, err)) end
end)
