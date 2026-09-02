local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local Animation=require(script.Parent.Parent.Services.Animation)
local Cleanup=require(script.Parent.Parent.Services.Cleanup)
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

local HEADER_HEIGHT=58
local WINDOW_RADIUS=14
local MIN_WIDTH=620
local MIN_HEIGHT=400
local DEFAULT_UI_SCALE=0.62
local MIN_UI_SCALE=0.45
local MAX_UI_SCALE=1.25
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

local function getMaximizedBounds(uiScale)
    local viewport=getViewportSize()
    local topLeft,bottomRight=Vector2.zero,Vector2.zero
    pcall(function() topLeft,bottomRight=GuiService:GetGuiInset() end)
    local left=math.max(24,topLeft.X+12)
    local top=math.max(24,topLeft.Y+12)
    local right=math.max(24,bottomRight.X+12)
    local bottom=math.max(24,bottomRight.Y+12)
    local width=math.max(MIN_WIDTH,(viewport.X-left-right)/uiScale)
    local height=math.max(MIN_HEIGHT,(viewport.Y-top-bottom)/uiScale)
    return UDim2.fromOffset(math.round(width),math.round(height)),UDim2.fromOffset(math.round(left+width*uiScale/2),math.round(top+height*uiScale/2))
end

local function makeDraggable(window, frame, handle)
    local dragging, startInput, startPos=false,nil,nil
    local conns={}
    conns[1]=handle.InputBegan:Connect(function(input)
        if window._WindowState.Maximized and not window._WindowState.Minimized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            window:_CommitScale()
            dragging=true; startInput=input.Position; startPos=frame.Position
        end
    end)
    conns[2]=UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            if window._WindowState.Maximized and not window._WindowState.Minimized then return end
            local delta=input.Position-startInput
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            if window._WindowState.Minimized then window._WindowState.MinimizedPosition=frame.Position
            else window.OriginalPosition=frame.Position end
        end
    end)
    conns[3]=UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    for _,c in ipairs(conns) do window._Cleanup:Add(c) end
    window._Cleanup:Add(function() dragging=false; startInput=nil; startPos=nil end)
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
    local finalScale=tonumber(options.Scale) or DEFAULT_UI_SCALE
    if finalScale~=finalScale then finalScale=DEFAULT_UI_SCALE end
    finalScale=math.clamp(finalScale,MIN_UI_SCALE,MAX_UI_SCALE)
    local self=setmetatable({
        Context=context,
        Tabs={},ActiveTab=nil,
        Scale=finalScale,
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
        Name="AxiomWindow",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=options.Size or UDim2.fromOffset(820,520),BackgroundTransparency=1,
        BorderSizePixel=0,ClipsDescendants=false,ZIndex=Z_INDEX.Background,Parent=context.Gui,
    })
    local scale=Utility.Create("UIScale",{Scale=finalScale*0.965,Parent=root})
    local scaleTween=Animation.Tween(scale,{Scale=finalScale},0.34)
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
    local visualTransparency=acrylic and math.max(0.02,t.AcrylicTransparency-(localBlur and 0.035 or 0)) or 0
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
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,9),Size=UDim2.new(1,-180,0,21),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=options.Title or "AXIOM",TextColor3=t.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(18,29),Size=UDim2.new(1,-180,0,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Subtitle or "UI ENGINE",TextColor3=t.TextMuted,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})

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
    self.Body=body
    self.Sidebar=sidebar
    self.TabList=tabList
    self.Content=content
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
    local resizing,resizeStart,sizeStart=false,nil,nil
    local c1=resize.InputBegan:Connect(function(input)
        if self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            self:_CommitScale()
            resizing=true
            resizeStart=input.Position
            sizeStart=root.AbsoluteSize/finalScale
        end
    end)
    local c2=UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local delta=(input.Position-resizeStart)/finalScale
            local maxSize=getMaximizedBounds(finalScale)
            local maxW=maxSize.X.Offset
            local maxH=maxSize.Y.Offset
            local newW=math.clamp(sizeStart.X+delta.X, MIN_WIDTH, maxW)
            local newH=math.clamp(sizeStart.Y+delta.Y, MIN_HEIGHT, maxH)
            root.Size=UDim2.fromOffset(newW,newH)
            -- Não sobrescreve PreviousSize se estiver maximizado/minimizado; atualiza Original para compat
            self.OriginalSize=root.Size
            self._WindowState.PreviousSize=root.Size
        end
    end)
    local c3=UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
    self._Cleanup:Add(c1); self._Cleanup:Add(c2); self._Cleanup:Add(c3)
    self._Cleanup:Add(function() resizing=false; resizeStart=nil; sizeStart=nil end)
    self._Cleanup:Add(root.Destroying:Connect(function() if not self._IsDestroyed then self:Destroy() end end))

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
    self._Cleanup:Add(button.MouseEnter:Connect(function()
        if not tooltip.Parent then return end
        tooltipRevision+=1
        positionTooltip()
        tooltip.Visible=true
        Animation.Tween(tooltip,{Size=UDim2.fromOffset(110,30)},0.16)
    end))
    self._Cleanup:Add(button.MouseLeave:Connect(function() hideTooltip(false) end))
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
        Utility.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,gap),VerticalAlignment=Enum.VerticalAlignment.Top,Parent=holder})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=left})
        Utility.Create("UIListLayout",{Padding=UDim.new(0,9),Parent=right})
        return attachContainerApi({},self.Window.Context,left),attachContainerApi({},self.Window.Context,right)
    end
    self._Cleanup:Add(button.Activated:Connect(function() if not self._IsDestroyed then tab:Select() end end))
    table.insert(self.Tabs,tab)
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
        targetSize,targetPos=getMaximizedBounds(self.Scale)
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
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_RESTORE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        self:_Delay(TWEEN_RESTORE,function()
            if token~=self._TransitionId then return end
            self.Body.Visible=true
            self.ResizeHandle.Visible=true
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
        local targetPos=self._WindowState.PreviousPosition or self.OriginalPosition
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_MAXIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        self:_Delay(TWEEN_MAXIMIZE,function()
            if token~=self._TransitionId then return end
            self.ResizeHandle.Visible=true
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
        local maxSize,maxPos=getMaximizedBounds(self.Scale)
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
    self.ActiveTab=nil
    self.ResizeHandle=nil
    self.UIScale=nil
    self.Body=nil
    self.Sidebar=nil
    self.TabList=nil
    self.Content=nil
    self.OverlayLayer=nil
    self.TooltipLayer=nil
    self.PopupLayer=nil
    self.ModalLayer=nil
    self.TitleBar=nil
    self.WindowClip=nil
    self.WindowVisual=nil
    self.Root=nil
    self.Context=nil
    self._Cleanup=nil
    self._WindowState=nil
end
return Window
