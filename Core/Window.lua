local UserInputService=game:GetService("UserInputService")
local Animation=require(script.Parent.Parent.Services.Animation)
local Utility=require(script.Parent.Parent.Services.Utility)
local Icons=require(script.Parent.Parent.Services.Icons)
local Components={
    Button=require(script.Parent.Parent.Components.Button), Toggle=require(script.Parent.Parent.Components.Toggle),
    Slider=require(script.Parent.Parent.Components.Slider), Dropdown=require(script.Parent.Parent.Components.Dropdown),
    Input=require(script.Parent.Parent.Components.Input), Keybind=require(script.Parent.Parent.Components.Keybind),
    ColorPicker=require(script.Parent.Parent.Components.ColorPicker), Section=require(script.Parent.Parent.Components.Section),
    Card=require(script.Parent.Parent.Components.Card),
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
