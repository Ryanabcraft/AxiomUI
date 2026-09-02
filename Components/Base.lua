local Utility = require(script.Parent.Parent.Services.Utility)
local Cleanup = require(script.Parent.Parent.Services.Cleanup)
local Base = {}

function Base.Cleanup()
    return Cleanup.new()
end

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

function Base.Handle(root, state, cleanup)
    cleanup=cleanup or Cleanup.new()
    local handle={Instance=root,Changed=state and state.Changed or nil,_cleanup=cleanup,_destroyed=false,_destroyCallbacks={}}
    local function finalize()
        if handle._destroyed then return end
        handle._destroyed=true
        for _,callback in ipairs(handle._destroyCallbacks) do pcall(callback) end
        table.clear(handle._destroyCallbacks)
        cleanup:Destroy()
        if state then state:Destroy() end
        handle.Changed=nil
        handle.Instance=nil
    end
    cleanup:Add(root.Destroying:Connect(finalize))
    function handle:Get() if not self._destroyed and state then return state:Get() end end
    function handle:Set(value) if not self._destroyed and state then state:Set(value) end end
    function handle:SetVisible(visible) if not self._destroyed and root.Parent then root.Visible=visible end end
    function handle:_OnDestroy(callback)
        if self._destroyed then pcall(callback) else table.insert(self._destroyCallbacks,callback) end
    end
    function handle:Destroy()
        if self._destroyed then return end
        finalize()
        pcall(function() root:Destroy() end)
    end
    return handle
end

return Base
