local State = require(script.Parent.Parent.Core.State)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local state = State.new(options.Default or "")
    local row = Base.Row(context, parent, options, 62)
    local box = Utility.Create("TextBox", {
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0), Size=UDim2.new(0.46,0,0,34),
        BackgroundColor3=context.Theme.Current.Background, BackgroundTransparency=0.25, BorderSizePixel=0,
        ClearTextOnFocus=false, Font=Enum.Font.Gotham, PlaceholderText=options.Placeholder or "Type here...",
        PlaceholderColor3=context.Theme.Current.TextMuted, Text=state:Get(), TextColor3=context.Theme.Current.Text,
        TextSize=12, Parent=row,
    })
    Utility.Corner(box, UDim.new(0,8)); Utility.Stroke(box,context.Theme.Current.Stroke,0.55)
    box.FocusLost:Connect(function(enterPressed)
        local value = box.Text
        if options.Validate and not options.Validate(value) then box.Text=state:Get(); return end
        state:Set(value)
        if options.Finished then Utility.SafeCallback(options.Callback,value,enterPressed) end
    end)
    if not options.Finished then box:GetPropertyChangedSignal("Text"):Connect(function() state:Set(box.Text) end) end
    state.Changed:Connect(function(value) if box.Text ~= value then box.Text=value end; Utility.SafeCallback(options.Callback,value) end)
    return Base.Handle(row,state)
end
