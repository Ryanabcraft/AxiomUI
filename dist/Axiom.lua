-- AXIOM UI ENGINE � generated distribution
local __modules,__cache={},{}
local function __require(id)
 if __cache[id]~=nil then return __cache[id] end
 local factory=assert(__modules[id],"Missing Axiom module: "..id)
 local value=factory()
 __cache[id]=value
 return value
end

__modules["Components/Base"]=function()
local Utility = __require("Services/Utility")
local Cleanup = __require("Services/Cleanup")
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

end

__modules["Components/Button"]=function()
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
    local theme = context.Theme.Current
    local button = Utility.Create("TextButton", {
        Name = options.Name or "Button", Size = UDim2.new(1, 0, 0, 44), AutoButtonColor = false,
        BackgroundColor3 = theme.SurfaceAlt, BackgroundTransparency = theme.Transparency,
        BorderSizePixel = 0, Text = options.Name or "Button", TextColor3 = theme.Text,
        TextSize = 13, Font = Enum.Font.GothamMedium, ClipsDescendants = true, Parent = parent,
    })
    Utility.Corner(button, theme.Radius)
    local stroke = Utility.Stroke(button, theme.Stroke, 0.62)
    context.Theme:Bind(button, "BackgroundColor3", "SurfaceAlt")
    context.Theme:Bind(button, "TextColor3", "Text")
    context.Theme:Bind(stroke, "Color", "Stroke")
    cleanup:Add(button.MouseEnter:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceHover }) end))
    cleanup:Add(button.MouseLeave:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceAlt }) end))
    cleanup:Add(button.Activated:Connect(function()
        if not cleanup:IsAlive() then return end
        Animation.Ripple(button,theme.Primary,cleanup)
        Utility.SafeCallback(options.Callback)
    end))
    cleanup:Add(function() Animation.Cancel(button) end)
    return Base.Handle(button,nil,cleanup)
end

end

__modules["Components/Card"]=function()
local Utility=__require("Services/Utility")

return function(context,parent,options)
    options=options or {}; local theme=context.Theme.Current
    local card=Utility.Create("Frame",{Name=options.Name or "Card",Size=options.Size or UDim2.new(1,0,0,100),BackgroundColor3=theme.SurfaceAlt,BackgroundTransparency=theme.Transparency,BorderSizePixel=0,Parent=parent})
    Utility.Corner(card,theme.Radius); Utility.Stroke(card,theme.Stroke,0.62); Utility.Padding(card,16)
    if options.Name then Utility.Create("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=options.Name,TextColor3=theme.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=card}) end
    return card
end

end

__modules["Components/ColorPicker"]=function()
local UserInputService=game:GetService("UserInputService")
local State=__require("Core/State")
local Animation=__require("Services/Animation")
local Utility=__require("Services/Utility")
local Base=__require("Components/Base")

return function(context,parent,options)
    options=options or {}
    local cleanup=Base.Cleanup()
    local state=State.new(options.Default or context.Theme.Current.Primary)
    local h,s,v=state:Get():ToHSV()
    local row=Base.Row(context,parent,options,62)
    row.ClipsDescendants=true
    local open=false
    local preview=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=state:Get(),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=row})
    Utility.Corner(preview,UDim.new(0,8)); Utility.Stroke(preview,Color3.new(1,1,1),0.75)
    local hex=Utility.Create("TextBox",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-54,0,14),Size=UDim2.fromOffset(92,34),BackgroundColor3=context.Theme.Current.Background,BackgroundTransparency=0.2,BorderSizePixel=0,ClearTextOnFocus=false,Font=Enum.Font.Code,TextColor3=context.Theme.Current.Text,TextSize=12,Parent=row})
    Utility.Corner(hex,UDim.new(0,8))
    local panel=Utility.Create("Frame",{Position=UDim2.fromOffset(12,64),Size=UDim2.new(1,-24,0,150),BackgroundTransparency=1,Parent=row})
    local sv=Utility.Create("Frame",{Size=UDim2.new(1,-54,0,112),BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ClipsDescendants=true,Parent=panel}); Utility.Corner(sv,UDim.new(0,8))
    local white=Utility.Create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=sv})
    Utility.Create("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}),Parent=white})
    local black=Utility.Create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=sv})
    Utility.Create("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Parent=black})
    local cursor=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(s,1-v),Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=5,Parent=sv}); Utility.Corner(cursor,UDim.new(1,0)); Utility.Stroke(cursor,Color3.new(1,1,1),0,2)
    local hue=Utility.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.fromOffset(38,112),BorderSizePixel=0,Parent=panel}); Utility.Corner(hue,UDim.new(0,8))
    Utility.Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}),Parent=hue})
    local hueCursor=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,h),Size=UDim2.new(1,4,0,4),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=5,Parent=hue}); Utility.Corner(hueCursor,UDim.new(1,0))
    local rgb=Utility.Create("TextLabel",{Position=UDim2.new(0,0,1,-27),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Font=Enum.Font.Code,TextColor3=context.Theme.Current.TextMuted,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=panel})
    local draggingSV,draggingHue=false,false
    local function toHex(c) return string.format("#%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
    local function fromHex(value) local text=value:gsub("#",""); if #text~=6 then return nil end; local n=tonumber(text,16); if not n then return nil end; return Color3.fromRGB(bit32.rshift(n,16),bit32.band(bit32.rshift(n,8),255),bit32.band(n,255)) end
    local function applyHSV() state:Set(Color3.fromHSV(h,s,v)) end
    local function updateSV(input) if not cleanup:IsAlive() or sv.AbsoluteSize.X<=0 or sv.AbsoluteSize.Y<=0 then return end; s=math.clamp((input.Position.X-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1); v=1-math.clamp((input.Position.Y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1); applyHSV() end
    local function updateHue(input) if not cleanup:IsAlive() or hue.AbsoluteSize.Y<=0 then return end; h=math.clamp((input.Position.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y,0,1); applyHSV() end
    cleanup:Add(sv.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSV=true; updateSV(input) end end))
    cleanup:Add(hue.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHue=true; updateHue(input) end end))
    cleanup:Add(UserInputService.InputChanged:Connect(function(input) if cleanup:IsAlive() and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then if draggingSV then updateSV(input) elseif draggingHue then updateHue(input) end end end))
    cleanup:Add(UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSV=false; draggingHue=false end end))
    cleanup:Add(preview.Activated:Connect(function() if cleanup:IsAlive() then open=not open; Animation.Tween(row,{Size=UDim2.new(1,0,0,open and 224 or 62)},0.28) end end))
    cleanup:Add(hex.FocusLost:Connect(function() if not cleanup:IsAlive() then return end; local color=fromHex(hex.Text); if color then state:Set(color) else hex.Text=toHex(state:Get()) end end))
    local function render(color,fireCallback)
        h,s,v=color:ToHSV(); preview.BackgroundColor3=color; hex.Text=toHex(color); sv.BackgroundColor3=Color3.fromHSV(h,1,1)
        cursor.Position=UDim2.fromScale(s,1-v); hueCursor.Position=UDim2.fromScale(0.5,h)
        rgb.Text=string.format("RGB  %d  %d  %d",math.round(color.R*255),math.round(color.G*255),math.round(color.B*255))
        if fireCallback then Utility.SafeCallback(options.Callback,color,toHex(color)) end
    end
    cleanup:Add(state.Changed:Connect(function(color) if cleanup:IsAlive() then render(color,true) end end))
    cleanup:Add(function() draggingSV=false; draggingHue=false; open=false; Animation.Cancel(row) end)
    render(state:Get(),false)
    return Base.Handle(row,state,cleanup)
end

end

__modules["Components/Dropdown"]=function()
local State = __require("Core/State")
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
    local values = options.Options or {}
    local multi = options.Multi == true
    local initial = options.Default or (multi and {} or values[1])
    local state = State.new(initial)
    local row = Base.Row(context,parent,options,54)
    row.ClipsDescendants = true
    local selector = Utility.Create("TextButton", {
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,10), Size=UDim2.new(0.46,0,0,34),
        BackgroundColor3=context.Theme.Current.Background, BackgroundTransparency=0.2, BorderSizePixel=0,
        AutoButtonColor=false, Font=Enum.Font.Gotham, TextColor3=context.Theme.Current.TextMuted,
        TextSize=12, TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    Utility.Corner(selector,UDim.new(0,8)); Utility.Stroke(selector,context.Theme.Current.Stroke,0.55)
    local list = Utility.Create("Frame", { Position=UDim2.new(0,12,0,54), Size=UDim2.new(1,-24,0,0), BackgroundTransparency=1, Parent=row })
    local layout=Utility.Create("UIListLayout",{Padding=UDim.new(0,4),Parent=list})
    local open=false
    local function display(value)
        if multi then
            local selected={}; for key,enabled in pairs(value) do if enabled then table.insert(selected,key) end end
            table.sort(selected); selector.Text=#selected>0 and table.concat(selected,", ") or "Select..."
        else selector.Text=tostring(value or "Select...") end
    end
    local function setOpen(value)
        open=value; local target=value and (#values*32+(#values-1)*4+66) or 54
        Animation.Tween(row,{Size=UDim2.new(1,0,0,target)})
        Animation.Tween(list,{Size=UDim2.new(1,-24,0,value and target-62 or 0)})
    end
    for _,value in ipairs(values) do
        local item=Utility.Create("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=context.Theme.Current.SurfaceHover,BackgroundTransparency=0.18,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.Gotham,Text=tostring(value),TextColor3=context.Theme.Current.Text,TextSize=12,Parent=list})
        Utility.Corner(item,UDim.new(0,7))
        cleanup:Add(item.Activated:Connect(function()
            if not cleanup:IsAlive() then return end
            if multi then local nextValue=table.clone(state:Get()); nextValue[value]=not nextValue[value]; state:Set(nextValue) else state:Set(value); setOpen(false) end
        end))
    end
    cleanup:Add(selector.Activated:Connect(function() if cleanup:IsAlive() then setOpen(not open) end end))
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then display(value); Utility.SafeCallback(options.Callback,value) end end))
    cleanup:Add(function() open=false; Animation.Cancel(row); Animation.Cancel(list) end)
    display(state:Get())
    return Base.Handle(row,state,cleanup)
end

end

__modules["Components/Input"]=function()
local State = __require("Core/State")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
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
    cleanup:Add(box.FocusLost:Connect(function(enterPressed)
        if not cleanup:IsAlive() then return end
        local value = box.Text
        if options.Validate and not options.Validate(value) then box.Text=state:Get(); return end
        state:Set(value)
        if options.Finished then Utility.SafeCallback(options.Callback,value,enterPressed) end
    end))
    if not options.Finished then cleanup:Add(box:GetPropertyChangedSignal("Text"):Connect(function() if cleanup:IsAlive() then state:Set(box.Text) end end)) end
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then if box.Text ~= value then box.Text=value end; Utility.SafeCallback(options.Callback,value) end end))
    return Base.Handle(row,state,cleanup)
