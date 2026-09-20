RuralAudit = {}

function RuralAudit.write(ranchId, actorCharacterId, action, targetType, targetId, payload)
    return MySQL.insert.await([[INSERT INTO ranch_audit_log
        (ranch_id, actor_character_id, action, target_type, target_id, payload_json)
        VALUES (?, ?, ?, ?, ?, ?)]], { ranchId, actorCharacterId, action, targetType, tostring(targetId or ''), json.encode(payload or {}) })
end
