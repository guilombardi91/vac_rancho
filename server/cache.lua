RuralCache = { ranches = {}, rateLimits = {} }

function RuralCache.getRanch(id)
    local entry = RuralCache.ranches[id]
    if not entry or entry.expiresAt < os.time() then return nil end
    return entry.value
end

function RuralCache.setRanch(id, value)
    RuralCache.ranches[id] = { value = value, expiresAt = os.time() + Config.RanchCacheTtlSeconds }
end

function RuralCache.invalidateRanch(id)
    RuralCache.ranches[id] = nil
end