end

end

__modules["Components/Keybind"]=function()
local UserInputService=game:GetService("UserInputService")
local State=__require("Core/State")
local Utility=__require("Services/Utility")
local Base=__require("Components/Base")

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

end

__modules["Components/Section"]=function()
local Utility=__require("Services/Utility")

return function(context,parent,options)
    options=options or {}; local theme=context.Theme.Current
    local section=Utility.Create("Frame",{Name=options.Name or "Section",Size=UDim2.new(1,0,0,32),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=parent})
    Utility.Create("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=string.upper(options.Name or "SECTION"),TextColor3=theme.TextMuted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=section})
    local content=Utility.Create("Frame",{Position=UDim2.fromOffset(0,30),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=section})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=content})
    return content
end

end

__modules["Components/Slider"]=function()
local UserInputService = game:GetService("UserInputService")
local State = __require("Core/State")
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
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

end

__modules["Components/Toggle"]=function()
local State = __require("Core/State")
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
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
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then render(value); Utility.SafeCallback(options.Callback, value) end end))
    cleanup:Add(button.Activated:Connect(function() if cleanup:IsAlive() then state:Set(not state:Get()) end end))
    cleanup:Add(function() Animation.Cancel(button); Animation.Cancel(knob) end)
    render(state:Get())
    return Base.Handle(row,state,cleanup)
end

end

__modules["Core/Engine"]=function()
local Players=game:GetService("Players")
local Theme=__require("Core/Theme")
local Window=__require("Core/Window")
local Config=__require("Services/Config")
local Animation=__require("Services/Animation")
local Cleanup=__require("Services/Cleanup")
local Utility=__require("Services/Utility")
local Dark=__require("Themes/Dark")
local Light=__require("Themes/Light")
local Custom=__require("Themes/Custom")

local Engine={Version="1.0.0",Themes={Dark=Dark,Light=Light},Windows={}}
Engine.__index=Engine

local function resolveParent()
    if gethui then local ok,result=pcall(gethui); if ok then return result end end
    local player=Players.LocalPlayer
    return player and player:WaitForChild("PlayerGui") or game:GetService("CoreGui")
end

function Engine.new()
    local self=setmetatable({},Engine)
    self.Theme=Theme.new(Dark)
    self.Windows={}
    self.Config=Config.new("AxiomUI")
    self._Cleanup=Cleanup.new()
    self._Destroyed=false
    self.Gui=Utility.Create("ScreenGui",{Name="AxiomUIEngine",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=resolveParent()})
    self.Toasts=Utility.Create("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),Size=UDim2.fromOffset(340,500),BackgroundTransparency=1,Parent=self.Gui})
    Utility.Create("UIListLayout",{VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,10),Parent=self.Toasts})
    return self
end

function Engine:CreateWindow(options)
    assert(not self._Destroyed,"Axiom has been destroyed")
    options=options or {}
    if options.Theme then self:SetTheme(options.Theme) end
    local window=Window.new(self,options)
    table.insert(self.Windows,window)
    return window
end

function Engine:SetTheme(theme)
    assert(not self._Destroyed,"Axiom has been destroyed")
    local resolved=type(theme)=="string" and self.Themes[theme] or theme
    assert(type(resolved)=="table","Unknown Axiom theme")
    self.Theme:Apply(resolved)
end

function Engine:CreateTheme(overrides) return Custom(overrides) end

function Engine:Notify(options)
    if self._Destroyed then return nil end
    options=options or {}; local t=self.Theme.Current
    local toast=Utility.Create("Frame",{Size=UDim2.fromOffset(0,82),BackgroundColor3=t.Surface,BackgroundTransparency=0.04,BorderSizePixel=0,ClipsDescendants=true,Parent=self.Toasts}); Utility.Corner(toast,UDim.new(0,12)); Utility.Stroke(toast,t.Stroke,0.35)
    Utility.Create("Frame",{Size=UDim2.fromOffset(4,82),BackgroundColor3=options.Color or t.Primary,BorderSizePixel=0,Parent=toast})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-32,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=options.Title or "Axiom",TextColor3=t.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=toast})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,35),Size=UDim2.new(1,-32,0,34),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Description or "",TextColor3=t.TextMuted,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=toast})
    Animation.Tween(toast,{Size=UDim2.fromOffset(340,82)},0.32)
    self._Cleanup:Add(task.delay(options.Duration or 4,function()
        if self._Destroyed or not toast.Parent then return end
        Animation.Tween(toast,{Size=UDim2.fromOffset(0,82),BackgroundTransparency=1},0.3)
        self._Cleanup:Add(task.delay(0.32,function() if toast.Parent then toast:Destroy() end end))
    end))
    return toast
end

function Engine:Destroy()
    if self._Destroyed then return end
    self._Destroyed=true
    -- Pop before destroying so a failing Window cannot stall or skip the registry.
    while #self.Windows>0 do
        local window=table.remove(self.Windows)
        pcall(function() window:Destroy() end)
    end
    self._Cleanup:Destroy()
    self.Config:Destroy()
    self.Theme:Destroy()
    if self.Gui then self.Gui:Destroy() end
    self.Gui=nil
    self.Toasts=nil
    self.Config=nil
    self.Theme=nil
end

return Engine

end

__modules["Core/Events"]=function()
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {}, _destroyed = false }, Signal)
end

function Signal:Connect(callback)
    assert(type(callback) == "function", "Signal callback must be a function")
    assert(not self._destroyed, "Cannot connect to a destroyed Signal")
    local connection = { Connected = true }
    self._listeners[connection] = callback
    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        if connection._owner then connection._owner._listeners[self] = nil end
        connection._owner = nil
    end
    connection._owner = self
    return connection
end

function Signal:Fire(...)
    if self._destroyed then return end
    for connection, callback in pairs(self._listeners) do
        if connection.Connected then
            task.spawn(function(...)
                if connection.Connected and not self._destroyed then callback(...) end
            end, ...)
        end
    end
end

function Signal:Destroy()
    self._destroyed = true
    for connection in pairs(self._listeners) do connection.Connected = false; connection._owner=nil end
    table.clear(self._listeners)
end

return Signal

end

__modules["Core/State"]=function()
local Signal = __require("Core/Events")
local State = {}
State.__index = State

function State.new(initialValue)
    return setmetatable({ _value = initialValue, Changed = Signal.new(), _destroyed=false }, State)
end

function State:Get()
    return self._value
end

function State:Set(value)
    if self._destroyed then return end
    if self._value == value then return end
    local previous = self._value
    self._value = value
    self.Changed:Fire(value, previous)
end

function State:Update(reducer)
    if self._destroyed then return end
    self:Set(reducer(self._value))
end

function State:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    self.Changed:Destroy()
    self._value=nil
end

return State

end

__modules["Core/Theme"]=function()
local Signal = __require("Core/Events")
local Theme = {}
Theme.__index = Theme

