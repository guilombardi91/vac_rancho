AnimalSimulation = {}

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
            local healthLoss = math.max(0, hunger - 75) * 0.025 * intervals + math.max(0, thirst - 75) * 0.035 * intervals + overcrowding * 0.15 * intervals
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
