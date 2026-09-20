RuralVeterinary = {}

local function openAnimalMenu(listing, animal, diseases)
    local options = {
        { title = ('%s #%s'):format(animal.name, animal.id), description = ('Saúde: %.0f | Fome: %.0f | Sede: %.0f'):format(animal.health, animal.hunger, animal.thirst), readOnly = true },
        { title = 'Examinar animal', icon = 'stethoscope', onSelect = function() TriggerServerEvent('rural_system:server:diagnoseAnimal', listing.key, animal.id) end },
    }
    for _, disease in ipairs(diseases or {}) do
        options[#options + 1] = { title = ('Tratar: %s'):format(Config.Veterinary.diseases[disease.disease_key].label), description = ('Gravidade: %.0f'):format(disease.severity), icon = 'briefcase-medical', onSelect = function()
            TriggerServerEvent('rural_system:server:treatAnimal', listing.key, animal.id, disease.disease_key)
        end }
    end
    lib.registerContext({ id = 'rural_vet_animal_' .. animal.id, title = 'Atendimento veterinário', menu = 'rural_vet_' .. listing.key, options = options })
    lib.showContext('rural_vet_animal_' .. animal.id)
end

function RuralVeterinary.openPanel(listing)
    local result = lib.callback.await('rural_system:server:getVeterinaryPanel', false, listing.key)
    if not result or not result.ok then return lib.notify({ description = result and result.message or 'Não foi possível abrir o livro veterinário.', type = 'error' }) end
    local diseaseMap = {}
    for _, disease in ipairs(result.data.diseases or {}) do
        diseaseMap[disease.animal_id] = diseaseMap[disease.animal_id] or {}
        diseaseMap[disease.animal_id][#diseaseMap[disease.animal_id] + 1] = disease
    end
    local options = {}
    for _, animal in ipairs(result.data.animals or {}) do
        options[#options + 1] = { title = animal.name, description = ('%s | Saúde %.0f%s'):format(Config.AnimalSpecies[animal.species_key].label, animal.health, diseaseMap[animal.id] and ' | Requer atenção' or ''), onSelect = function()
            openAnimalMenu(listing, animal, diseaseMap[animal.id])
        end }
    end
    if #options == 0 then options[1] = { title = 'Nenhum animal registrado', readOnly = true } end
    lib.registerContext({ id = 'rural_vet_' .. listing.key, title = 'Livro veterinário', options = options })
    lib.showContext('rural_vet_' .. listing.key)
end

function RuralVeterinary.createPoint(listing)
    if not listing.veterinary then return end
    lib.points.new({ coords = vec3(listing.veterinary.x, listing.veterinary.y, listing.veterinary.z), distance = 4.0,
        nearby = function(point)
            if point.currentDistance < 2.0 then
                lib.showTextUI('[E] Consultar livro veterinário')
                if IsControlJustReleased(0, 0xCEFD9220) then RuralVeterinary.openPanel(listing) end
            end
        end,
        onExit = function() lib.hideTextUI() end,
    })
end