function Theme.new(initialTheme)
    return setmetatable({ Current = initialTheme, Changed = Signal.new(), _bindings = {} }, Theme)
end

function Theme:Bind(instance, property, token, transform)
    local binding = { Instance = instance, Property = property, Token = token, Transform = transform }
    table.insert(self._bindings, binding)
    binding.Connection=instance.Destroying:Connect(function()
        for index,item in ipairs(self._bindings) do
            if item==binding then table.remove(self._bindings,index) break end
        end
        binding.Instance=nil
    end)
    local value = self.Current[token]
    if transform then value = transform(value, self.Current) end
    if value ~= nil then instance[property] = value end
    return binding
end

function Theme:Apply(nextTheme)
    self.Current = nextTheme
    for index = #self._bindings, 1, -1 do
        local binding = self._bindings[index]
        if not binding.Instance or not binding.Instance.Parent then
            if binding.Connection then binding.Connection:Disconnect() end
            table.remove(self._bindings, index)
        else
            local value = nextTheme[binding.Token]
            if binding.Transform then value = binding.Transform(value, nextTheme) end
            if value ~= nil then binding.Instance[binding.Property] = value end
        end
    end
    self.Changed:Fire(nextTheme)
end

function Theme:Destroy()
    for _,binding in ipairs(self._bindings) do
        if binding.Connection then binding.Connection:Disconnect() end
        binding.Instance=nil
    end
    table.clear(self._bindings)
    self.Changed:Destroy()
end

return Theme

end

__modules["Core/Window"]=function()
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local Animation=__require("Services/Animation")
local Cleanup=__require("Services/Cleanup")
local Utility=__require("Services/Utility")
local Icons=__require("Services/Icons")
local Components={
    Button=__require("Components/Button"), Toggle=__require("Components/Toggle"),
    Slider=__require("Components/Slider"), Dropdown=__require("Components/Dropdown"),
    Input=__require("Components/Input"), Keybind=__require("Components/Keybind"),
    ColorPicker=__require("Components/ColorPicker"), Section=__require("Components/Section"),
    Card=__require("Components/Card"),
}
local Window={}; Window.__index=Window

local HEADER_HEIGHT=58
local WINDOW_RADIUS=14
local REFERENCE_VISUAL_WIDTH=500
local REFERENCE_VISUAL_HEIGHT=475
local DEFAULT_USER_SCALE=1
local MIN_USER_SCALE=0.75
local MAX_USER_SCALE=1.25
local MIN_RESIZE_WIDTH=420
local MIN_RESIZE_HEIGHT=360
local MOBILE_BREAKPOINT=600
local DESKTOP_BREAKPOINT=900
local MOBILE_MIN_RENDER_SCALE=0.85
local TWEEN_MINIMIZE=0.22
local TWEEN_RESTORE=0.26
local TWEEN_MAXIMIZE=0.30
local Z_INDEX={
    Background=1,
    Body=5,
    Sidebar=10,
    Content=10,
    Tab=15,
    Header=30,
    Resize=40,
    Overlay=100,
    Tooltip=110,
    Popup=120,
    Modal=150,
}

local function getViewportSize()
    local cam=workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1920,1080)
end

local function offsetPosition(position,x,y)
    return UDim2.new(position.X.Scale,position.X.Offset+x,position.Y.Scale,position.Y.Offset+y)
end

local function resolveReferenceSize(size,viewport)
    return Vector2.new(
        viewport.X*size.X.Scale+size.X.Offset,
        viewport.Y*size.Y.Scale+size.Y.Offset
    )
end

local function getResponsiveMetrics(userScale,referenceSize)
    local viewport=getViewportSize()
    local topLeft,bottomRight=Vector2.zero,Vector2.zero
    pcall(function() topLeft,bottomRight=GuiService:GetGuiInset() end)
    local safeMin,safeMax=Vector2.zero,viewport
    pcall(function()
        local area=GuiService:GetInsetArea(Enum.ScreenInsets.DeviceSafeInsets)
        local min=Vector2.new(math.max(0,area.Min.X),math.max(0,area.Min.Y))
        local max=Vector2.new(math.min(viewport.X,area.Max.X),math.min(viewport.Y,area.Max.Y))
        if max.X>min.X and max.Y>min.Y then safeMin,safeMax=min,max end
    end)
    local pureTouch=UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local mobile=viewport.X<MOBILE_BREAKPOINT or (UserInputService.TouchEnabled and viewport.Y<MOBILE_BREAKPOINT)
    local mode=mobile and "Mobile" or (viewport.X<DESKTOP_BREAKPOINT and "Tablet" or "Desktop")
    local margin=mode=="Desktop" and 24 or (mode=="Tablet" and 16 or 12)
    local left=math.max(topLeft.X,safeMin.X)+margin
    local top=math.max(topLeft.Y,safeMin.Y)+margin
    local right=math.max(bottomRight.X,viewport.X-safeMax.X)+margin
    local bottom=math.max(bottomRight.Y,viewport.Y-safeMax.Y)+margin
    local availableWidth=math.max(1,viewport.X-left-right)
    local availableHeight=math.max(1,viewport.Y-top-bottom)
    local reference=resolveReferenceSize(referenceSize,viewport)
    local finalScale
    local logicalWidth
    local logicalHeight

    if mode=="Mobile" then
        local portrait=viewport.Y>=viewport.X
        local baseVisualWidth=portrait and availableWidth or math.min(reference.X,availableWidth)
        local baseVisualHeight=portrait and math.min(reference.Y,availableHeight*0.86) or math.min(reference.Y,availableHeight)
        local visualWidth=math.min(availableWidth,baseVisualWidth*userScale)
        local visualHeight=math.min(availableHeight,baseVisualHeight*userScale)
        finalScale=math.max(MOBILE_MIN_RENDER_SCALE,userScale)
        logicalWidth=visualWidth/finalScale
        logicalHeight=visualHeight/finalScale
    else
        local fitScale=math.min(1,availableWidth/reference.X,availableHeight/reference.Y)
        finalScale=math.min(fitScale*userScale,availableWidth/reference.X,availableHeight/reference.Y)
        logicalWidth=reference.X
        logicalHeight=reference.Y
    end

    local visualWidth=logicalWidth*finalScale
    local visualHeight=logicalHeight*finalScale
    return {
        Mode=mode,
        PureTouch=pureTouch,
        Portrait=viewport.Y>=viewport.X,
        Margin=margin,
        Left=left,
        Top=top,
        Right=left+availableWidth,
        Bottom=top+availableHeight,
        AvailableWidth=availableWidth,
        AvailableHeight=availableHeight,
        Scale=finalScale,
        LogicalSize=UDim2.fromOffset(math.round(logicalWidth),math.round(logicalHeight)),
        VisualSize=Vector2.new(visualWidth,visualHeight),
        CenterPosition=UDim2.fromOffset(math.round(left+availableWidth/2),math.round(top+availableHeight/2)),
        MaximizedSize=UDim2.fromOffset(math.round(availableWidth/finalScale),math.round(availableHeight/finalScale)),
    }
end

local function makeDraggable(window, frame, handle)
    local dragging, dragInput, startInput, startCenter=false,nil,nil,nil
    local conns={}
    conns[1]=handle.InputBegan:Connect(function(input)
        if dragging then return end
        if window._WindowState.Maximized and not window._WindowState.Minimized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            window:_CommitScale()
            dragging=true
            dragInput=input
            startInput=input.Position
            startCenter=frame.AbsolutePosition+frame.AbsoluteSize/2
        end
    end)
    conns[2]=UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            if dragInput.UserInputType==Enum.UserInputType.Touch and input~=dragInput then return end
            if window._WindowState.Maximized and not window._WindowState.Minimized then return end
            local delta=input.Position-startInput
            local metrics=getResponsiveMetrics(window.UserScale,window.ReferenceSize)
            local halfSize=frame.AbsoluteSize/2
            local minX,maxX=metrics.Left+halfSize.X,metrics.Right-halfSize.X
            local minY,maxY=metrics.Top+halfSize.Y,metrics.Bottom-halfSize.Y
            local x=minX<=maxX and math.clamp(startCenter.X+delta.X,minX,maxX) or metrics.Left+metrics.AvailableWidth/2
            local y=minY<=maxY and math.clamp(startCenter.Y+delta.Y,minY,maxY) or metrics.Top+metrics.AvailableHeight/2
            frame.Position=UDim2.fromOffset(math.round(x),math.round(y))
            window._HasCustomPosition=true
            if window._WindowState.Minimized then
                window._WindowState.MinimizedPosition=frame.Position
                window._WindowState.PreviousPosition=offsetPosition(frame.Position,0,window._WindowState.MinimizeDeltaY or 0)
                if not window._WindowState.PreMinimizeMaximized then
                    window._PreferredPosition=window._WindowState.PreviousPosition
                end
            else
                window.OriginalPosition=frame.Position
                window._WindowState.PreviousPosition=frame.Position
                window._PreferredPosition=frame.Position
            end
        end
    end)
    conns[3]=UserInputService.InputEnded:Connect(function(input)
        if input==dragInput then dragging=false; dragInput=nil end
    end)
    for _,c in ipairs(conns) do window._Cleanup:Add(c) end
    window._Cleanup:Add(function() dragging=false; dragInput=nil; startInput=nil; startCenter=nil end)
