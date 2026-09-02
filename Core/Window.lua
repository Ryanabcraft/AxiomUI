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

local HEADER_HEIGHT=58
local WINDOW_RADIUS=14
local MIN_WIDTH=620
local MIN_HEIGHT=400
local TWEEN_MINIMIZE=0.22
local TWEEN_RESTORE=0.26
local TWEEN_MAXIMIZE=0.30

local function getViewportSize()
    local cam=workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1920,1080)
end

local function makeDraggable(window, frame, handle)
    local dragging, startInput, startPos=false,nil,nil
    local conns={}
    conns[1]=handle.InputBegan:Connect(function(input)
        if window._WindowState.Maximized and not window._WindowState.Minimized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; startInput=input.Position; startPos=frame.Position
        end
    end)
    conns[2]=UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            if window._WindowState.Maximized and not window._WindowState.Minimized then return end
            local delta=input.Position-startInput
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            if window._WindowState.Minimized and not window._WindowState.PreMinimizeMaximized then
                window._WindowState.PreviousPosition=frame.Position
                window.OriginalPosition=frame.Position
            end
        end
    end)
    conns[3]=UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    for _,c in ipairs(conns) do table.insert(window._Connections,c) end
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
    local self=setmetatable({
        Context=context,
        Tabs={},ActiveTab=nil,
        Minimized=false,Maximized=false,
        _Connections={},
        _Blur=nil,
        _IsDestroyed=false,
        _WindowState={Minimized=false,Maximized=false,PreviousSize=nil,PreviousPosition=nil,PreMinimizeMaximized=nil,IsAnimating=false}
    },Window)
    local t=context.Theme.Current

    -- ROOT is interaction/layout only. Keeping it fully transparent prevents a square
    -- acrylic layer from appearing below the rounded visual container.
    local root=Utility.Create("Frame",{
        Name="AxiomWindow",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=options.Size or UDim2.fromOffset(820,520),BackgroundTransparency=1,
        BorderSizePixel=0,ClipsDescendants=false,Parent=context.Gui,
    })
    local scale=Utility.Create("UIScale",{Scale=0.965,Parent=root})
    Animation.Tween(scale,{Scale=1},0.34)

    -- WINDOW CLIP owns every visual layer, so background, gradient and children all
    -- share the same clipping radius with no square frame underneath.
    local windowClip=Utility.Create("Frame",{
        Name="WindowClip",Size=UDim2.fromScale(1,1),BackgroundColor3=t.Background,
        BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Parent=root
    })
    Utility.Corner(windowClip,UDim.new(0,WINDOW_RADIUS))
    local outerStroke=Utility.Stroke(windowClip,t.Stroke,0.18,1)
    context.Theme:Bind(windowClip,"BackgroundColor3","Background")
    context.Theme:Bind(outerStroke,"Color","Stroke")
    Utility.Create("UIGradient",{
        Rotation=38,
        Color=ColorSequence.new(t.Background,Color3.fromRGB(15,16,27)),
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.62,0.04),NumberSequenceKeypoint.new(1,0)}),
        Parent=windowClip,
    })
    Animation.Tween(windowClip,{BackgroundTransparency=options.Acrylic==false and 0 or t.AcrylicTransparency},0.3)

    -- TITLE BAR (Header) - dentro do clip, cantos arredondados via parent clip
    local top=Utility.Create("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,HEADER_HEIGHT),BackgroundColor3=t.Surface,BackgroundTransparency=0.58,BorderSizePixel=0,Parent=windowClip})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(1,0,0,1),BackgroundColor3=t.Stroke,BackgroundTransparency=0.5,BorderSizePixel=0,Parent=top})
    local logo=Utility.Create("Frame",{Position=UDim2.fromOffset(18,14),Size=UDim2.fromOffset(30,30),BackgroundColor3=t.Primary,BorderSizePixel=0,Parent=top})
    Utility.Corner(logo,UDim.new(1,0))
    Utility.Create("UIGradient",{Rotation=135,Color=ColorSequence.new(t.Primary,Color3.fromRGB(36,39,59)),Parent=logo})
    Utility.Stroke(logo,Color3.new(1,1,1),0.76)
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(58,9),Size=UDim2.new(1,-220,0,21),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=options.Title or "AXIOM",TextColor3=t.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})
    Utility.Create("TextLabel",{Position=UDim2.fromOffset(58,29),Size=UDim2.new(1,-220,0,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=options.Subtitle or "UI ENGINE",TextColor3=t.TextMuted,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=top})

    local function topButton(text,x,callback,color)
        local button=Utility.Create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,x,0,13),Size=UDim2.fromOffset(32,32),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.22,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text=text,TextColor3=color or t.TextMuted,TextSize=14,Parent=top})
        Utility.Corner(button,UDim.new(0,8)); Utility.Stroke(button,t.Stroke,0.68)
        button.MouseEnter:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceHover,TextColor3=color or t.Text}) end)
        button.MouseLeave:Connect(function() Animation.Tween(button,{BackgroundColor3=t.SurfaceAlt,TextColor3=color or t.TextMuted}) end)
        button.Activated:Connect(callback)
        return button
    end
    topButton("—",-94,function() self:Minimize() end,t.Primary)
    topButton("□",-56,function() self:Maximize() end,t.Secondary)
    topButton("×",-18,function() self:Close() end,Color3.fromRGB(187,91,255))

    -- BODY: CanvasGroup para fade controlado no minimize
    local body=Utility.Create("CanvasGroup",{Name="Body",Position=UDim2.fromOffset(0,HEADER_HEIGHT),Size=UDim2.new(1,0,1,-HEADER_HEIGHT),BackgroundTransparency=1,BorderSizePixel=0,GroupTransparency=0,Parent=windowClip})

    local sidebar=Utility.Create("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,88,1,0),BackgroundColor3=t.Surface,BackgroundTransparency=0.64,BorderSizePixel=0,Parent=body})
    Utility.Create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=t.Stroke,BackgroundTransparency=0.52,BorderSizePixel=0,Parent=sidebar})
    local tabList=Utility.Create("Frame",{Position=UDim2.fromOffset(15,18),Size=UDim2.new(1,-30,1,-92),BackgroundTransparency=1,Parent=sidebar})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,9),HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=tabList})
    local status=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-16),Size=UDim2.fromOffset(56,56),BackgroundColor3=t.SurfaceAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=sidebar})
    Utility.Corner(status,UDim.new(0,11)); Utility.Stroke(status,t.Stroke,0.62)
    local statusDot=Utility.Create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=t.Primary,BorderSizePixel=0,Parent=status})
    Utility.Corner(statusDot,UDim.new(1,0)); Utility.Create("UIGradient",{Color=ColorSequence.new(t.Primary,t.Secondary),Rotation=45,Parent=statusDot})

    -- Content dentro do Body, com offset correto (22px abaixo do header)
    local content=Utility.Create("Frame",{Position=UDim2.fromOffset(110,22),Size=UDim2.new(1,-132,1,-44),BackgroundTransparency=1,Parent=body})

    self.Root=root
    self.WindowClip=windowClip
    self.TitleBar=top
    self.Body=body
    self.Sidebar=sidebar
    self.TabList=tabList
    self.Content=content
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
        ZIndex=10,
        Parent=windowClip
    })
    -- Indicador premium extremamente discreto (3 tracinhos diagonais com 92% transparência) — só aparece no hover
    local grip=Utility.Create("Frame",{Name="GripVisual",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-2,1,-2),Size=UDim2.fromOffset(12,12),BackgroundTransparency=1,Parent=resize})
    for i=1,3 do
        local line=Utility.Create("Frame",{
            Size=UDim2.new(1,0,0,1),
            Position=UDim2.new(0,0,0,(i-1)*4),
            BackgroundColor3=t.TextMuted,
            BackgroundTransparency=0.92,
            BorderSizePixel=0,
            Parent=grip
        })
        Utility.Corner(line,UDim.new(1,0))
        line.Rotation=45
        line.AnchorPoint=Vector2.new(0.5,0.5)
        line.Position=UDim2.new(0.5,0,0.5,(i-1)*4 -4)
    end
    grip.Visible=false
    resize.MouseEnter:Connect(function() grip.Visible=true end)
    resize.MouseLeave:Connect(function() grip.Visible=false end)

    self.ResizeHandle=resize
    self._GripVisual=grip

    -- Resize logic centralizada, sem leak, respeitando estados e limites
    local resizing,resizeStart,sizeStart=false,nil,nil
    local c1=resize.InputBegan:Connect(function(input)
        if self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            resizing=true
            resizeStart=input.Position
            sizeStart=root.AbsoluteSize
        end
    end)
    local c2=UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if self._WindowState.Minimized or self._WindowState.Maximized then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local delta=input.Position-resizeStart
            local viewport=getViewportSize()
            local maxW=viewport.X-48
            local maxH=viewport.Y-48
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
    table.insert(self._Connections,c1); table.insert(self._Connections,c2); table.insert(self._Connections,c3)

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

