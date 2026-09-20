RuralSecurity = {}

function RuralSecurity.rateLimit(source, key)
    local now, window = os.time(), Config.Security.windowSeconds
    local bucketKey = ('%s:%s'):format(source, key)
    local bucket = RuralCache.rateLimits[bucketKey]
    if not bucket or now - bucket.startedAt >= window then
        RuralCache.rateLimits[bucketKey] = { startedAt = now, count = 1 }
        return true
    end
    bucket.count = bucket.count + 1
    return bucket.count <= Config.Security.maxRequestsPerWindow
end

function RuralSecurity.near(source, coordinates, radius)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local position = GetEntityCoords(ped)
    return RuralUtils.distanceSquared({ x = position.x, y = position.y, z = position.z }, coordinates) <= radius * radius
end

function RuralSecurity.validateAmount(amount)
    return RuralUtils.isFiniteNumber(amount) and amount > 0 and amount <= 100000000 and RuralUtils.roundCurrency(amount) == amount
end

AddEventHandler('playerDropped', function()
    local source = source
    for key in pairs(RuralCache.rateLimits) do
        if key:sub(1, #tostring(source) + 1) == tostring(source) .. ':' then RuralCache.rateLimits[key] = nil end
    end
end)