end

local function attachContainerApi(container,context,parent)
    container.RootParent=parent
    container.CurrentParent=parent
    function container:AddSection(options)
        self.CurrentParent=Components.Section(context,self.CurrentParent,options)
        return self
    end
    function container:EndSection()
        self.CurrentParent=self.RootParent
        return self
    end
    for name,factory in pairs(Components) do
        if name~="Section" and name~="Card" then
            container["Add"..name]=function(self,options)
                return factory(context,self.CurrentParent,options)
            end
        end
    end
    function container:AddCard(options)
        return Components.Card(context,self.CurrentParent,options)
    end
    function container:AddPanel(options)
        options=options or {}
        local t=context.Theme.Current
        local panel=Utility.Create("Frame",{Name=options.Name or "Panel",Size=UDim2.new(1,0,0,options.MinHeight or 80),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=t.Surface,BackgroundTransparency=0.18,BorderSizePixel=0,Parent=self.CurrentParent})
        Utility.Corner(panel,UDim.new(0,12)); Utility.Stroke(panel,t.Stroke,0.48); Utility.Padding(panel,14)
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder,Parent=panel})
        if options.Name then
            Utility.Create("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=options.Name,TextColor3=t.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=panel})
        end
        return attachContainerApi({},context,panel)
    end
    return container
end

function Window.new(context,options)
    options=options or {}
    local userScale=tonumber(options.Scale) or DEFAULT_USER_SCALE
    if userScale~=userScale then userScale=DEFAULT_USER_SCALE end
    userScale=math.clamp(userScale,MIN_USER_SCALE,MAX_USER_SCALE)
    local referenceSize=options.Size or UDim2.fromOffset(REFERENCE_VISUAL_WIDTH,REFERENCE_VISUAL_HEIGHT)
    local initialMetrics=getResponsiveMetrics(userScale,referenceSize)
    local self=setmetatable({
        Context=context,
        Tabs={},ActiveTab=nil,
        Scale=initialMetrics.Scale,
        UserScale=userScale,
        ReferenceSize=referenceSize,
        DeviceMode=initialMetrics.Mode,
        _ResponsiveMetrics=initialMetrics,
        _ColumnGroups={},
        _HasCustomSize=false,
        _HasCustomPosition=false,
        _PreferredSize=nil,
        _PreferredPosition=nil,
        Minimized=false,Maximized=false,
        _Cleanup=Cleanup.new(),
        _TransitionId=0,
        _IsDestroyed=false,
        _WindowState={Minimized=false,Maximized=false,PreviousSize=nil,PreviousPosition=nil,PreMinimizeMaximized=nil,MinimizedPosition=nil,MinimizeDeltaY=0,IsAnimating=false}
    },Window)
    local t=context.Theme.Current

    -- ROOT is interaction/layout only. Keeping it fully transparent prevents a square
    -- acrylic layer from appearing below the rounded visual container.
    local root=Utility.Create("Frame",{
        Name="AxiomWindow",AnchorPoint=Vector2.new(0.5,0.5),Position=initialMetrics.CenterPosition,
        Size=initialMetrics.LogicalSize,BackgroundTransparency=1,
        BorderSizePixel=0,ClipsDescendants=false,ZIndex=Z_INDEX.Background,Parent=context.Gui,
    })
    local scale=Utility.Create("UIScale",{Scale=initialMetrics.Scale*0.965,Parent=root})
    local scaleTween=Animation.Tween(scale,{Scale=initialMetrics.Scale},0.34)
    if scaleTween then self._Cleanup:Add(scaleTween) end
    self._Cleanup:Add(function() Animation.Cancel(scale) end)

    -- Exactly one outer border: a rounded 1px background shell. Using a Frame instead
    -- of UIStroke avoids corner halos caused by stroke rasterization during UIScale.
    local windowVisual=Utility.Create("Frame",{
        Name="WindowVisual",Size=UDim2.fromScale(1,1),BackgroundColor3=t.Stroke,
        BackgroundTransparency=0.42,BorderSizePixel=0,ZIndex=Z_INDEX.Background,Parent=root
    })
    Utility.Corner(windowVisual,UDim.new(0,WINDOW_RADIUS))
    context.Theme:Bind(windowVisual,"BackgroundColor3","Stroke")

    local localBlur=options.Blur==true
    local acrylic=options.Acrylic~=false
    local visualTransparency=acrylic and math.min(0.22,t.AcrylicTransparency+0.04+(localBlur and 0.03 or 0)) or 0
    local windowClip=Utility.Create("Frame",{
        Name="WindowClip",Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundColor3=t.Background,
        BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,ZIndex=Z_INDEX.Background,Parent=windowVisual
    })
    Utility.Corner(windowClip,UDim.new(0,WINDOW_RADIUS-1))
    context.Theme:Bind(windowClip,"BackgroundColor3","Background")
    Utility.Create("UIGradient",{
        Rotation=38,
        Color=ColorSequence.new(t.Background,Color3.fromRGB(15,16,27)),
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,localBlur and 0 or 0.02),NumberSequenceKeypoint.new(0.62,localBlur and 0.02 or 0.06),NumberSequenceKeypoint.new(1,0)}),
        Parent=windowClip,
    })
    local openTween=Animation.Tween(windowClip,{BackgroundTransparency=visualTransparency},0.3)
    if openTween then self._Cleanup:Add(openTween) end

    -- TITLE BAR (Header) - dentro do clip, cantos arredondados via parent clip
    local top=Utility.Create("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,HEADER_HEIGHT),BackgroundColor3=t.Surface,BackgroundTransparency=0.58,BorderSizePixel=0,ZIndex=Z_INDEX.Header,Parent=windowClip})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,0),Size=UDim2.new(1,-24,0,1),BackgroundColor3=t.Stroke,BackgroundTransparency=0.5,BorderSizePixel=0,Parent=top})
    local titleLabel=Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,9),Size=UDim2.new(1,-180,0,21),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=options.Title or "AXIOM",TextColor3=t.Text,TextSize=13,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})
    local subtitleLabel=Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,29),Size=UDim2.new(1,-180,0,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Subtitle or "UI ENGINE",TextColor3=t.TextMuted,TextSize=9,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})

    local function topButton(text,x,callback,color)
        local button=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,x,0,13),Size=UDim2.fromOffset(32,32),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.22,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text=text,TextColor3=color or t.TextMuted,TextSize=14,Parent=top})
        Utility.Corner(button,UDim.new(0,8)); Utility.Stroke(button,t.Stroke,0.68)
        self._Cleanup:Add(button.MouseEnter:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceHover,TextColor3=color or t.Text}) end))
        self._Cleanup:Add(button.MouseLeave:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceAlt,TextColor3=color or t.TextMuted}) end))
        self._Cleanup:Add(button.Activated:Connect(callback))
        return button
    end
    topButton("—",-94,function() self:Minimize() end,t.Primary)
    topButton("□",-56,function() self:Maximize() end,t.Secondary)
    topButton("×",-18,function() self:Close() end,Color3.fromRGB(187,91,255))

    -- BODY: CanvasGroup para fade controlado no minimize
    local body=Utility.Create("CanvasGroup",{Name="Body",Position=UDim2.fromOffset(0,HEADER_HEIGHT),Size=UDim2.new(1,0,1,-HEADER_HEIGHT),BackgroundTransparency=1,BorderSizePixel=0,GroupTransparency=0,ZIndex=Z_INDEX.Body,Parent=windowClip})

    local sidebar=Utility.Create("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,88,1,0),BackgroundColor3=t.Surface,BackgroundTransparency=0.64,BorderSizePixel=0,ZIndex=Z_INDEX.Sidebar,Parent=body})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,12),Size=UDim2.new(0,1,1,-24),BackgroundColor3=t.Stroke,BackgroundTransparency=0.52,BorderSizePixel=0,Parent=sidebar})
    local tabList=Utility.Create("Frame",{Position=UDim2.fromOffset(15,18),Size=UDim2.new(1,-30,1,-92),BackgroundTransparency=1,Parent=sidebar})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,9),HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=tabList})
    local status=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-16),Size=UDim2.fromOffset(56,56),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=sidebar})
    Utility.Corner(status,UDim.new(0,11)); Utility.Stroke(status,t.Stroke,0.62)
    local statusDot=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=t.Primary,BorderSizePixel=0,Parent=status})
    Utility.Corner(statusDot,UDim.new(1,0)); Utility.Create("UIGradient",{Color=ColorSequence.new(t.Primary,t.Secondary),Rotation=45,Parent=statusDot})

    -- Content dentro do Body, com offset correto (22px abaixo do header)
    local content=Utility.Create("Frame",{Position=UDim2.fromOffset(110,22),Size=UDim2.new(1,-132,1,-44),BackgroundTransparency=1,ZIndex=Z_INDEX.Content,Parent=body})

    -- Dedicated stacking contexts keep transient UI above every page/control while
    -- preserving WindowClip as the single rounded clipping boundary.
    local overlayLayer=Utility.Create("Frame",{Name="OverlayLayer",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,Active=false,ZIndex=Z_INDEX.Overlay,Parent=windowClip})
    local tooltipLayer=Utility.Create("Frame",{Name="Tooltips",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,Active=false,ZIndex=Z_INDEX.Tooltip,Parent=overlayLayer})
    local popupLayer=Utility.Create("Frame",{Name="Popups",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,Active=false,ZIndex=Z_INDEX.Popup,Parent=overlayLayer})
    local modalLayer=Utility.Create("Frame",{Name="Modals",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,Active=false,ZIndex=Z_INDEX.Modal,Parent=overlayLayer})

    self.Root=root
    self.UIScale=scale
    self.WindowVisual=windowVisual
    self.WindowClip=windowClip
    self.TitleBar=top
    self.TitleLabel=titleLabel
    self.SubtitleLabel=subtitleLabel
    self.Body=body
    self.Sidebar=sidebar
    self.TabList=tabList
    self.Content=content
    self.Status=status
    self.OverlayLayer=overlayLayer
    self.TooltipLayer=tooltipLayer
    self.PopupLayer=popupLayer
    self.ModalLayer=modalLayer
    self.OriginalSize=root.Size
    self.OriginalPosition=root.Position
    self._WindowState.PreviousSize=root.Size
    self._WindowState.PreviousPosition=root.Position
    makeDraggable(self,root,top)

    -- RESIZE HANDLE: completamente invisível, dentro do clip, sem artefato quadrado
    -- Detecta mouse mas não mostra quadrado branco. Posicionado 4px dentro da borda para respeitar radius 18.
    local resize=Utility.Create("TextButton",{
        Name="ResizeHandle",
        AnchorPoint=Vector2.new(1,1),
        Position=UDim2.new(1,-4,1,-4),
        Size=UDim2.fromOffset(20,20),
        BackgroundTransparency=1,
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,
        AutoButtonColor=false,
        Text="",
        TextTransparency=1,
        ZIndex=Z_INDEX.Resize,
        Parent=windowClip
    })
    self.ResizeHandle=resize

    -- Resize logic centralizada, sem leak, respeitando estados e limites
    local resizing,resizeInput,resizeStart,sizeStart=false,nil,nil,nil
    local c1=resize.InputBegan:Connect(function(input)
        if resizing then return end
        if self._ResponsiveMetrics.PureTouch or self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            self:_CommitScale()
            resizing=true
            resizeInput=input
            resizeStart=input.Position
            sizeStart=root.AbsoluteSize/self.Scale
        end
    end)
    local c2=UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            if resizeInput.UserInputType==Enum.UserInputType.Touch and input~=resizeInput then return end
            local delta=(input.Position-resizeStart)/self.Scale
            local metrics=getResponsiveMetrics(self.UserScale,self.ReferenceSize)
            local center=root.AbsolutePosition+root.AbsoluteSize/2
            local maxVisualW=math.max(1,2*math.min(center.X-metrics.Left,metrics.Right-center.X))
            local maxVisualH=math.max(1,2*math.min(center.Y-metrics.Top,metrics.Bottom-center.Y))
            local maxW=math.min(metrics.AvailableWidth,maxVisualW)/self.Scale
            local maxH=math.min(metrics.AvailableHeight,maxVisualH)/self.Scale
            local newW=math.clamp(sizeStart.X+delta.X,math.min(MIN_RESIZE_WIDTH,maxW),maxW)
            local newH=math.clamp(sizeStart.Y+delta.Y,math.min(MIN_RESIZE_HEIGHT,maxH),maxH)
            root.Size=UDim2.fromOffset(newW,newH)
            self._HasCustomSize=true
            self._PreferredSize=root.Size
            self.OriginalSize=root.Size
            self._WindowState.PreviousSize=root.Size
            self:_UpdateDeviceLayout(metrics)
        end
    end)
    local c3=UserInputService.InputEnded:Connect(function(input)
        if input==resizeInput then resizing=false; resizeInput=nil end
    end)
    self._Cleanup:Add(c1); self._Cleanup:Add(c2); self._Cleanup:Add(c3)
    self._Cleanup:Add(function() resizing=false; resizeInput=nil; resizeStart=nil; sizeStart=nil end)
    self._Cleanup:Add(root.Destroying:Connect(function() if not self._IsDestroyed then self:Destroy() end end))

    self:_UpdateDeviceLayout(initialMetrics)
    local viewportConnection
    local function bindViewport(reapply)
        if viewportConnection then viewportConnection:Disconnect(); viewportConnection=nil end
        local camera=workspace.CurrentCamera
        if camera then
            viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:_ApplyResponsiveLayout(true)
            end)
        end
        if reapply~=false then self:_ApplyResponsiveLayout(false) end
    end
    self._Cleanup:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() bindViewport(true) end))
    self._Cleanup:Add(GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function() self:_ApplyResponsiveLayout(true) end))
    self._Cleanup:Add(function() if viewportConnection then viewportConnection:Disconnect(); viewportConnection=nil end end)
    bindViewport(false)

    return self