-- Helpers internos para blur seguro
function Window:_SetBlurEnabled(enabled)
    if not self._Blur then return end
    pcall(function()
        if enabled then
            Animation.Tween(self._Blur,{Size=2},0.28)
        else
            Animation.Tween(self._Blur,{Size=0},0.22)
        end
    end)
end

function Window:_DoMinimize()
    if self._WindowState.IsAnimating then return end
    self._WindowState.IsAnimating=true
    -- Salva estado antes de minimizar (para MAXIMIZED->MINIMIZED->MAXIMIZED)
    self._WindowState.PreviousSize=self.Root.Size
    self._WindowState.PreviousPosition=self.Root.Position
    self._WindowState.PreMinimizeMaximized=self._WindowState.Maximized
    self._WindowState.Minimized=true
    self.Minimized=true

    -- Blur: desativa levemente quando minimizado (mantém premium sem borrar)
    self:_SetBlurEnabled(false)

    -- Fade body e esconde antes de animar altura
    Animation.Tween(self.Body,{GroupTransparency=1},0.12)
    task.delay(0.12,function()
        if not self._WindowState.Minimized then return end
        self.Body.Visible=false
        self.ResizeHandle.Visible=false
        if self._GripVisual then self._GripVisual.Visible=false end
        -- Calcula tamanho minimizado: mesma largura, altura = HEADER
        local prev=self._WindowState.PreviousSize
        local minimizedSize=UDim2.new(prev.X.Scale, prev.X.Offset, 0, HEADER_HEIGHT)
        Animation.Tween(self.Root,{Size=minimizedSize},TWEEN_MINIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(TWEEN_MINIMIZE,function() self._WindowState.IsAnimating=false end)
    end)
end

function Window:_DoRestoreFromMinimize()
    if self._WindowState.IsAnimating then return end
    self._WindowState.IsAnimating=true
    self._WindowState.Minimized=false
    self.Minimized=false

    local targetSize=self._WindowState.PreviousSize or self.OriginalSize
    local targetPos=self._WindowState.PreviousPosition or self.OriginalPosition
    -- Se veio de maximizado, restaura para maximizado
    if self._WindowState.PreMinimizeMaximized then
        self._WindowState.Maximized=true
        self.Maximized=true
        targetSize=UDim2.new(1,-48,1,-48)
        targetPos=UDim2.fromScale(0.5,0.5)
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_RESTORE)
        task.delay(TWEEN_RESTORE,function()
            self.Body.Visible=true
            self.ResizeHandle.Visible=false -- continua invisível quando maximizado (sem resize)
            Animation.Tween(self.Body,{GroupTransparency=0},0.16)
            self:_SetBlurEnabled(true)
            self._WindowState.IsAnimating=false
        end)
    else
        self._WindowState.Maximized=false
        self.Maximized=false
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_RESTORE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(TWEEN_RESTORE,function()
            self.Body.Visible=true
            self.ResizeHandle.Visible=true
            Animation.Tween(self.Body,{GroupTransparency=0},0.16)
            self:_SetBlurEnabled(true)
            self._WindowState.IsAnimating=false
        end)
    end
    self.OriginalSize=targetSize
    self.OriginalPosition=targetPos
