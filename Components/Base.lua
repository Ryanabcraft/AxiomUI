local Utility = require(script.Parent.Parent.Services.Utility)
local Base = {}

function Base.Row(context, parent, options, height)
    local theme = context.Theme.Current
    local row = Utility.Create("Frame", {
        Name = options.Name or "Component", Size = UDim2.new(1, 0, 0, height or 54),
        BackgroundColor3 = theme.SurfaceAlt, BackgroundTransparency = theme.Transparency,
        BorderSizePixel = 0, Parent = parent,
    })
    Utility.Corner(row, theme.Radius)
    context.Theme:Bind(row, "BackgroundColor3", "SurfaceAlt")
    local stroke = Utility.Stroke(row, theme.Stroke, 0.62)
    context.Theme:Bind(stroke, "Color", "Stroke")
    local label = Utility.Create("TextLabel", {
        Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(0.62, -16, 1, 0), Font = Enum.Font.GothamMedium,
        Text = options.Name or "Component", TextColor3 = theme.Text, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    context.Theme:Bind(label, "TextColor3", "Text")
    return row, label
end

function Base.Handle(root, state)
    local handle = { Instance = root, Changed = state and state.Changed or nil }
    function handle:Get() return state and state:Get() end
    function handle:Set(value) if state then state:Set(value) end end
    function handle:SetVisible(visible) root.Visible = visible end
    function handle:Destroy() if state then state:Destroy() end root:Destroy() end
    return handle
end

return Base