end

function Window:_Delay(seconds,callback)
    local thread=task.delay(seconds,function()
        if not self._IsDestroyed then callback() end
    end)
    self._Cleanup:Add(thread)
    return thread
end

function Window:_CommitScale()
    if not self.UIScale then return end
    Animation.Cancel(self.UIScale)
    self.UIScale.Scale=self.Scale
end

function Window:GetDeviceMode()
    return self.DeviceMode
end

function Window:_UpdateColumnGroups()
    local contentWidth=self._ContentLogicalWidth or 0
    if contentWidth<=0 and self.Content and self.Content.AbsoluteSize.X>0 and self.UIScale and self.UIScale.Scale>0 then
        contentWidth=self.Content.AbsoluteSize.X/self.UIScale.Scale
    end
    local stacked=(self.DeviceMode=="Mobile" and self._ResponsiveMetrics.Portrait) or contentWidth<340
    for _,group in ipairs(self._ColumnGroups) do
        if group.Holder.Parent then
            group.Layout.FillDirection=stacked and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
            group.Layout.Padding=UDim.new(0,group.Gap)
            if stacked then
                group.Left.Size=UDim2.new(1,0,0,0)
                group.Right.Size=UDim2.new(1,0,0,0)
            else
                group.Left.Size=UDim2.new(group.Ratio,-group.Gap/2,0,0)
                group.Right.Size=UDim2.new(1-group.Ratio,-group.Gap/2,0,0)
            end
        end
    end
end

function Window:_UpdateDeviceLayout(metrics,logicalSize)
    self.DeviceMode=metrics.Mode
    self._ResponsiveMetrics=metrics
    local sidebarWidth
    local contentGap
    local rightPadding
    local tabSize
    local tabInset
    local statusSize
    if metrics.Mode=="Mobile" then
        sidebarWidth=56; contentGap=10; rightPadding=10; tabSize=48; tabInset=4; statusSize=48
    elseif metrics.Mode=="Tablet" then
        sidebarWidth=72; contentGap=14; rightPadding=14; tabSize=52; tabInset=10; statusSize=52
    else
        sidebarWidth=88; contentGap=22; rightPadding=22; tabSize=56; tabInset=15; statusSize=56
    end
    local contentX=sidebarWidth+contentGap
    local layoutSize=logicalSize or self.Root.Size
    self._ContentLogicalWidth=math.max(0,layoutSize.X.Offset-contentX-rightPadding)
    self.Sidebar.Size=UDim2.new(0,sidebarWidth,1,0)
    self.TabList.Position=UDim2.fromOffset(tabInset,18)
    self.TabList.Size=UDim2.new(1,-tabInset*2,1,-92)
    self.Content.Position=UDim2.fromOffset(contentX,22)
    self.Content.Size=UDim2.new(1,-contentX-rightPadding,1,-44)
    self.Status.Size=UDim2.fromOffset(statusSize,statusSize)
    self.Status.Position=UDim2.new(0.5,0,1,-math.max(10,tabInset))
    for _,tab in ipairs(self.Tabs) do
        if tab.Button then tab.Button.Size=UDim2.fromOffset(tabSize,metrics.Mode=="Mobile" and 48 or 52) end
        if metrics.PureTouch and tab._HideTooltip then tab._HideTooltip(true) end
    end
    self.ResizeHandle.Visible=not metrics.PureTouch and not self._WindowState.Minimized and not self._WindowState.Maximized
    self:_UpdateColumnGroups()
end

