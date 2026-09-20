exports('GetRanch', function(ranchId) return RanchService.getRanch(ranchId) end)
exports('GetPlayerRanches', function(characterId) return RanchRepository.getPlayerRanches(tostring(characterId)) end)
exports('GetPlayerRanch', function(characterId, ranchId)
    if ranchId then
        local ranch = RanchService.getRanch(ranchId)
        return ranch and RanchService.hasPermission(tostring(characterId), ranch.id, 'ranch.view') and ranch or nil
    end
    return RanchRepository.getPlayerRanches(tostring(characterId))
end)
exports('HasRanchPermission', function(characterId, ranchId, permission) return RanchService.hasPermission(tostring(characterId), ranchId, permission) end)
exports('AddRanchMoney', function(ranchId, amount, reason, actorCharacterId)
    if not RuralSecurity.validateAmount(amount) then return false, 'Valor inválido.' end
    local ranch = RanchService.getRanch(ranchId)
    if not ranch then return false, 'Rancho inexistente.' end
    local affected = MySQL.update.await('UPDATE ranches SET cash_balance = cash_balance + ?, version = version + 1 WHERE id = ?', { amount, ranch.id })
    if affected ~= 1 then return false, 'Não foi possível atualizar o caixa.' end
    local updated = RanchRepository.findById(ranch.id)
    MySQL.insert.await('INSERT INTO ranch_ledger (ranch_id, actor_character_id, entry_type, amount, balance_after, description) VALUES (?, ?, ?, ?, ?, ?)', { ranch.id, actorCharacterId, 'external_credit', amount, updated.cash_balance, reason or 'Crédito externo' })
    RuralCache.invalidateRanch(ranch.id)
    return true
end)
exports('GetRanchAnimals', function(ranchId) return AnimalRepository.getAnimalsByRanch(ranchId) end)
exports('AddRanchAnimal', function(ranchId, pastureId, definition) return AnimalService.createAnimal(ranchId, pastureId, definition) end)
