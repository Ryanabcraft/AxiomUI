local Players=game:GetService("Players")
local Theme=require(script.Parent.Theme)
local Window=require(script.Parent.Window)
local Config=require(script.Parent.Parent.Services.Config)
local Animation=require(script.Parent.Parent.Services.Animation)
local Cleanup=require(script.Parent.Parent.Services.Cleanup)
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
