local Utility = {}

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do instance[property] = value end
    for _, child in ipairs(children or {}) do child.Parent = instance end
    return instance
end

function Utility.Corner(parent, radius)
    return Utility.Create("UICorner", { CornerRadius = radius or UDim.new(0, 10), Parent = parent })
end

function Utility.Stroke(parent, color, transparency, thickness)
    return Utility.Create("UIStroke", {
        Color = color, Transparency = transparency or 0, Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round, Parent = parent,
    })
end

function Utility.Padding(parent, value)
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, value), PaddingBottom = UDim.new(0, value),
        PaddingLeft = UDim.new(0, value), PaddingRight = UDim.new(0, value), Parent = parent,
    })
end

function Utility.SafeCallback(callback, ...)
    if not callback then return end
    local ok, err = pcall(callback, ...)
    if not ok then warn("[Axiom] callback error:", err) end
end

return Utility