end

function Window:Minimize()
    if self._IsDestroyed then return end
    if self._WindowState.Minimized then
        self:_DoRestoreFromMinimize()
    else
        -- Se maximizado, não faz tween direto para 66 com largura scale; o _DoMinimize já lida guardando PreMinimizeMaximized
        self:_DoMinimize()
    end
end

function Window:Maximize()
    if self._IsDestroyed then return end
    if self._WindowState.IsAnimating then return end
    -- Se minimizado, restaura primeiro (comportamento consistente) — mas spec permite MAXIMIZED->MINIMIZED->MAXIMIZED,
    -- então se estiver minimizado e maximizado flag estava true, o Minimize já guardou. Aqui se estiver minimizado, tratamos como restore para maximizado
    if self._WindowState.Minimized then
        -- Minimizado -> Maximizar: restaura direto para maximizado sem passar por Normal
        self:_DoRestoreFromMinimize()
        -- Após restore, se ainda não maximizado e queremos maximizar, schedule
        if not self._WindowState.Maximized then
            task.delay(TWEEN_RESTORE+0.02,function() self:Maximize() end)
        end
        return
    end

    if self._WindowState.Maximized then
        -- Restaurar
        self._WindowState.IsAnimating=true
        self._WindowState.Maximized=false
        self.Maximized=false
        local targetSize=self._WindowState.PreviousSize or self.OriginalSize
        local targetPos=self._WindowState.PreviousPosition or self.OriginalPosition
        Animation.Tween(self.Root,{Size=targetSize,Position=targetPos},TWEEN_MAXIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(TWEEN_MAXIMIZE,function()
            self.ResizeHandle.Visible=true
            self._WindowState.IsAnimating=false
            self.OriginalSize=targetSize
            self.OriginalPosition=targetPos
        end)
    else
        -- Maximizar
        self._WindowState.PreviousSize=self.Root.Size
        self._WindowState.PreviousPosition=self.Root.Position
        self._WindowState.IsAnimating=true
        self._WindowState.Maximized=true
        self.Maximized=true
        -- Respeita viewport, não ultrapassa topbar: usa inset 48 e posição 0.5
        local maxSize=UDim2.new(1,-48,1,-48)
        local maxPos=UDim2.fromScale(0.5,0.5)
        Animation.Tween(self.Root,{Size=maxSize,Position=maxPos},TWEEN_MAXIMIZE, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(TWEEN_MAXIMIZE,function()
            self.ResizeHandle.Visible=false -- sem resize durante maximizado
            self._WindowState.IsAnimating=false
        end)
    end
end

function Window:Close()
    if self._IsDestroyed then return end
    if self._Blur then
        Animation.Tween(self._Blur,{Size=0},0.18)
        task.delay(0.20,function() if self._Blur then pcall(function() self._Blur:Destroy() end) self._Blur=nil end end)
    end
    Animation.Tween(self.WindowClip,{BackgroundTransparency=1},0.20)
    Animation.Tween(self.Root,{Size=UDim2.fromOffset(self.Root.AbsoluteSize.X*0.94,self.Root.AbsoluteSize.Y*0.94)},0.24)
    task.delay(0.25,function() self:Destroy() end)
end

function Window:SetTheme(theme) self.Context.Theme:Apply(theme) end

function Window:Destroy()
    if self._IsDestroyed then return end
    self._IsDestroyed=true
    -- Desconecta tudo para evitar memory leak
    for _,conn in ipairs(self._Connections) do
        pcall(function() if conn and conn.Disconnect then conn:Disconnect() end end)
    end
    self._Connections={}
    if self._Blur then pcall(function() self._Blur:Destroy() end) self._Blur=nil end
    if self.Root then pcall(function() self.Root:Destroy() end) end
    -- Remove da lista do Engine
    if self.Context and self.Context.Windows then
        for i,w in ipairs(self.Context.Windows) do
            if w==self then table.remove(self.Context.Windows,i) break end
        end
    end
    -- Limpa referências
    self.Tabs={}
    self.ActiveTab=nil
end
return Window
