-- AXIOM UI ENGINE · generated distribution
local __modules,__cache={},{}
local function __require(id)
 if __cache[id]~=nil then return __cache[id] end
 local factory=assert(__modules[id],"Missing Axiom module: "..id)
 local value=factory()
 __cache[id]=value
 return value
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

__modules["Components/Base"]=function()
local Utility = __require("Services/Utility")
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

end

__modules["Components/Toggle"]=function()
local State = __require("Core/State")
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

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

end

__modules["Components/Button"]=function()
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
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
    button.MouseEnter:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceHover }) end)
    button.MouseLeave:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceAlt }) end)
    button.Activated:Connect(function()
        Animation.Ripple(button, theme.Primary)
        Utility.SafeCallback(options.Callback)
    end)
    return Base.Handle(button)
end

end

__modules["Components/Keybind"]=function()
local UserInputService=game:GetService("UserInputService")
local State=__require("Core/State")
local Utility=__require("Services/Utility")
local Base=__require("Components/Base")

return function(context,parent,options)
    options=options or {}; local state=State.new(options.Default or Enum.KeyCode.Unknown); local listening=false
    local row=Base.Row(context,parent,options,54)
    local capture=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(94,32),BackgroundColor3=context.Theme.Current.Background,BackgroundTransparency=0.15,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamMedium,TextColor3=context.Theme.Current.TextMuted,TextSize=11,Parent=row})
    Utility.Corner(capture,UDim.new(0,8)); Utility.Stroke(capture,context.Theme.Current.Stroke,0.55)
    local function render(key) capture.Text=listening and "PRESS A KEY" or key.Name:upper() end
    capture.Activated:Connect(function() listening=true; render(state:Get()) end)
    UserInputService.InputBegan:Connect(function(input,processed)
        if listening and input.KeyCode~=Enum.KeyCode.Unknown then listening=false; state:Set(input.KeyCode); render(input.KeyCode); return end
        if not processed and input.KeyCode==state:Get() then Utility.SafeCallback(options.Callback,input.KeyCode) end
    end)
    state.Changed:Connect(render); render(state:Get())
    return Base.Handle(row,state)
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

end

__modules["Components/ColorPicker"]=function()
local UserInputService=game:GetService("UserInputService")
local State=__require("Core/State")
local Animation=__require("Services/Animation")
local Utility=__require("Services/Utility")
local Base=__require("Components/Base")

return function(context,parent,options)
    options=options or {}
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
    local function updateSV(input) s=math.clamp((input.Position.X-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1); v=1-math.clamp((input.Position.Y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1); applyHSV() end
    local function updateHue(input) h=math.clamp((input.Position.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y,0,1); applyHSV() end
    sv.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSV=true; updateSV(input) end end)
    hue.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHue=true; updateHue(input) end end)
    UserInputService.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then if draggingSV then updateSV(input) elseif draggingHue then updateHue(input) end end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSV=false; draggingHue=false end end)
    preview.Activated:Connect(function() open=not open; Animation.Tween(row,{Size=UDim2.new(1,0,0,open and 224 or 62)},0.28) end)
    hex.FocusLost:Connect(function() local color=fromHex(hex.Text); if color then state:Set(color) else hex.Text=toHex(state:Get()) end end)
    local function render(color,fireCallback)
        h,s,v=color:ToHSV(); preview.BackgroundColor3=color; hex.Text=toHex(color); sv.BackgroundColor3=Color3.fromHSV(h,1,1)
        cursor.Position=UDim2.fromScale(s,1-v); hueCursor.Position=UDim2.fromScale(0.5,h)
        rgb.Text=string.format("RGB  %d  %d  %d",math.round(color.R*255),math.round(color.G*255),math.round(color.B*255))
        if fireCallback then Utility.SafeCallback(options.Callback,color,toHex(color)) end
    end
    state.Changed:Connect(function(color) render(color,true) end)
    render(state:Get(),false)
    return Base.Handle(row,state)
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

__modules["Components/Input"]=function()
local State = __require("Core/State")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

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

__modules["Components/Dropdown"]=function()
local State = __require("Core/State")
local Animation = __require("Services/Animation")
local Utility = __require("Services/Utility")
local Base = __require("Components/Base")

