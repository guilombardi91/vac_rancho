RuralUtils = {}

function RuralUtils.trim(value)
    if type(value) ~= 'string' then return nil end
    return value:match('^%s*(.-)%s*$')
end

function RuralUtils.isFiniteNumber(value)
    return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
end

function RuralUtils.roundCurrency(value)
    return math.floor((value + 0.00001) * 100) / 100
end

function RuralUtils.distanceSquared(a, b)
    local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
    return dx * dx + dy * dy + dz * dz
end

function RuralUtils.contains(values, wanted)
    for _, value in ipairs(values or {}) do if value == wanted then return true end end
    return false
end

function RuralUtils.clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end