function Window:_GetMaximizedBounds()
    local metrics=getResponsiveMetrics(self.UserScale,self.ReferenceSize)
    return UDim2.fromOffset(
        math.round(metrics.AvailableWidth/self.Scale),
        math.round(metrics.AvailableHeight/self.Scale)
    ),metrics.CenterPosition,metrics
end

function Window:_ClampPosition(position,size,metrics)
    metrics=metrics or getResponsiveMetrics(self.UserScale,self.ReferenceSize)
    local halfWidth=size.X.Offset*self.Scale/2
    local halfHeight=size.Y.Offset*self.Scale/2
    local minX,maxX=metrics.Left+halfWidth,metrics.Right-halfWidth
    local minY,maxY=metrics.Top+halfHeight,metrics.Bottom-halfHeight
    local x=minX<=maxX and math.clamp(position.X.Offset,minX,maxX) or metrics.Left+metrics.AvailableWidth/2
    local y=minY<=maxY and math.clamp(position.Y.Offset,minY,maxY) or metrics.Top+metrics.AvailableHeight/2
    return UDim2.fromOffset(math.round(x),math.round(y))
end

function Window:_GetResponsiveRestoreGeometry(metrics)
    local preservingRestoreState=self._WindowState.Maximized or self._WindowState.Minimized
    local currentSize=preservingRestoreState and (self._WindowState.PreviousSize or self.OriginalSize) or self.Root.Size
    local currentPosition=preservingRestoreState and (self._WindowState.PreviousPosition or self.OriginalPosition) or self.Root.Position
    local targetSize=self._HasCustomSize and (self._PreferredSize or currentSize) or metrics.LogicalSize
    local maxWidth=metrics.AvailableWidth/metrics.Scale
    local maxHeight=metrics.AvailableHeight/metrics.Scale
    targetSize=UDim2.fromOffset(
        math.round(math.clamp(targetSize.X.Offset,math.min(MIN_RESIZE_WIDTH,maxWidth),maxWidth)),
        math.round(math.clamp(targetSize.Y.Offset,math.min(MIN_RESIZE_HEIGHT,maxHeight),maxHeight))
    )
    local targetPosition=self._HasCustomPosition and (self._PreferredPosition or currentPosition) or metrics.CenterPosition
    return targetSize,self:_ClampPosition(targetPosition,targetSize,metrics)
end

function Window:_ApplyResponsiveLayout(animate)
    if self._IsDestroyed then return end
    local metrics=getResponsiveMetrics(self.UserScale,self.ReferenceSize)
    self._TransitionId+=1
    self._WindowState.IsAnimating=false
    self.Scale=metrics.Scale
    local restoreSize,restorePosition=self:_GetResponsiveRestoreGeometry(metrics)
    local targetSize=restoreSize
    local targetPosition=restorePosition

    if self._WindowState.Minimized then
        local minimizedRestoreSize=restoreSize
        local minimizedRestorePosition=restorePosition
        self._WindowState.PreviousSize=restoreSize
        self._WindowState.PreviousPosition=restorePosition
        if self._WindowState.PreMinimizeMaximized then
            minimizedRestoreSize=metrics.MaximizedSize
            minimizedRestorePosition=metrics.CenterPosition
        end
        local deltaY=math.max(0,(minimizedRestoreSize.Y.Offset*metrics.Scale-HEADER_HEIGHT*metrics.Scale)/2)
        self._WindowState.MinimizeDeltaY=deltaY
        targetSize=UDim2.fromOffset(minimizedRestoreSize.X.Offset,HEADER_HEIGHT)
        targetPosition=offsetPosition(minimizedRestorePosition,0,-deltaY)
        self.Body.Visible=false
        self.Body.GroupTransparency=1
    elseif self._WindowState.Maximized then
        targetSize=metrics.MaximizedSize
        self._WindowState.PreviousSize=restoreSize
        self._WindowState.PreviousPosition=restorePosition
        self.Body.Visible=true
        self.Body.GroupTransparency=0
    else
        self.OriginalSize=restoreSize
        self.OriginalPosition=restorePosition
        self._WindowState.PreviousSize=restoreSize
        self._WindowState.PreviousPosition=restorePosition
        self.Body.Visible=true
        self.Body.GroupTransparency=0
    end

    self:_UpdateDeviceLayout(metrics,targetSize)
    if animate then
        Animation.Tween(self.UIScale,{Scale=metrics.Scale},0.22)
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPosition},0.22)
    else
        Animation.Cancel(self.UIScale)
        Animation.Cancel(self.Root)
        self.UIScale.Scale=metrics.Scale
        self.Root.Size=targetSize
        self.Root.Position=targetPosition
    end
end

function Window:AddTab(options)
    assert(not self._IsDestroyed,"Cannot add a tab to a destroyed Window")
    options=options or {}
    local t=self.Context.Theme.Current
    local button=Utility.Create("TextButton",{Size=UDim2.fromOffset(56,52),BackgroundColor3=t.Primary,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",ZIndex=Z_INDEX.Tab,Parent=self.TabList})
    Utility.Corner(button,UDim.new(0,10)); Utility.Stroke(button,t.Primary,1)
    local gradient=Utility.Create("UIGradient",{Rotation=135,Color=ColorSequence.new(Color3.fromRGB(151,48,255),Color3.fromRGB(82,35,204)),Parent=button})
    local icon=Utility.Create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,Image=Icons.Get(options.Icon),ImageColor3=t.TextMuted,ImageTransparency=0,ImageRectOffset=Vector2.zero,ImageRectSize=Vector2.zero,ZIndex=Z_INDEX.Tab+1,Parent=button})
    local tooltip=Utility.Create("TextLabel",{AnchorPoint=Vector2.new(0,0.5),Size=UDim2.fromOffset(0,30),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.04,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=options.Name or "Tab",TextColor3=t.Text,TextSize=11,Visible=false,ClipsDescendants=true,ZIndex=Z_INDEX.Tooltip,Parent=self.TooltipLayer})
    Utility.Corner(tooltip,UDim.new(0,7)); Utility.Stroke(tooltip,t.Stroke,0.45)
    local tooltipRevision=0
    local function positionTooltip()
        local currentScale=self.UIScale.Scale
        local relativePosition=(button.AbsolutePosition-self.WindowClip.AbsolutePosition)/currentScale
        local buttonSize=button.AbsoluteSize/currentScale
        tooltip.Position=UDim2.fromOffset(math.round(relativePosition.X+buttonSize.X+12),math.round(relativePosition.Y+buttonSize.Y/2))
    end
    local function hideTooltip(immediate)
        tooltipRevision+=1
        local revision=tooltipRevision
        if immediate then
            Animation.Cancel(tooltip)
            if tooltip.Parent then tooltip.Size=UDim2.fromOffset(0,30); tooltip.Visible=false end
            return
        end
        Animation.Tween(tooltip,{Size=UDim2.fromOffset(0,30)},0.12)
        self:_Delay(0.13,function()
            if revision==tooltipRevision and tooltip.Parent then tooltip.Visible=false end
        end)
    end
    if not self._ResponsiveMetrics.PureTouch then
        self._Cleanup:Add(button.MouseEnter:Connect(function()
            if not tooltip.Parent then return end
            tooltipRevision+=1
            positionTooltip()
            tooltip.Visible=true
            Animation.Tween(tooltip,{Size=UDim2.fromOffset(110,30)},0.16)
        end))
        self._Cleanup:Add(button.MouseLeave:Connect(function() hideTooltip(false) end))
    end
    self._Cleanup:Add(function() hideTooltip(true) end)
    local page=Utility.Create("ScrollingFrame",{Name=(options.Name or "Tab").."Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=t.Primary,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false,ZIndex=Z_INDEX.Content,Parent=self.Content})
    Utility.Padding(page,2); Utility.Create("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page})
    local tab=attachContainerApi({Window=self,Button=button,Icon=icon,Gradient=gradient,Tooltip=tooltip,_HideTooltip=hideTooltip,Page=page,Options=options},self.Context,page)
    function tab:Select() if self.Window then self.Window:SelectTab(self) end end
    function tab:AddColumnGroup(groupOptions)
        groupOptions=groupOptions or {}
        local gap=groupOptions.Gap or 12
        local ratio=groupOptions.Ratio or 0.62
        local holder=Utility.Create("Frame",{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=self.CurrentParent})
        local left=Utility.Create("Frame",{Size=UDim2.new(ratio,-gap/2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=holder})
        local right=Utility.Create("Frame",{Size=UDim2.new(1-ratio,-gap/2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=holder})
        local layout=Utility.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap),VerticalAlignment=Enum.VerticalAlignment.Top,Parent=holder})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=left})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=right})
        table.insert(self.Window._ColumnGroups,{Holder=holder,Left=left,Right=right,Layout=layout,Ratio=ratio,Gap=gap})
        self.Window:_UpdateColumnGroups()
        return attachContainerApi({},self.Window.Context,left),attachContainerApi({},self.Window.Context,right)
    end
    self._Cleanup:Add(button.Activated:Connect(function() if not self._IsDestroyed then tab:Select() end end))
    table.insert(self.Tabs,tab)
    self:_UpdateDeviceLayout(self._ResponsiveMetrics)
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self._IsDestroyed then return end
    for _,item in ipairs(self.Tabs) do
        local active=item==tab
        item.Page.Visible=active
        Animation.Tween(item.Button,{BackgroundTransparency=active and 0 or 1})
        Animation.Tween(item.Icon,{ImageColor3=active and Color3.new(1,1,1) or self.Context.Theme.Current.TextMuted})
    end
    self.ActiveTab=tab
