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
