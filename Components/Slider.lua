local UserInputService = game:GetService("UserInputService")
local State = require(script.Parent.Parent.Core.State)
local Animation = require(script.Parent.Parent.Services.Animation)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
    local min, max = options.Min or 0, options.Max or 100
    local increment = options.Increment or 1
    local state = State.new(math.clamp(options.Default or min, min, max))
    local row, label = Base.Row(context, parent, options, 68)
    label.Size = UDim2.new(1, -114, 1, 0)
    label.Position = UDim2.fromOffset(16, 0)
    local valueLabel = Utility.Create("TextLabel", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-16,0,10), Size = UDim2.fromOffset(70,20),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = context.Theme.Current.TextMuted,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ClipsDescendants = true, Parent = row,
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
        local range=max-min
        Animation.Tween(fill, { Size = UDim2.fromScale(range==0 and 0 or (value-min)/range,1) }, 0.12)
    end
    local function update(input)
        if not cleanup:IsAlive() or track.AbsoluteSize.X<=0 then return end
        local ratio = math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        state:Set(math.floor((min+(max-min)*ratio)/increment+0.5)*increment)
    end
    cleanup:Add(track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=true; update(input) end end))
    cleanup:Add(UserInputService.InputChanged:Connect(function(input) if dragging and cleanup:IsAlive() and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end))
    cleanup:Add(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging=false end end))
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then render(value); Utility.SafeCallback(options.Callback,value) end end))
    cleanup:Add(function() dragging=false; Animation.Cancel(fill) end)
    render(state:Get())
    return Base.Handle(row,state,cleanup)
end
