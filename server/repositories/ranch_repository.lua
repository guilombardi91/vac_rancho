RanchRepository = {}

function RanchRepository.findByListingKey(listingKey)
    return MySQL.single.await('SELECT * FROM ranches WHERE listing_key = ? LIMIT 1', { listingKey })
end

function RanchRepository.findById(ranchId)
    return MySQL.single.await('SELECT * FROM ranches WHERE id = ? LIMIT 1', { ranchId })
end

function RanchRepository.countByOwner(characterId)
    return MySQL.scalar.await("SELECT COUNT(*) FROM ranches WHERE owner_character_id = ? AND status IN ('active', 'for_sale', 'leased')", { characterId }) or 0
end

function RanchRepository.getMember(ranchId, characterId)
    return MySQL.single.await('SELECT * FROM ranch_members WHERE ranch_id = ? AND character_id = ? AND status = ? LIMIT 1', { ranchId, characterId, 'active' })
end

function RanchRepository.getMembers(ranchId)
    return MySQL.query.await('SELECT * FROM ranch_members WHERE ranch_id = ? AND status = ? ORDER BY ownership_percent DESC, joined_at ASC', { ranchId, 'active' })
end

function RanchRepository.getRolePermissions(ranchId, roleKey)
    return MySQL.query.await('SELECT permission_key, allowed FROM ranch_role_permissions WHERE ranch_id = ? AND role_key = ?', { ranchId, roleKey })
end

function RanchRepository.getPlayerRanches(characterId)
    return MySQL.query.await([[SELECT r.*, m.role_key, m.ownership_percent FROM ranches r
        INNER JOIN ranch_members m ON m.ranch_id = r.id WHERE m.character_id = ? AND m.status = 'active' ORDER BY r.name]], { characterId })
end