end

function Window:_DoMinimize()
    if self._WindowState.IsAnimating then return end
    self:_CommitScale()
    self._TransitionId+=1
    local token=self._TransitionId
    self._WindowState.IsAnimating=true
    self._WindowState.PreMinimizeMaximized=self._WindowState.Maximized
    if not self._WindowState.Maximized then
        self._WindowState.PreviousSize=self.Root.Size
        self._WindowState.PreviousPosition=self.Root.Position
    end
    local deltaY=math.max(0,(self.Root.AbsoluteSize.Y-HEADER_HEIGHT*self.Scale)/2)
    self._WindowState.MinimizeDeltaY=deltaY
    self._WindowState.MinimizedPosition=offsetPosition(self.Root.Position,0,-deltaY)
    self._WindowState.Minimized=true
    self.Minimized=true
    for _,tab in ipairs(self.Tabs) do if tab._HideTooltip then tab._HideTooltip(true) end end
    Animation.Tween(self.Body,{GroupTransparency=1},0.12)
    self:_Delay(0.12,function()
        if token~=self._TransitionId or not self._WindowState.Minimized then return end
        self.Body.Visible=false
        self.ResizeHandle.Visible=false
        local minimizedSize=UDim2.new(self.Root.Size.X.Scale,self.Root.Size.X.Offset,0,HEADER_HEIGHT)
        Animation.Tween(self.Root,{Size=minimizedSize,Position=self._WindowState.MinimizedPosition},TWEEN_MINIMIZE,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        self:_Delay(TWEEN_MINIMIZE,function()
            if token==self._TransitionId then self._WindowState.IsAnimating=false end
        end)
    end)
end

function Window:_DoRestoreFromMinimize()
    if self._WindowState.IsAnimating then return end
    self._TransitionId+=1
    local token=self._TransitionId
    self._WindowState.IsAnimating=true
    self._WindowState.Minimized=false
    self.Minimized=false

    local targetSize=self._WindowState.PreviousSize or self.OriginalSize
    local targetPos=offsetPosition(self.Root.Position,0,self._WindowState.MinimizeDeltaY or 0)
    if self._WindowState.PreMinimizeMaximized then
        self._WindowState.Maximized=true
        self.Maximized=true
        local metrics
        targetSize,targetPos,metrics=self:_GetMaximizedBounds()
        self:_UpdateDeviceLayout(metrics,targetSize)
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_RESTORE)
        self:_Delay(TWEEN_RESTORE,function()
            if token~=self._TransitionId then return end
            self.Body.Visible=true
            self.ResizeHandle.Visible=false
            Animation.Tween(self.Body,{GroupTransparency=0},0.16)
            self._WindowState.IsAnimating=false
        end)
    else
        self._WindowState.Maximized=false
        self.Maximized=false
        targetPos=self:_ClampPosition(targetPos,targetSize)
        self:_UpdateDeviceLayout(self._ResponsiveMetrics,targetSize)
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_RESTORE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        self:_Delay(TWEEN_RESTORE,function()
            if token~=self._TransitionId then return end
            self.Body.Visible=true
            self.ResizeHandle.Visible=not self._ResponsiveMetrics.PureTouch
            Animation.Tween(self.Body,{GroupTransparency=0},0.16)
            self._WindowState.IsAnimating=false
        end)
        self._WindowState.PreviousPosition=targetPos
        self.OriginalPosition=targetPos
    end
    self.OriginalSize=targetSize
end

function Window:Minimize()
    if self._IsDestroyed then return end
    if self._WindowState.Minimized then
        self:_DoRestoreFromMinimize()
    else
        self:_DoMinimize()
    end
end

