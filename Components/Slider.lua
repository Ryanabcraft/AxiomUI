local UserInputService = game:GetService("UserInputService")
local State = require(script.Parent.Parent.Core.State)
local Animation = require(script.Parent.Parent.Services.Animation)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local min, max = options.Min or 0, options.Max or 100
    local increment = options.Increment or 1
    local state = State.new(math.clamp(options.Default or min, min, max))
    local row = Base.Row(context, parent, options, 68)
    local valueLabel = Utility.Create("TextLabel", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-16,0,10), Size = UDim2.fromOffset(70,20),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = context.Theme.Current.TextMuted,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    local track = Utility.Create("Frame", {
        Position = UDim2.new(0,16,1,-20), Size = UDim2.new(1,-32,0,5), BackgroundColor3 = context.Theme.Current.SurfaceHover,
        BorderSizePixel = 0, Parent = row,
    })
    Utility.Corner(track, UDim.new(1,0))
    local fill = Utility.Create("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = context.Theme.Current.Primary, BorderSizePixel = 0, Parent = track })
    Utility.Corner(fill, UDim.new(1,0))
    local dragging = false
    local function render(value)
        valueLabel.Text = tostring(value) .. (options.Suffix or "")
        Animation.Tween(fill, { Size = UDim2.fromScale((value-min)/(max-min),1) }, 0.12)
    end
    local function update(input)
        local ratio = math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        state:Set(math.floor((min+(max-min)*ratio)/increment+0.5)*increment)
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=true; update(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=false end end)
    state.Changed:Connect(function(value) render(value); Utility.SafeCallback(options.Callback,value) end)
    render(state:Get())
    return Base.Handle(row,state)
end
