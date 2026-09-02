local UserInputService=game:GetService("UserInputService")
local State=require(script.Parent.Parent.Core.State)
local Animation=require(script.Parent.Parent.Services.Animation)
local Utility=require(script.Parent.Parent.Services.Utility)
local Base=require(script.Parent.Base)

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