return function(context, parent, options)
    options = options or {}
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
        item.Activated:Connect(function()
            if multi then local nextValue=table.clone(state:Get()); nextValue[value]=not nextValue[value]; state:Set(nextValue) else state:Set(value); setOpen(false) end
        end)
    end
    selector.Activated:Connect(function() setOpen(not open) end)
    state.Changed:Connect(function(value) display(value); Utility.SafeCallback(options.Callback,value) end)
    display(state:Get())
    return Base.Handle(row,state)
end

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
        connection._owner._listeners[self] = nil
    end
    connection._owner = self
    return connection
end

function Signal:Fire(...)
    if self._destroyed then return end
    for connection, callback in pairs(self._listeners) do
        if connection.Connected then
            task.spawn(callback, ...)
        end
    end
end

function Signal:Destroy()
    self._destroyed = true
    for connection in pairs(self._listeners) do connection.Connected = false end
    table.clear(self._listeners)
end

return Signal

end

__modules["Core/State"]=function()
local Signal = __require("Core/Events")
local State = {}
State.__index = State

function State.new(initialValue)
    return setmetatable({ _value = initialValue, Changed = Signal.new() }, State)
end

function State:Get()
    return self._value
end

function State:Set(value)
    if self._value == value then return end
    local previous = self._value
    self._value = value
    self.Changed:Fire(value, previous)
end

function State:Update(reducer)
    self:Set(reducer(self._value))
end

function State:Destroy()
    self.Changed:Destroy()
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
    local value = self.Current[token]
    if transform then value = transform(value, self.Current) end
    if value ~= nil then instance[property] = value end
    return binding
end

function Theme:Apply(nextTheme)
    self.Current = nextTheme
    for index = #self._bindings, 1, -1 do
        local binding = self._bindings[index]
        if not binding.Instance.Parent then
            table.remove(self._bindings, index)
        else
            local value = nextTheme[binding.Token]
            if binding.Transform then value = binding.Transform(value, nextTheme) end
            if value ~= nil then binding.Instance[binding.Property] = value end
        end
    end
    self.Changed:Fire(nextTheme)
end

return Theme

end

__modules["Core/Engine"]=function()
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local Theme=__require("Core/Theme")
local Window=__require("Core/Window")
local Config=__require("Services/Config")
local Animation=__require("Services/Animation")
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
    self.Theme=Theme.new(Dark); self.Windows={}; self.Config=Config.new("AxiomUI")
    self.Gui=Utility.Create("ScreenGui",{Name="AxiomUIEngine",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=resolveParent()})
    self.Toasts=Utility.Create("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),Size=UDim2.fromOffset(340,500),BackgroundTransparency=1,Parent=self.Gui})
    Utility.Create("UIListLayout",{VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,10),Parent=self.Toasts})
    return self
end

function Engine:CreateWindow(options)
    options=options or {}
    if options.Theme then self:SetTheme(options.Theme) end
    if options.Blur then
        local blur=Lighting:FindFirstChild("AxiomBlur") or Instance.new("BlurEffect"); blur.Name="AxiomBlur"; blur.Size=0; blur.Parent=Lighting; Animation.Tween(blur,{Size=12},0.3)
    end
    local window=Window.new(self,options); table.insert(self.Windows,window); return window
end

function Engine:SetTheme(theme)
    local resolved=type(theme)=="string" and self.Themes[theme] or theme
    assert(type(resolved)=="table","Unknown Axiom theme")
    self.Theme:Apply(resolved)
end

function Engine:CreateTheme(overrides) return Custom(overrides) end

function Engine:Notify(options)
    options=options or {}; local t=self.Theme.Current
    local toast=Utility.Create("Frame",{Size=UDim2.fromOffset(0,82),BackgroundColor3=t.Surface,BackgroundTransparency=0.04,BorderSizePixel=0,ClipsDescendants=true,Parent=self.Toasts}); Utility.Corner(toast,UDim.new(0,12)); Utility.Stroke(toast,t.Stroke,0.35)
    Utility.Create("Frame",{Size=UDim2.fromOffset(4,82),BackgroundColor3=options.Color or t.Primary,BorderSizePixel=0,Parent=toast})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-32,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=options.Title or "Axiom",TextColor3=t.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=toast})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,35),Size=UDim2.new(1,-32,0,34),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Description or "",TextColor3=t.TextMuted,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=toast})
    Animation.Tween(toast,{Size=UDim2.fromOffset(340,82)},0.32)
    task.delay(options.Duration or 4,function() Animation.Tween(toast,{Size=UDim2.fromOffset(0,82),BackgroundTransparency=1},0.3); task.delay(0.32,function() toast:Destroy() end) end)
    return toast
