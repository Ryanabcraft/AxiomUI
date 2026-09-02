local State = require(script.Parent.Parent.Core.State)
local Animation = require(script.Parent.Parent.Services.Animation)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local theme = context.Theme.Current
    local state = State.new(options.Default == true)
    local row = Base.Row(context, parent, options, 54)
    local button = Utility.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 24),
        BackgroundColor3 = theme.SurfaceHover, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row,
    })
    Utility.Corner(button, UDim.new(1, 0))
    local knob = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = theme.TextMuted, BorderSizePixel = 0, Parent = button,
    })
    Utility.Corner(knob, UDim.new(1, 0))
    local function render(value)
        Animation.Tween(button, { BackgroundColor3 = value and context.Theme.Current.Primary or context.Theme.Current.SurfaceHover })
        Animation.Tween(knob, { Position = UDim2.new(0, value and 30 or 12, 0.5, 0), BackgroundColor3 = value and Color3.new(1,1,1) or context.Theme.Current.TextMuted })
    end
    state.Changed:Connect(function(value) render(value); Utility.SafeCallback(options.Callback, value) end)
    button.Activated:Connect(function() state:Set(not state:Get()) end)
    render(state:Get())
    return Base.Handle(row, state)
end
