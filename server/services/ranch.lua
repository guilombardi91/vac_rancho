RanchService = {}

local function listingByKey(key)
    for _, listing in ipairs(Config.RanchListings) do if listing.key == key then return listing end end
end

function RanchService.getRanch(ranchId)
    ranchId = tonumber(ranchId)
    if not ranchId then return nil end
    local cached = RuralCache.getRanch(ranchId)
    if cached then return cached end
    local ranch = RanchRepository.findById(ranchId)
    if ranch then RuralCache.setRanch(ranchId, ranch) end
    return ranch
end

function RanchService.hasPermission(characterId, ranchId, permission)
    local member = RanchRepository.getMember(ranchId, characterId)
    if not member then return false end
    if member.role_key == RuralConstants.Roles.OWNER then return true end
    local permissions = RanchRepository.getRolePermissions(ranchId, member.role_key)
    if #permissions > 0 then
        for _, entry in ipairs(permissions) do if entry.permission_key == permission then return entry.allowed == 1 end end
        return false
    end
    return RuralUtils.contains(Config.Permissions[member.role_key], permission)
end

function RanchService.purchase(source, listingKey)
    local listing = listingByKey(listingKey)
    if not listing then return false, 'Propriedade inválida.' end
    if not RuralSecurity.near(source, listing, Config.ActionDistance) then return false, 'Aproxime-se da placa da propriedade.' end
    local player, err = RuralVorp.getCharacter(source)
    if not player then return false, err end
    if RanchRepository.countByOwner(player.id) >= Config.MaxRanchesPerCharacter then return false, 'Você atingiu o limite de propriedades.' end
    if RanchRepository.findByListingKey(listing.key) then return false, 'Esta propriedade já possui dono.' end
    local cash, cashErr = RuralVorp.getCash(source)
    if not cash then return false, cashErr end
    if cash < listing.price then return false, 'Dinheiro insuficiente.' end

    local success, ranchId = MySQL.transaction.await({
        { query = [[INSERT INTO ranches (listing_key, name, type, owner_character_id, region_key, x, y, z, heading, acquisition_price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)]], values = { listing.key, listing.label, listing.type, player.id, listing.region, listing.x, listing.y, listing.z, listing.heading, listing.price } },
        { query = [[INSERT INTO ranch_members (ranch_id, character_id, role_key, ownership_percent) VALUES (LAST_INSERT_ID(), ?, ?, 100.00)]], values = { player.id, RuralConstants.Roles.OWNER } },
    })
    if not success then return false, 'Não foi possível registrar a propriedade. Tente novamente.' end
    local inserted = RanchRepository.findByListingKey(listing.key)
    if not inserted then return false, 'A propriedade foi criada, mas não pôde ser carregada.' end
    local paid, payErr = RuralVorp.removeCash(source, listing.price)
    if not paid then
        MySQL.update.await('DELETE FROM ranches WHERE id = ?', { inserted.id })
        return false, payErr
    end
    MySQL.insert.await([[INSERT INTO ranch_ledger (ranch_id, actor_character_id, entry_type, amount, balance_after, reference_type, reference_id, description)
        VALUES (?, ?, 'purchase', ?, 0, 'listing', ?, ?)]], { inserted.id, player.id, -listing.price, listing.key, 'Compra da propriedade' })
    RuralAudit.write(inserted.id, player.id, 'ranch.purchase', 'ranch', inserted.id, { listingKey = listing.key, price = listing.price })
    TriggerEvent('rural_system:server:ranchCreated', inserted.id, listing.key, player.id)
    RuralCache.invalidateRanch(inserted.id)
    return true, inserted
end

function RanchService.getDashboard(characterId, ranchId)
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or not RanchService.hasPermission(characterId, ranch.id, 'ranch.view') then return nil, 'Sem acesso a esta propriedade.' end
    return { ranch = ranch, members = RanchRepository.getMembers(ranch.id), permissions = Config.Permissions }
end

