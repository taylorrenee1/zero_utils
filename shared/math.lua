function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

math.clamp = clamp