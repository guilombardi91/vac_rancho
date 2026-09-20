local function reply(source, ok, message)
    RuralVorp.notify(source, message, ok and 'success' or 'error')
end

lib.callback.register('rural_system:server:getDashboard', function(source, ranchId)
    local player, err = RuralVorp.getCharacter(source)
    if not player then return { ok = false, message = err } end
    local data, reason = RanchService.getDashboard(player.id, ranchId)
    return data and { ok = true, data = data } or { ok = false, message = reason }
end)

RegisterNetEvent('rural_system:server:purchaseListing', function(listingKey)
    local source = source
    if not RuralSecurity.rateLimit(source, 'purchase') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    if type(listingKey) ~= 'string' or #listingKey > 64 then return reply(source, false, 'Propriedade inválida.') end
    local ok, result = RanchService.purchase(source, listingKey)
    reply(source, ok, ok and ('Você adquiriu %s.'):format(result.name) or result)
end)

RegisterNetEvent('rural_system:server:deposit', function(ranchId, amount)
    local source = source
    if not RuralSecurity.rateLimit(source, 'finance') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    local ok, reason = RanchService.deposit(source, ranchId, amount)
    reply(source, ok, ok and 'Depósito registrado.' or reason)
end)

RegisterNetEvent('rural_system:server:withdraw', function(ranchId, amount)
    local source = source
    if not RuralSecurity.rateLimit(source, 'finance') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    local ok, reason = RanchService.withdraw(source, ranchId, amount)
    reply(source, ok, ok and 'Retirada registrada.' or reason)
end)

RegisterNetEvent('rural_system:server:carePasture', function(listingKey, careType)
    local source = source
    if not RuralSecurity.rateLimit(source, 'animal_care') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    if type(listingKey) ~= 'string' or type(careType) ~= 'string' then return reply(source, false, 'Dados inválidos.') end
    local ok, result = AnimalService.carePasture(source, listingKey, careType)
    reply(source, ok, ok and ('Cuidado concluído: %.1f unidades utilizadas.'):format(result) or result)
end)

lib.callback.register('rural_system:server:getAnimalStream', function(source, listingKey)
    if type(listingKey) ~= 'string' then return nil end
    local listing
    for _, entry in ipairs(Config.RanchListings) do if entry.key == listingKey then listing = entry break end end
    if not listing or not RuralSecurity.near(source, listing.pasture, Config.Animals.streamingRadius) then return nil end
    local player = RuralVorp.getCharacter(source)
    return player and AnimalService.getStreamData(player.id, listingKey) or nil
end)

lib.callback.register('rural_system:server:getVeterinaryPanel', function(source, listingKey)
    if type(listingKey) ~= 'string' then return { ok = false, message = 'Posto inválido.' } end
    local data, err = VeterinaryService.getPanel(source, listingKey)
    return data and { ok = true, data = data } or { ok = false, message = err }
end)

RegisterNetEvent('rural_system:server:diagnoseAnimal', function(listingKey, animalId)
    local source = source
    if not RuralSecurity.rateLimit(source, 'veterinary') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    if type(listingKey) ~= 'string' or not tonumber(animalId) then return reply(source, false, 'Dados inválidos.') end
    local ok, result = VeterinaryService.diagnose(source, listingKey, animalId)
    reply(source, ok, ok and (#result > 0 and ('Diagnóstico concluído: %s condição(ões) encontrada(s).'):format(#result) or 'Diagnóstico concluído: animal saudável.') or result)
end)

RegisterNetEvent('rural_system:server:treatAnimal', function(listingKey, animalId, diseaseKey)
    local source = source
    if not RuralSecurity.rateLimit(source, 'veterinary') then return reply(source, false, 'Muitas solicitações; aguarde.') end
    if type(listingKey) ~= 'string' or not tonumber(animalId) or type(diseaseKey) ~= 'string' then return reply(source, false, 'Dados inválidos.') end
    local ok, reason = VeterinaryService.treat(source, listingKey, animalId, diseaseKey)
    reply(source, ok, ok and 'Tratamento concluído.' or reason)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= RuralConstants.ResourceName then return end
    if GetResourceState('oxmysql') ~= 'started' then error('[rural_system] oxmysql precisa estar iniciado antes deste resource.') end
    if GetResourceState('vorp_core') ~= 'started' then error('[rural_system] vorp_core precisa estar iniciado antes deste resource.') end
    print(('[rural_system] Fase 1 iniciada; %s listagens configuradas.'):format(#Config.RanchListings))
end)