function RanchService.deposit(source, ranchId, amount)
    if not RuralSecurity.validateAmount(amount) then return false, 'Valor inválido.' end
    local player, err = RuralVorp.getCharacter(source)
    if not player then return false, err end
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or not RanchService.hasPermission(player.id, ranch.id, 'finance.deposit') then return false, 'Sem permissão para depositar.' end
    local cash = RuralVorp.getCash(source)
    if not cash or cash < amount then return false, 'Dinheiro insuficiente.' end
    local paid, payErr = RuralVorp.removeCash(source, amount)
    if not paid then return false, payErr end
    local ok = MySQL.transaction.await({
        { query = 'UPDATE ranches SET cash_balance = cash_balance + ?, version = version + 1 WHERE id = ?', values = { amount, ranch.id } },
        { query = [[INSERT INTO ranch_ledger (ranch_id, actor_character_id, entry_type, amount, balance_after, description)
            SELECT id, ?, 'deposit', ?, cash_balance, 'Depósito no caixa do rancho' FROM ranches WHERE id = ?]], values = { player.id, amount, ranch.id } },
    })
    if not ok then RuralVorp.addCash(source, amount); return false, 'Falha ao registrar o depósito; o dinheiro foi devolvido.' end
    RuralAudit.write(ranch.id, player.id, 'finance.deposit', 'ranch', ranch.id, { amount = amount })
    RuralCache.invalidateRanch(ranch.id)
    return true
end

function RanchService.withdraw(source, ranchId, amount)
    if not RuralSecurity.validateAmount(amount) then return false, 'Valor inválido.' end
    local player, err = RuralVorp.getCharacter(source)
    if not player then return false, err end
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or not RanchService.hasPermission(player.id, ranch.id, 'finance.withdraw') then return false, 'Sem permissão para retirar.' end
    local affected = MySQL.update.await('UPDATE ranches SET cash_balance = cash_balance - ?, version = version + 1 WHERE id = ? AND cash_balance >= ?', { amount, ranch.id, amount })
    if affected ~= 1 then return false, 'O caixa não possui saldo suficiente.' end
    local paid, payErr = RuralVorp.addCash(source, amount)
    if not paid then
        MySQL.update.await('UPDATE ranches SET cash_balance = cash_balance + ?, version = version + 1 WHERE id = ?', { amount, ranch.id })
        return false, payErr
    end
    local current = RanchRepository.findById(ranch.id)
    MySQL.insert.await([[INSERT INTO ranch_ledger (ranch_id, actor_character_id, entry_type, amount, balance_after, description)
        VALUES (?, ?, 'withdrawal', ?, ?, 'Retirada do caixa do rancho')]], { ranch.id, player.id, -amount, current.cash_balance })
    RuralAudit.write(ranch.id, player.id, 'finance.withdraw', 'ranch', ranch.id, { amount = amount })
    RuralCache.invalidateRanch(ranch.id)
    return true
end

function RanchService.addMember(actorCharacterId, ranchId, memberCharacterId, roleKey, ownershipPercent)
    local ranch = RanchService.getRanch(ranchId)
    ownershipPercent = tonumber(ownershipPercent) or 0
    if not ranch or not RanchService.hasPermission(actorCharacterId, ranch.id, 'members.manage') then return false, 'Sem permissão para administrar membros.' end
    if not Config.Permissions[roleKey] or memberCharacterId == '' or ownershipPercent < 0 or ownershipPercent > 100 then return false, 'Dados de membro inválidos.' end
    local result = MySQL.query.await('SELECT ownership_percent FROM ranch_members WHERE ranch_id = ? AND status = ?', { ranch.id, 'active' })
    local total = 0
    for _, member in ipairs(result or {}) do total = total + tonumber(member.ownership_percent) end
    local existing = RanchRepository.getMember(ranch.id, memberCharacterId)
    if existing then total = total - tonumber(existing.ownership_percent) end
    if total + ownershipPercent > 100 then return false, 'A participação total não pode ultrapassar 100%.' end
    MySQL.update.await([[INSERT INTO ranch_members (ranch_id, character_id, role_key, ownership_percent, status, joined_at, left_at)
        VALUES (?, ?, ?, ?, 'active', CURRENT_TIMESTAMP, NULL)
        ON DUPLICATE KEY UPDATE role_key = VALUES(role_key), ownership_percent = VALUES(ownership_percent), status = 'active', left_at = NULL]],
        { ranch.id, memberCharacterId, roleKey, ownershipPercent })
    RuralAudit.write(ranch.id, actorCharacterId, 'member.upsert', 'character', memberCharacterId, { role = roleKey, ownershipPercent = ownershipPercent })
    return true