end

function Engine:Destroy()
    local blur=Lighting:FindFirstChild("AxiomBlur"); if blur then blur:Destroy() end
    self.Gui:Destroy()
end

return Engine

end

__modules["Core/Window"]=function()
local UserInputService=game:GetService("UserInputService")
local Animation=__require("Services/Animation")
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

local function makeDraggable(frame,handle)
    local dragging,startInput,startPos=false,nil,nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; startInput=input.Position; startPos=frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-startInput
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
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
    local self=setmetatable({Context=context,Tabs={},ActiveTab=nil,Minimized=false,Maximized=false},Window)
    local t=context.Theme.Current
    local root=Utility.Create("Frame",{
        Name="AxiomWindow",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=options.Size or UDim2.fromOffset(820,520),BackgroundColor3=t.Background,
        BackgroundTransparency=options.Acrylic==false and 0 or t.AcrylicTransparency,
        BorderSizePixel=0,ClipsDescendants=true,Parent=context.Gui,
    })
    Utility.Corner(root,UDim.new(0,18))
    local outerStroke=Utility.Stroke(root,t.Stroke,0.18,1)
    context.Theme:Bind(root,"BackgroundColor3","Background")
    context.Theme:Bind(outerStroke,"Color","Stroke")
    Utility.Create("UIGradient",{
        Rotation=38,
        Color=ColorSequence.new(t.Background,Color3.fromRGB(15,16,27)),
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.62,0.04),NumberSequenceKeypoint.new(1,0)}),
        Parent=root,
    })
    local scale=Utility.Create("UIScale",{Scale=0.965,Parent=root})
    Animation.Tween(scale,{Scale=1},0.34)
    root.BackgroundTransparency=1
    Animation.Tween(root,{BackgroundTransparency=options.Acrylic==false and 0 or t.AcrylicTransparency},0.3)

    local top=Utility.Create("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,66),BackgroundColor3=t.Surface,BackgroundTransparency=0.58,BorderSizePixel=0,Parent=root})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,1),BackgroundColor3=t.Stroke,BackgroundTransparency=0.5,BorderSizePixel=0,Parent=top})
    local logo=Utility.Create("Frame",{Position=UDim2.fromOffset(20,16),Size=UDim2.fromOffset(34,34),BackgroundColor3=t.Primary,BorderSizePixel=0,Parent=top})
    Utility.Corner(logo,UDim.new(1,0))
    Utility.Create("UIGradient",{Rotation=135,Color=ColorSequence.new(t.Primary,Color3.fromRGB(36,39,59)),Parent=logo})
    Utility.Stroke(logo,Color3.new(1,1,1),0.76)
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(66,12),Size=UDim2.new(1,-240,0,22),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=options.Title or "AXIOM",TextColor3=t.Text,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(66,33),Size=UDim2.new(1,-240,0,17),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Subtitle or "UI ENGINE",TextColor3=t.TextMuted,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})

    local function topButton(text,x,callback,color)
        local button=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,x,0,16),Size=UDim2.fromOffset(34,34),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.22,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text=text,TextColor3=color or t.TextMuted,TextSize=15,Parent=top})
        Utility.Corner(button,UDim.new(0,8)); Utility.Stroke(button,t.Stroke,0.68)
        button.MouseEnter:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceHover,TextColor3=color or t.Text}) end)
        button.MouseLeave:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceAlt,TextColor3=color or t.TextMuted}) end)
        button.Activated:Connect(callback)
        return button
    end
    topButton("—",-100,function() self:Minimize() end,t.Primary)
    topButton("□",-58,function() self:Maximize() end,t.Secondary)
    topButton("×",-16,function() self:Close() end,Color3.fromRGB(187,91,255))

    local sidebar=Utility.Create("Frame",{Position=UDim2.fromOffset(0,66),Size=UDim2.new(0,88,1,-66),BackgroundColor3=t.Surface,BackgroundTransparency=0.64,BorderSizePixel=0,Parent=root})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=t.Stroke,BackgroundTransparency=0.52,BorderSizePixel=0,Parent=sidebar})
    local tabList=Utility.Create("Frame",{Position=UDim2.fromOffset(15,18),Size=UDim2.new(1,-30,1,-92),BackgroundTransparency=1,Parent=sidebar})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,9),HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=tabList})
    local status=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-16),Size=UDim2.fromOffset(56,56),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=sidebar})
    Utility.Corner(status,UDim.new(0,11)); Utility.Stroke(status,t.Stroke,0.62)
    local statusDot=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=t.Primary,BorderSizePixel=0,Parent=status})
    Utility.Corner(statusDot,UDim.new(1,0)); Utility.Create("UIGradient",{Color=ColorSequence.new(t.Primary,t.Secondary),Rotation=45,Parent=statusDot})

    local content=Utility.Create("Frame",{Position=UDim2.fromOffset(110,88),Size=UDim2.new(1,-132,1,-110),BackgroundTransparency=1,Parent=root})
    self.Root=root; self.TitleBar=top; self.TabList=tabList; self.Content=content
    self.OriginalSize=root.Size; self.OriginalPosition=root.Position
    makeDraggable(root,top)

    local resize=Utility.Create("TextButton",{Name="ResizeHandle",AnchorPoint=Vector2.new(1,1),Position=UDim2.fromScale(1,1),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,Text="◢",TextColor3=t.TextMuted,TextSize=12,Parent=root})
    local resizing,resizeStart,sizeStart=false,nil,nil
    resize.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then resizing=true; resizeStart=input.Position; sizeStart=root.AbsoluteSize end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-resizeStart
            root.Size=UDim2.fromOffset(math.max(620,sizeStart.X+delta.X),math.max(400,sizeStart.Y+delta.Y))
            self.OriginalSize=root.Size
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
    return self