function Window:Maximize()
    if self._IsDestroyed then return end
    if self._WindowState.IsAnimating then return end
    self:_CommitScale()
    if self._WindowState.Minimized then
        self._WindowState.PreMinimizeMaximized=true
        self:_DoRestoreFromMinimize()
        return
    end

    self._TransitionId+=1
    local token=self._TransitionId
    if self._WindowState.Maximized then
        self._WindowState.IsAnimating=true
        self._WindowState.Maximized=false
        self.Maximized=false
        local targetSize=self._WindowState.PreviousSize or self.OriginalSize
        local targetPos=self:_ClampPosition(self._WindowState.PreviousPosition or self.OriginalPosition,targetSize)
        self:_UpdateDeviceLayout(self._ResponsiveMetrics,targetSize)
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_MAXIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        self:_Delay(TWEEN_MAXIMIZE,function()
            if token~=self._TransitionId then return end
            self.ResizeHandle.Visible=not self._ResponsiveMetrics.PureTouch
            self._WindowState.IsAnimating=false
            self.OriginalSize=targetSize
            self.OriginalPosition=targetPos
        end)
    else
        self._WindowState.PreviousSize=self.Root.Size
        self._WindowState.PreviousPosition=self.Root.Position
        self._WindowState.IsAnimating=true
        self._WindowState.Maximized=true
        self.Maximized=true
        local maxSize,maxPos,metrics=self:_GetMaximizedBounds()
        self:_UpdateDeviceLayout(metrics,maxSize)
        Animation.Tween(self.Root,{Size=maxSize,Position=maxPos},TWEEN_MAXIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        self:_Delay(TWEEN_MAXIMIZE,function()
            if token~=self._TransitionId then return end
            self.ResizeHandle.Visible=false
            self._WindowState.IsAnimating=false
        end)
    end
end

function Window:Close()
    if self._IsDestroyed then return end
    self._TransitionId+=1
    Animation.Tween(self.WindowClip,{BackgroundTransparency=1},0.20)
    Animation.Tween(self.WindowVisual,{BackgroundTransparency=1},0.20)
    Animation.Tween(self.UIScale,{Scale=self.Scale*0.94},0.24)
    self:_Delay(0.25,function() self:Destroy() end)
end

function Window:SetTheme(theme) if not self._IsDestroyed then self.Context.Theme:Apply(theme) end end

function Window:Destroy()
    if self._IsDestroyed then return end
    self._IsDestroyed=true
    self._TransitionId+=1
    local context=self.Context
    local root=self.Root
    self._Cleanup:Destroy()
    Animation.Cancel(self.Body)
    Animation.Cancel(self.WindowClip)
    Animation.Cancel(self.WindowVisual)
    Animation.Cancel(root)
    if root then pcall(function() root:Destroy() end) end
    if context and context.Windows then
        for i,w in ipairs(context.Windows) do
            if w==self then table.remove(context.Windows,i) break end
        end
    end
    for _,tab in ipairs(self.Tabs) do
        tab.Window=nil
        tab.Button=nil
        tab.Icon=nil
        tab.Gradient=nil
        tab.Tooltip=nil
        tab._HideTooltip=nil
        tab.Page=nil
        tab.RootParent=nil
        tab.CurrentParent=nil
    end
    table.clear(self.Tabs)
    table.clear(self._ColumnGroups)
    self.ActiveTab=nil
    self.ResizeHandle=nil
    self.UIScale=nil
    self.Body=nil
    self.Sidebar=nil
    self.TabList=nil
    self.Content=nil
    self.Status=nil
    self.OverlayLayer=nil
    self.TooltipLayer=nil
    self.PopupLayer=nil
    self.ModalLayer=nil
    self.TitleBar=nil
    self.TitleLabel=nil
    self.SubtitleLabel=nil
    self.WindowClip=nil
    self.WindowVisual=nil
    self.Root=nil
    self.Context=nil
    self.ReferenceSize=nil
    self._ResponsiveMetrics=nil
    self._ColumnGroups=nil
    self._HasCustomSize=nil
    self._HasCustomPosition=nil
    self._PreferredSize=nil
    self._PreferredPosition=nil
    self._Cleanup=nil
    self._WindowState=nil
end
return Window

end

__modules["Services/Animation"]=function()
local TweenService = game:GetService("TweenService")
local Animation = {}
local activeTweens=setmetatable({},{__mode="k"})

function Animation.Tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then return nil end
    local previous=activeTweens[instance]
    if previous then pcall(function() previous:Cancel() end) end
    local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    activeTweens[instance]=tween
    tween.Completed:Once(function()
        if activeTweens[instance]==tween then activeTweens[instance]=nil end
    end)
    tween:Play()
    return tween
end

function Animation.Cancel(instance)
    local tween=activeTweens[instance]
    if tween then pcall(function() tween:Cancel() end); activeTweens[instance]=nil end
end

function Animation.Hover(gui, normal, hovered, cleanup)
    local enter=gui.MouseEnter:Connect(function() Animation.Tween(gui, hovered) end)
    local leave=gui.MouseLeave:Connect(function() Animation.Tween(gui, normal) end)
    if cleanup then cleanup:Add(enter); cleanup:Add(leave) end
    return enter,leave
end

function Animation.Ripple(button, color, cleanup)
    local ripple = Instance.new("Frame")
    ripple.Name = "AxiomRipple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.fromScale(0.5, 0.5)
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.72
    ripple.ZIndex = button.ZIndex + 2
    ripple.Parent = button
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    local target = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.8
    Animation.Tween(ripple, { Size = UDim2.fromOffset(target, target), BackgroundTransparency = 1 }, 0.42)
    local thread=task.delay(0.45, function() if ripple.Parent then ripple:Destroy() end end)
    if cleanup then cleanup:Add(thread) end
end

return Animation

end

__modules["Services/Cleanup"]=function()
local Cleanup={}
Cleanup.__index=Cleanup

function Cleanup.new()
    return setmetatable({_tasks={},_destroyed=false},Cleanup)
end

function Cleanup:Add(item)
    if item==nil then return nil end
    if self._destroyed then
        self:_Clean(item)
        return item
    end
    table.insert(self._tasks,item)
    return item
end

function Cleanup:_Clean(item)
    local kind=typeof(item)
    if kind=="RBXScriptConnection" then
        if item.Connected then item:Disconnect() end
    elseif kind=="Instance" then
        if item:IsA("TweenBase") then item:Cancel() end
        item:Destroy()
    elseif kind=="function" then
        item()
    elseif kind=="thread" then
        pcall(task.cancel,item)
    elseif type(item)=="table" then
        if item.Disconnect then item:Disconnect()
        elseif item.Cancel then item:Cancel()
        elseif item.Destroy then item:Destroy() end
    end
end

function Cleanup:IsAlive()
    return not self._destroyed
end

function Cleanup:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    for i=#self._tasks,1,-1 do
        pcall(function() self:_Clean(self._tasks[i]) end)
        self._tasks[i]=nil
    end
end

return Cleanup

end

__modules["Services/Config"]=function()
local HttpService=game:GetService("HttpService")
local Config={}; Config.__index=Config

function Config.new(namespace)
    return setmetatable({Namespace=namespace or "Axiom",Values={},Profiles={},AutoSave=false,AutoSaveProfile="default",_connections={},_destroyed=false},Config)
end

function Config:Register(key,control)
    if self._destroyed then return control end
    if self._connections[key] then self._connections[key]:Disconnect() end
    self.Values[key]=control
    if control.Changed then
        self._connections[key]=control.Changed:Connect(function()
            if self.AutoSave then
                local revision=tick(); self._pendingRevision=revision
                task.delay(0.35,function() if not self._destroyed and self._pendingRevision==revision then self:Save(self.AutoSaveProfile) end end)
            end
        end)
    end
    if control._OnDestroy then
        control:_OnDestroy(function()
            if self.Values[key]==control then
                self.Values[key]=nil
                if self._connections[key] then self._connections[key]:Disconnect(); self._connections[key]=nil end
            end
        end)
    end
    return control
end

function Config:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    self.AutoSave=false
    self._pendingRevision=nil
    for key,connection in pairs(self._connections) do connection:Disconnect(); self._connections[key]=nil end
    table.clear(self.Values)
    table.clear(self.Profiles)
end

function Config:EnableAutoSave(enabled,profile)
    self.AutoSave=enabled~=false
    self.AutoSaveProfile=profile or self.AutoSaveProfile
end

function Config:Serialize()
    local output={}
    for key,control in pairs(self.Values) do
        local value=control:Get()
        if typeof(value)=="Color3" then value={__type="Color3",r=value.R,g=value.G,b=value.B}
        elseif typeof(value)=="EnumItem" then value={__type="EnumItem",enum=tostring(value.EnumType),name=value.Name} end
        output[key]=value
    end
    return output
end

function Config:LoadTable(data)
    for key,value in pairs(data or {}) do
        local control=self.Values[key]
        if control then
            if type(value)=="table" and value.__type=="Color3" then value=Color3.new(value.r,value.g,value.b)
            elseif type(value)=="table" and value.__type=="EnumItem" and value.enum=="Enum.KeyCode" then value=Enum.KeyCode[value.name] end
            control:Set(value)
        end
    end
end

function Config:Save(profile)
    if self._destroyed then return nil end
    profile=profile or "default"; local data=self:Serialize(); self.Profiles[profile]=data
    if writefile then
        if makefolder then pcall(makefolder,self.Namespace) end
        writefile(self.Namespace.."/"..profile..".json",HttpService:JSONEncode(data))
    end
    return data
end

function Config:Load(profile)
    if self._destroyed then return false end
    profile=profile or "default"; local data=self.Profiles[profile]
    if not data and readfile and isfile and isfile(self.Namespace.."/"..profile..".json") then
        local ok,result=pcall(function() return HttpService:JSONDecode(readfile(self.Namespace.."/"..profile..".json")) end)
        if ok then data=result end
    end
    self:LoadTable(data or {}); return data~=nil
end

return Config

end

__modules["Services/Icons"]=function()
local Icons = {
    home = "rbxassetid://10723407389",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10747373176",
    eye = "rbxassetid://10723346959",
    search = "rbxassetid://10734943674",
    sliders = "rbxassetid://10734951847",
    palette = "rbxassetid://10734973486",
    code = "rbxassetid://10709810463",
    info = "rbxassetid://10723415903",
    bell = "rbxassetid://10709775704",
    check = "rbxassetid://10709790644",
    close = "rbxassetid://10747384394",
}

local aliases = {
    default = "info",
    visual = "eye",
    movement = "sliders",
    config = "settings",
    configuration = "settings",
    profile = "user",
}

local function isValidContentId(value)
    return value:match("^rbxassetid://%d+$")
        or value:match("^rbxasset://.+")
        or value:match("^https?://.+")
end

function Icons.Get(name)
    if type(name) == "number" and name > 0 then
        return "rbxassetid://" .. math.floor(name)
    end
    if type(name) == "string" then
        local key = string.lower(name)
        key = aliases[key] or key
        if Icons[key] then return Icons[key] end
        if isValidContentId(name) then return name end
    end
    return Icons[aliases.default]
end

return Icons

end

__modules["Services/Utility"]=function()
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

end

__modules["Themes/Custom"]=function()
local Dark = __require("Themes/Dark")

return function(overrides)
    local theme = table.clone(Dark)
    theme.Name = "Axiom Custom"
    for key, value in pairs(overrides or {}) do
        theme[key] = value
    end
    return theme
end

end

__modules["Themes/Dark"]=function()
return {
    Name = "Axiom Dark",
    Background = Color3.fromRGB(7, 8, 14),
    Surface = Color3.fromRGB(13, 15, 24),
    SurfaceAlt = Color3.fromRGB(22, 24, 37),
    SurfaceHover = Color3.fromRGB(32, 34, 51),
    Stroke = Color3.fromRGB(61, 64, 88),
    Text = Color3.fromRGB(241, 243, 255),
    TextMuted = Color3.fromRGB(143, 149, 174),
    Primary = Color3.fromRGB(139, 55, 255),
    Secondary = Color3.fromRGB(31, 130, 255),
    Success = Color3.fromRGB(53, 211, 153),
    Danger = Color3.fromRGB(255, 91, 121),
    Warning = Color3.fromRGB(255, 190, 76),
    Radius = UDim.new(0, 11),
    Transparency = 0.12,
    AcrylicTransparency = 0.09,
    TweenTime = 0.22,
}

end

__modules["Themes/Light"]=function()
return {
    Name="Axiom Light", Background=Color3.fromRGB(238,241,249), Surface=Color3.fromRGB(250,251,255),
    SurfaceAlt=Color3.fromRGB(228,232,244), SurfaceHover=Color3.fromRGB(215,221,239), Stroke=Color3.fromRGB(184,191,215),
    Text=Color3.fromRGB(24,27,39), TextMuted=Color3.fromRGB(91,99,126), Primary=Color3.fromRGB(102,78,235),
    Secondary=Color3.fromRGB(25,137,229), Success=Color3.fromRGB(22,164,111), Danger=Color3.fromRGB(225,65,96),
    Warning=Color3.fromRGB(218,145,34), Radius=UDim.new(0,10), Transparency=0.04, AcrylicTransparency=0.08, TweenTime=0.22,
}

end

__modules["init"]=function()
-- Axiom UI Engine 1.0.0
-- Entry point — for loadstring use dist/Axiom.lua
local Engine=__require("Core/Engine")
return Engine.new()

end

return __require("init")
