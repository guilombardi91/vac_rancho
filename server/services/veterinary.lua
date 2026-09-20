VeterinaryService = {}

local function getRanchForCare(source, listingKey)
    local listing
    for _, entry in ipairs(Config.RanchListings) do if entry.key == listingKey then listing = entry break end end
    if not listing or not listing.veterinary then return nil, nil, 'Posto veterinário inválido.' end
    local player, err = RuralVorp.getCharacter(source)
    if not player then return nil, nil, err end
    local ranch = RanchRepository.findByListingKey(listingKey)
    if not ranch or not RanchService.hasPermission(player.id, ranch.id, 'animals.veterinary') then return nil, nil, 'Somente um veterinário autorizado pode realizar este atendimento.' end
    if not RuralSecurity.near(source, listing.veterinary, Config.Veterinary.diagnosisDistance) then return nil, nil, 'Aproxime-se do posto veterinário.' end
    return ranch, player
end

function VeterinaryService.getPanel(source, listingKey)
    local ranch, _, err = getRanchForCare(source, listingKey)
    if not ranch then return nil, err end
    return { animals = AnimalRepository.getAnimalsByRanch(ranch.id), diseases = AnimalRepository.getRanchDiseases(ranch.id) }
end

function VeterinaryService.diagnose(source, listingKey, animalId)
    local ranch, player, err = getRanchForCare(source, listingKey)
    if not ranch then return false, err end
    local animal = AnimalRepository.getAnimal(ranch.id, tonumber(animalId))
    if not animal then return false, 'Animal não encontrado.' end
    local diseases = AnimalRepository.getActiveDiseases(animal.id)
    MySQL.update.await([[UPDATE ranch_animal_health SET diagnosed_by_character_id = ?, diagnosed_at = CURRENT_TIMESTAMP
        WHERE animal_id = ? AND status = 'active' AND diagnosed_at IS NULL]], { player.id, animal.id })
    MySQL.insert.await('INSERT INTO ranch_animal_care_log (animal_id, ranch_id, actor_character_id, action_type, payload_json) VALUES (?, ?, ?, ?, ?)', { animal.id, ranch.id, player.id, 'diagnose', json.encode({ diseaseCount = #diseases }) })
    RuralAudit.write(ranch.id, player.id, 'animal.diagnose', 'animal', animal.id, { diseaseCount = #diseases })
    return true, diseases
end

function VeterinaryService.treat(source, listingKey, animalId, diseaseKey)
    local ranch, player, err = getRanchForCare(source, listingKey)
    if not ranch then return false, err end
    local disease = Config.Veterinary.diseases[diseaseKey]
    if not disease then return false, 'Tratamento inválido.' end
    local animal = AnimalRepository.getAnimal(ranch.id, tonumber(animalId))
    if not animal then return false, 'Animal não encontrado.' end
    local healthRecord = MySQL.single.await("SELECT * FROM ranch_animal_health WHERE animal_id = ? AND disease_key = ? AND status = 'active' LIMIT 1", { animal.id, diseaseKey })
    if not healthRecord then return false, 'Esta doença não está ativa no animal.' end
    local affected = MySQL.update.await([[UPDATE ranch_animals a
        INNER JOIN ranch_inventory i ON i.ranch_id = a.ranch_id AND i.item_key = ? AND i.quantity >= 1
        INNER JOIN ranch_animal_health h ON h.id = ? AND h.animal_id = a.id AND h.status = 'active'
        SET i.quantity = i.quantity - 1, h.status = 'treated', h.treated_by_character_id = ?, h.treated_at = CURRENT_TIMESTAMP,
        h.resolved_at = CURRENT_TIMESTAMP, a.health = LEAST(100, a.health + ?), a.hunger = GREATEST(0, a.hunger - ?),
        a.thirst = GREATEST(0, a.thirst - ?), a.stress = GREATEST(0, a.stress - 8), a.version = a.version + 1
        WHERE a.id = ? AND a.ranch_id = ?]], { Config.Veterinary.treatmentItem, healthRecord.id, player.id, disease.treatmentHealth or 0, disease.treatmentHunger or 0, disease.treatmentThirst or 0, animal.id, ranch.id })
    if not affected or affected < 1 then return false, 'Não há medicamento suficiente ou o tratamento não pôde ser registrado.' end
    MySQL.insert.await('INSERT INTO ranch_animal_care_log (animal_id, ranch_id, actor_character_id, action_type, item_key, quantity, payload_json) VALUES (?, ?, ?, ?, ?, 1, ?)', { animal.id, ranch.id, player.id, 'treat', Config.Veterinary.treatmentItem, json.encode({ disease = diseaseKey }) })
    RuralAudit.write(ranch.id, player.id, 'animal.treat', 'animal', animal.id, { disease = diseaseKey })
    return true
end