end

function Window:AddTab(options)
    options=options or {}
    local t=self.Context.Theme.Current
    local button=Utility.Create("TextButton",{Size=UDim2.fromOffset(56,52),BackgroundColor3=t.Primary,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=self.TabList})
    Utility.Corner(button,UDim.new(0,10)); Utility.Stroke(button,t.Primary,1)
    local gradient=Utility.Create("UIGradient",{Rotation=135,Color=ColorSequence.new(Color3.fromRGB(151,48,255),Color3.fromRGB(82,35,204)),Parent=button})
    local icon=Utility.Create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,Image=Icons.Get(options.Icon),ImageColor3=t.TextMuted,Parent=button})
    local tooltip=Utility.Create("TextLabel",{Position=UDim2.new(1,12,0.5,-15),Size=UDim2.fromOffset(0,30),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.04,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=options.Name or "Tab",TextColor3=t.Text,TextSize=11,Visible=false,ClipsDescendants=true,ZIndex=20,Parent=button})
    Utility.Corner(tooltip,UDim.new(0,7)); Utility.Stroke(tooltip,t.Stroke,0.45)
    button.MouseEnter:Connect(function() tooltip.Visible=true; Animation.Tween(tooltip,{Size=UDim2.fromOffset(110,30)},0.16) end)
    button.MouseLeave:Connect(function() Animation.Tween(tooltip,{Size=UDim2.fromOffset(0,30)},0.12); task.delay(0.13,function() if tooltip then tooltip.Visible=false end end) end)
    local page=Utility.Create("ScrollingFrame",{Name=(options.Name or "Tab").."Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=t.Primary,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false,Parent=self.Content})
    Utility.Padding(page,2); Utility.Create("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page})
    local tab=attachContainerApi({Window=self,Button=button,Icon=icon,Gradient=gradient,Page=page,Options=options},self.Context,page)
    function tab:Select() self.Window:SelectTab(self) end
    function tab:AddColumnGroup(groupOptions)
        groupOptions=groupOptions or {}
        local gap=groupOptions.Gap or 12
        local ratio=groupOptions.Ratio or 0.62
        local holder=Utility.Create("Frame",{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=self.CurrentParent})
        local left=Utility.Create("Frame",{Size=UDim2.new(ratio,-gap/2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=holder})
        local right=Utility.Create("Frame",{Size=UDim2.new(1-ratio,-gap/2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=holder})
        Utility.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap),VerticalAlignment=Enum.VerticalAlignment.Top,Parent=holder})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=left})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=right})
        return attachContainerApi({},self.Window.Context,left),attachContainerApi({},self.Window.Context,right)
    end
    button.Activated:Connect(function() tab:Select() end)
    table.insert(self.Tabs,tab)
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    for _,item in ipairs(self.Tabs) do
        local active=item==tab
        item.Page.Visible=active
        Animation.Tween(item.Button,{BackgroundTransparency=active and 0 or 1})
        Animation.Tween(item.Icon,{ImageColor3=active and Color3.new(1,1,1) or self.Context.Theme.Current.TextMuted})
    end
    self.ActiveTab=tab
