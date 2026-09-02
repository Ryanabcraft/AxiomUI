local UserInputService=game:GetService("UserInputService")
local State=require(script.Parent.Parent.Core.State)
local Utility=require(script.Parent.Parent.Services.Utility)
local Base=require(script.Parent.Base)

return function(context,parent,options)
    options=options or {}; local cleanup=Base.Cleanup(); local state=State.new(options.Default or Enum.KeyCode.Unknown); local listening=false
    local row=Base.Row(context,parent,options,54)
    local capture=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(94,32),BackgroundColor3=context.Theme.Current.Background,BackgroundTransparency=0.15,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamMedium,TextColor3=context.Theme.Current.TextMuted,TextSize=11,Parent=row})
    Utility.Corner(capture,UDim.new(0,8)); Utility.Stroke(capture,context.Theme.Current.Stroke,0.55)
    local function render(key) capture.Text=listening and "PRESS A KEY" or key.Name:upper() end
    cleanup:Add(capture.Activated:Connect(function() if cleanup:IsAlive() then listening=true; render(state:Get()) end end))
    cleanup:Add(UserInputService.InputBegan:Connect(function(input,processed)
        if not cleanup:IsAlive() then return end
        if listening and input.KeyCode~=Enum.KeyCode.Unknown then listening=false; state:Set(input.KeyCode); render(input.KeyCode); return end
        if not processed and input.KeyCode==state:Get() then Utility.SafeCallback(options.Callback,input.KeyCode) end
    end))
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then render(value) end end))
    cleanup:Add(function() listening=false end)
    render(state:Get())
    return Base.Handle(row,state,cleanup)
end
