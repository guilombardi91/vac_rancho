AnimalRepository = {}

function AnimalRepository.getPastureByRanch(ranchId)
    return MySQL.single.await('SELECT * FROM ranch_pastures WHERE ranch_id = ? ORDER BY id LIMIT 1', { ranchId })
end

function AnimalRepository.getWaterByRanch(ranchId)
    return MySQL.single.await('SELECT * FROM ranch_water_sources WHERE ranch_id = ? ORDER BY id LIMIT 1', { ranchId })
end

function AnimalRepository.getAnimalsByRanch(ranchId)
    return MySQL.query.await([[SELECT id, ranch_id, pasture_id, species_key, breed_key, sex, name, born_at, weight, health, hunger, thirst,
        happiness, stress, hygiene, quality, genetics_json, state, x, y, z, last_simulated_at FROM ranch_animals
        WHERE ranch_id = ? AND state NOT IN ('dead', 'sold') ORDER BY id]], { ranchId })
end

function AnimalRepository.getAnimal(ranchId, animalId)
    return MySQL.single.await('SELECT * FROM ranch_animals WHERE ranch_id = ? AND id = ? LIMIT 1', { ranchId, animalId })
end

function AnimalRepository.getActiveDiseases(animalId)
    return MySQL.query.await("SELECT * FROM ranch_animal_health WHERE animal_id = ? AND status = 'active' ORDER BY severity DESC", { animalId })
end

function AnimalRepository.getRanchDiseases(ranchId)
    return MySQL.query.await([[SELECT h.*, a.name AS animal_name, a.species_key, a.health AS animal_health FROM ranch_animal_health h
        INNER JOIN ranch_animals a ON a.id = h.animal_id WHERE h.ranch_id = ? AND h.status = 'active' ORDER BY h.severity DESC]], { ranchId })
end

function AnimalRepository.createDisease(ranchId, animalId, diseaseKey, severity)
    local existing = MySQL.scalar.await("SELECT id FROM ranch_animal_health WHERE animal_id = ? AND disease_key = ? AND status = 'active' LIMIT 1", { animalId, diseaseKey })
    if existing then return nil end
    return MySQL.insert.await([[INSERT INTO ranch_animal_health (animal_id, ranch_id, disease_key, severity)
        VALUES (?, ?, ?, ?)]], { animalId, ranchId, diseaseKey, severity })
end

function AnimalRepository.getBreedingCandidates(ranchId, pastureId, speciesKey, sex, maturityDays)
    return MySQL.query.await([[SELECT a.* FROM ranch_animals a WHERE a.ranch_id = ? AND a.pasture_id = ? AND a.species_key = ? AND a.sex = ?
        AND a.state = 'pasture' AND a.health >= ? AND a.happiness >= ? AND NOT EXISTS
        (SELECT 1 FROM ranch_animal_health h WHERE h.animal_id = a.id AND h.status = 'active')
        AND a.born_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? DAY) ORDER BY a.quality DESC]], { ranchId, pastureId, speciesKey, sex, Config.Breeding.minimumHealth, Config.Breeding.minimumHappiness, maturityDays })
end

function AnimalRepository.getDueBreedings()
    return MySQL.query.await([[SELECT b.*, mother.species_key AS mother_species, mother.breed_key AS mother_breed, mother.genetics_json AS mother_genetics,
        father.breed_key AS father_breed, father.genetics_json AS father_genetics, mother.pasture_id
        FROM ranch_breeding b INNER JOIN ranch_animals mother ON mother.id = b.mother_animal_id
        INNER JOIN ranch_animals father ON father.id = b.father_animal_id WHERE b.state = 'pregnant' AND b.due_at <= UTC_TIMESTAMP()]], {})
end

function AnimalRepository.countAnimalsByPasture(pastureId)
    return MySQL.scalar.await("SELECT COUNT(*) FROM ranch_animals WHERE pasture_id = ? AND state = 'pasture'", { pastureId }) or 0
end

function AnimalRepository.getInventoryAmount(ranchId, itemKey)
    return MySQL.scalar.await('SELECT quantity FROM ranch_inventory WHERE ranch_id = ? AND item_key = ? ORDER BY quality DESC LIMIT 1', { ranchId, itemKey }) or 0
end

function AnimalRepository.createAnimal(ranchId, pastureId, definition, spawn)
    return MySQL.insert.await([[INSERT INTO ranch_animals
        (ranch_id, pasture_id, species_key, breed_key, sex, name, born_at, weight, genetics_json, x, y, z)
        VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?)]], {
        ranchId, pastureId, definition.species, definition.breed, definition.sex, definition.name,
        definition.weight, json.encode(definition.genetics or {}), spawn.x, spawn.y, spawn.z,
    })
end