end

function RanchService.removeMember(actorCharacterId, ranchId, memberCharacterId)
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or not RanchService.hasPermission(actorCharacterId, ranch.id, 'members.manage') then return false, 'Sem permissão para administrar membros.' end
    if tostring(memberCharacterId) == tostring(ranch.owner_character_id) then return false, 'Transfira a propriedade antes de remover o proprietário.' end
    local affected = MySQL.update.await("UPDATE ranch_members SET status = 'removed', left_at = CURRENT_TIMESTAMP WHERE ranch_id = ? AND character_id = ? AND status = 'active'", { ranch.id, memberCharacterId })
    if affected ~= 1 then return false, 'Membro não encontrado.' end
    RuralAudit.write(ranch.id, actorCharacterId, 'member.remove', 'character', memberCharacterId, {})
    return true
end

function RanchService.transferOwnership(actorCharacterId, ranchId, recipientCharacterId)
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or tostring(ranch.owner_character_id) ~= tostring(actorCharacterId) then return false, 'Somente o proprietário pode transferir o rancho.' end
    local recipient = RanchRepository.getMember(ranch.id, recipientCharacterId)
    if not recipient then return false, 'O destinatário deve ser membro ativo do rancho.' end
    local ok = MySQL.transaction.await({
        { query = 'UPDATE ranches SET owner_character_id = ?, version = version + 1 WHERE id = ?', values = { recipientCharacterId, ranch.id } },
        { query = "UPDATE ranch_members SET role_key = 'OWNER', ownership_percent = 100.00 WHERE ranch_id = ? AND character_id = ?", values = { ranch.id, recipientCharacterId } },
        { query = "UPDATE ranch_members SET role_key = 'MANAGER', ownership_percent = 0.00 WHERE ranch_id = ? AND character_id = ?", values = { ranch.id, actorCharacterId } },
    })
    if not ok then return false, 'A transferência não pôde ser concluída.' end
    RuralAudit.write(ranch.id, actorCharacterId, 'ranch.transfer', 'character', recipientCharacterId, {})
    RuralCache.invalidateRanch(ranch.id)
    return true
end

function RanchService.createLease(actorCharacterId, ranchId, tenantCharacterId, rentAmount, startsAt, endsAt)
    local ranch = RanchService.getRanch(ranchId)
    if not ranch or tostring(ranch.owner_character_id) ~= tostring(actorCharacterId) then return false, 'Somente o proprietário pode arrendar o rancho.' end
    if not RuralSecurity.validateAmount(rentAmount) or tenantCharacterId == '' or startsAt >= endsAt then return false, 'Dados de arrendamento inválidos.' end
    local id = MySQL.insert.await([[INSERT INTO ranch_leases (ranch_id, landlord_character_id, tenant_character_id, rent_amount, starts_at, ends_at)
        VALUES (?, ?, ?, ?, FROM_UNIXTIME(?), FROM_UNIXTIME(?))]], { ranch.id, actorCharacterId, tenantCharacterId, rentAmount, startsAt, endsAt })
    if not id then return false, 'Não foi possível criar o arrendamento.' end
    RanchService.addMember(actorCharacterId, ranch.id, tenantCharacterId, RuralConstants.Roles.MANAGER, 0)
    RuralAudit.write(ranch.id, actorCharacterId, 'lease.create', 'lease', id, { tenantCharacterId = tenantCharacterId, rentAmount = rentAmount })
    return true, id
end
