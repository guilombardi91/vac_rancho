AnimalSimulation = {}

local function decodeGenetics(value)
    if type(value) == 'table' then return value end
    local ok, decoded = pcall(json.decode, value or '{}')
    return ok and type(decoded) == 'table' and decoded or {}
end

local function geneticValue(seed, key)
    local number = 0
    for index = 1, #key do number = number + key:byte(index) * index end
    return ((seed * 9301 + number * 49297) % 233280) / 233280
end

local function inheritGenetics(motherJson, fatherJson, seed)
    local mother, father, result = decodeGenetics(motherJson), decodeGenetics(fatherJson), {}
    for key, value in pairs(mother) do result[key] = value end
    for key in pairs(father) do
        local maternal, paternal = tonumber(mother[key]) or 50, tonumber(father[key]) or 50
        local variation = (geneticValue(seed, key) * 2 - 1) * Config.Breeding.mutationRange
        result[key] = RuralUtils.clamp(math.floor((maternal + paternal) / 2 + variation + 0.5), 1, 100)
    end
    return result
end

local function applyDiseases(ranchId, animal, intervals)
    local active = AnimalRepository.getActiveDiseases(animal.id)
    local healthLoss = 0
    for _, diagnosis in ipairs(active) do
        local disease = Config.Veterinary.diseases[diagnosis.disease_key]
        if disease then healthLoss = healthLoss + disease.healthLossPerInterval * intervals end
    end
    for key, disease in pairs(Config.Veterinary.diseases) do
        local thresholdReached = (disease.hungerThreshold and tonumber(animal.hunger) >= disease.hungerThreshold) or (disease.thirstThreshold and tonumber(animal.thirst) >= disease.thirstThreshold)
        if thresholdReached or (disease.baseChance > 0 and geneticValue(tonumber(animal.id) + os.time() // Config.Animals.simulationIntervalSeconds, key) < disease.baseChance * intervals) then
            AnimalRepository.createDisease(ranchId, animal.id, key, 35)
        end
    end
    return healthLoss
end

function AnimalSimulation.runRanch(ranchId)
    local ranch = RanchService.getRanch(ranchId)
    if not ranch then return false end
    local now = os.time()
    local last = tonumber(MySQL.scalar.await('SELECT UNIX_TIMESTAMP(last_simulated_at) FROM ranches WHERE id = ?', { ranch.id })) or now
    local elapsed = math.min(math.max(0, now - last), Config.Animals.maxCatchUpSeconds)
    local intervals = math.floor(elapsed / Config.Animals.simulationIntervalSeconds)
    if intervals < 1 then return false end
    local pasture = AnimalRepository.getPastureByRanch(ranch.id)
    if not pasture then return false end
    local population = AnimalRepository.countAnimalsByPasture(pasture.id)
    local overcrowding = math.max(0, population - tonumber(pasture.capacity))
    for _, animal in ipairs(AnimalRepository.getAnimalsByRanch(ranch.id)) do
        local species = Config.AnimalSpecies[animal.species_key]
        if species then
            local hunger = RuralUtils.clamp(tonumber(animal.hunger) + species.foodPerInterval * intervals * 4, 0, 100)
            local thirst = RuralUtils.clamp(tonumber(animal.thirst) + species.waterPerInterval * intervals * 4, 0, 100)
            local stress = RuralUtils.clamp(tonumber(animal.stress) + overcrowding * intervals * 0.8 + math.max(0, hunger - 70) * 0.04 * intervals, 0, 100)
            animal.hunger, animal.thirst = hunger, thirst
            local diseaseLoss = applyDiseases(ranch.id, animal, intervals)
            local healthLoss = math.max(0, hunger - 75) * 0.025 * intervals + math.max(0, thirst - 75) * 0.035 * intervals + overcrowding * 0.15 * intervals + diseaseLoss
            local health = RuralUtils.clamp(tonumber(animal.health) - healthLoss, 0, 100)
            local happiness = RuralUtils.clamp(tonumber(animal.happiness) - (hunger + thirst) * 0.012 * intervals - overcrowding * 0.3 * intervals, 0, 100)
            local state = health <= 0 and 'dead' or animal.state
            MySQL.update.await([[UPDATE ranch_animals SET hunger = ?, thirst = ?, stress = ?, health = ?, happiness = ?, state = ?,
                last_simulated_at = CURRENT_TIMESTAMP, version = version + 1 WHERE id = ?]], { hunger, thirst, stress, health, happiness, state, animal.id })
            if state == 'dead' then RuralAudit.write(ranch.id, nil, 'animal.died', 'animal', animal.id, { hunger = hunger, thirst = thirst }) end
        end
    end
    MySQL.update.await('UPDATE ranches SET last_simulated_at = CURRENT_TIMESTAMP WHERE id = ?', { ranch.id })
    RuralCache.invalidateRanch(ranch.id)
    return true
end

CreateThread(function()
    while true do
        Wait(Config.Animals.simulationIntervalSeconds * 1000)
        local ranches = MySQL.query.await("SELECT id FROM ranches WHERE status IN ('active', 'leased') AND last_simulated_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL 15 MINUTE)")
        for _, ranch in ipairs(ranches or {}) do AnimalSimulation.runRanch(ranch.id) end
    end
end)

local function startPregnancies()
    local ranches = MySQL.query.await("SELECT id FROM ranches WHERE status IN ('active', 'leased')")
    for _, ranch in ipairs(ranches or {}) do
        local pasture = AnimalRepository.getPastureByRanch(ranch.id)
        if pasture then
            for femaleSpecies, pair in pairs(Config.Breeding.speciesPairs) do
                local mothers = AnimalRepository.getBreedingCandidates(ranch.id, pasture.id, femaleSpecies, 'female', Config.AnimalSpecies[femaleSpecies].growthDays)
                local fathers = AnimalRepository.getBreedingCandidates(ranch.id, pasture.id, pair.maleSpecies, 'male', Config.AnimalSpecies[pair.maleSpecies].growthDays)
                if #fathers > 0 then
                    for _, mother in ipairs(mothers) do
                        local existing = MySQL.scalar.await("SELECT id FROM ranch_breeding WHERE mother_animal_id = ? AND state = 'pregnant' LIMIT 1", { mother.id })
                        if not existing and geneticValue(tonumber(mother.id) + os.time() // Config.Breeding.checkIntervalSeconds, 'conception') > 0.72 then
                            local father = fathers[((tonumber(mother.id) - 1) % #fathers) + 1]
                            local seed = (tonumber(mother.id) * 65537 + tonumber(father.id) * 7919 + os.time() // Config.Breeding.checkIntervalSeconds) % 2147483647
                            local id = MySQL.insert.await([[INSERT INTO ranch_breeding (ranch_id, mother_animal_id, father_animal_id, due_at, genetics_seed)
                                VALUES (?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY), ?)]], { ranch.id, mother.id, father.id, pair.gestationDays, seed })
                            if id then RuralAudit.write(ranch.id, nil, 'animal.pregnancy', 'breeding', id, { mother = mother.id, father = father.id }) end
                        end
                    end
                end
            end
        end
    end
end

local function processBirths()
    for _, breeding in ipairs(AnimalRepository.getDueBreedings() or {}) do
        local pair = Config.Breeding.speciesPairs[breeding.mother_species]
        if pair and breeding.pasture_id then
            local female = geneticValue(tonumber(breeding.genetics_seed), 'sex') >= 0.5
            local species = female and pair.offspringFemaleSpecies or pair.offspringMaleSpecies
            local genetics = inheritGenetics(breeding.mother_genetics, breeding.father_genetics, tonumber(breeding.genetics_seed))
            local breed = female and breeding.mother_breed or breeding.father_breed
            if not Config.AnimalBreeds[breed] or Config.AnimalBreeds[breed].species ~= species then breed = nil end
            local ok, animalId = AnimalService.createAnimal(breeding.ranch_id, breeding.pasture_id, { species = species, breed = breed, sex = female and 'female' or 'male', name = 'Filhote', genetics = genetics })
            if ok then
                MySQL.update.await("UPDATE ranch_breeding SET state = 'born', offspring_animal_id = ?, completed_at = UTC_TIMESTAMP() WHERE id = ? AND state = 'pregnant'", { animalId, breeding.id })
                RuralAudit.write(breeding.ranch_id, nil, 'animal.born', 'animal', animalId, { breedingId = breeding.id })
                TriggerEvent('rural:animalBorn', breeding.ranch_id, animalId, breeding.id)
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(Config.Breeding.checkIntervalSeconds * 1000)
        startPregnancies()
        processBirths()
    end
end)
