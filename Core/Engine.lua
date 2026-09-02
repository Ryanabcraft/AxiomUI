local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local Theme=require(script.Parent.Theme)
local Window=require(script.Parent.Window)
local Config=require(script.Parent.Parent.Services.Config)
local Animation=require(script.Parent.Parent.Services.Animation)
local Utility=require(script.Parent.Parent.Services.Utility)
local Dark=require(script.Parent.Parent.Themes.Dark)
local Light=require(script.Parent.Parent.Themes.Light)
local Custom=require(script.Parent.Parent.Themes.Custom)

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

-- BUG 1 FIX: Blur global removido. Acrylic agora é simulado localmente via transparência + gradient.
-- Se Blur=true, cria um BlurEffect EXTREMAMENTE sutil (Size 2) por janela, com lifecycle amarrado à janela.
-- Nunca Size 12 que destrói visibilidade do jogo.
function Engine:CreateWindow(options)
    options=options or {}
    if options.Theme then self:SetTheme(options.Theme) end
    local window=Window.new(self,options)
    table.insert(self.Windows,window)

    -- Acrylic é local (BackgroundTransparency + UIGradient), não precisa de Blur global.
    -- Blur separado e seguro: apenas se explicitamente pedido, intensidade mínima e com cleanup.
    if options.Blur then
        local blur
        local ok=pcall(function()
            blur=Instance.new("BlurEffect")
            blur.Name="AxiomBlur_"..tostring(window.Root:GetDebugId())
            blur.Size=0
            blur.Enabled=true
            -- Tenta Lighting, fallback para CurrentCamera (ambos suportam BlurEffect)
            local parented=false
            pcall(function() blur.Parent=Lighting; parented=true end)
            if not parented then
                pcall(function() blur.Parent=workspace.CurrentCamera end)
            end
        end)
        if ok and blur and blur.Parent then
            window._Blur=blur
            -- Intensidade premium sutil — fundo continua claramente visível
            Animation.Tween(blur,{Size=2},0.32)
        else
            if blur then pcall(function() blur:Destroy() end) end
            window._Blur=nil
        end
    end

    return window
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
    -- Limpa todos os blurs por janela (não deixa órfão)
    for _,w in ipairs(self.Windows) do
        if w._Blur then pcall(function() w._Blur:Destroy() end) w._Blur=nil end
        if w.Destroy then pcall(function() w:Destroy() end) end
    end
    -- Fallback: remove qualquer AxiomBlur legado em Lighting/Camera
    pcall(function()
        local legacy=Lighting:FindFirstChild("AxiomBlur")
        if legacy then legacy:Destroy() end
    end)
    pcall(function()
        local cam=workspace.CurrentCamera
        if cam then
            for _,v in ipairs(cam:GetChildren()) do
                if v.Name:find("AxiomBlur") then v:Destroy() end
            end
        end
    end)
    if self.Gui then pcall(function() self.Gui:Destroy() end) end
end

return Engine