end

function Window:Minimize()
    self.Minimized=not self.Minimized
    Animation.Tween(self.Root,{Size=self.Minimized and UDim2.fromOffset(self.Root.AbsoluteSize.X,66) or self.OriginalSize},0.3)
end

function Window:Maximize()
    if self.Minimized then self:Minimize() end
    self.Maximized=not self.Maximized
    if self.Maximized then
        self.OriginalSize=self.Root.Size; self.OriginalPosition=self.Root.Position
        Animation.Tween(self.Root,{Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-48,1,-48)},0.32)
    else
        Animation.Tween(self.Root,{Position=self.OriginalPosition,Size=self.OriginalSize},0.32)
    end
end

function Window:Close()
    Animation.Tween(self.Root,{BackgroundTransparency=1,Size=UDim2.fromOffset(self.Root.AbsoluteSize.X*0.94,self.Root.AbsoluteSize.Y*0.94)},0.24)
    task.delay(0.25,function() self.Root:Destroy() end)
end

function Window:SetTheme(theme) self.Context.Theme:Apply(theme) end
function Window:Destroy() self.Root:Destroy() end
return Window

end

__modules["Services/Config"]=function()
local HttpService=game:GetService("HttpService")
local Config={}; Config.__index=Config

function Config.new(namespace)
    return setmetatable({Namespace=namespace or "Axiom",Values={},Profiles={},AutoSave=false,AutoSaveProfile="default",_connections={}},Config)
end

function Config:Register(key,control)
    self.Values[key]=control
    if control.Changed then
        self._connections[key]=control.Changed:Connect(function()
            if self.AutoSave then
                local revision=tick(); self._pendingRevision=revision
                task.delay(0.35,function() if self._pendingRevision==revision then self:Save(self.AutoSaveProfile) end end)
            end
        end)
    end
    return control
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
    profile=profile or "default"; local data=self:Serialize(); self.Profiles[profile]=data
    if writefile then
        if makefolder then pcall(makefolder,self.Namespace) end
        writefile(self.Namespace.."/"..profile..".json",HttpService:JSONEncode(data))
    end
    return data
end

function Config:Load(profile)
    profile=profile or "default"; local data=self.Profiles[profile]
    if not data and readfile and isfile and isfile(self.Namespace.."/"..profile..".json") then
        local ok,result=pcall(function() return HttpService:JSONDecode(readfile(self.Namespace.."/"..profile..".json")) end)
        if ok then data=result end
    end
    self:LoadTable(data or {}); return data~=nil
end

return Config

end

__modules["Services/Animation"]=function()
local TweenService = game:GetService("TweenService")
local Animation = {}

function Animation.Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Animation.Hover(gui, normal, hovered)
    gui.MouseEnter:Connect(function() Animation.Tween(gui, hovered) end)
    gui.MouseLeave:Connect(function() Animation.Tween(gui, normal) end)
end

function Animation.Ripple(button, color)
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
    task.delay(0.45, function() ripple:Destroy() end)
end

return Animation

end

__modules["Services/Icons"]=function()
local Icons = {
    home = "rbxassetid://10723407389",
    settings = "rbxassetid://10734950309",
    sliders = "rbxassetid://10734951847",
    palette = "rbxassetid://10734973486",
    code = "rbxassetid://10709810463",
    info = "rbxassetid://10723415903",
    bell = "rbxassetid://10709775704",
    check = "rbxassetid://10709790644",
    close = "rbxassetid://10747384394",
}

function Icons.Get(name)
    return Icons[name] or name or ""
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
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent,
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

__modules["init"]=function()
-- Axiom UI Engine 1.0.0
-- Package entry point for Rojo/Wally-style module trees.
local Engine=__require("Core/Engine")
return Engine.new()

end

return __require("init")
