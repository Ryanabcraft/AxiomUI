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
    topButton("—",-94,function() self:Minimize() end,t.Warning)
    topButton("□",-56,function() self:Maximize() end,t.Success)
    topButton("×",-18,function() self:Close() end,t.Danger)

    -- BODY: CanvasGroup para fade controlado no minimize
    local body=Utility.Create("CanvasGroup",{Name="Body",Position=UDim2.fromOffset(0,HEADER_HEIGHT),Size=UDim2.new(1,0,1,-HEADER_HEIGHT),BackgroundTransparency=1,BorderSizePixel=0,GroupTransparency=0,ZIndex=Z_INDEX.Body,Parent=windowClip})

    local sidebar=Utility.Create("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,88,1,0),BackgroundColor3=t.Surface,BackgroundTransparency=0.64,BorderSizePixel=0,ZIndex=Z_INDEX.Sidebar,Parent=body})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,12),Size=UDim2.new(0,1,1,-24),BackgroundColor3=t.Stroke,BackgroundTransparency=0.52,BorderSizePixel=0,Parent=sidebar})
    local tabList=Utility.Create("Frame",{Position=UDim2.fromOffset(15,18),Size=UDim2.new(1,-30,1,-92),BackgroundTransparency=1,Parent=sidebar})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,9),HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=tabList})
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
    if metrics.Mode=="Mobile" then
        sidebarWidth=56; contentGap=10; rightPadding=10; tabSize=48; tabInset=4
    elseif metrics.Mode=="Tablet" then
        sidebarWidth=72; contentGap=14; rightPadding=14; tabSize=52; tabInset=10
    else
        sidebarWidth=88; contentGap=22; rightPadding=22; tabSize=56; tabInset=15
    end
    local contentX=sidebarWidth+contentGap
    local layoutSize=logicalSize or self.Root.Size
    self._ContentLogicalWidth=math.max(0,layoutSize.X.Offset-contentX-rightPadding)
    self.Sidebar.Size=UDim2.new(0,sidebarWidth,1,0)
    self.TabList.Position=UDim2.fromOffset(tabInset,18)
    self.TabList.Size=UDim2.new(1,-tabInset*2,1,-36)
    self.Content.Position=UDim2.fromOffset(contentX,22)
    self.Content.Size=UDim2.new(1,-contentX-rightPadding,1,-44)
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
