local Axiom=require(script.Parent.Parent)

local Window=Axiom:CreateWindow({
    Title="Axiom Control Center", Subtitle="PREMIUM INTERFACE · v1.0", Theme="Dark",
    Acrylic=true, Blur=true, Size=UDim2.fromOffset(780,510),
})

local Dashboard=Window:AddTab({Name="Dashboard",Icon="home"})
local Main,Inspector=Dashboard:AddColumnGroup({Ratio=0.62,Gap=14})
local Controls=Main:AddPanel({Name="CONTROL SURFACE",MinHeight=240})
Controls:AddToggle({Name="Enable Feature",Default=false,Callback=function(value) print("Feature:",value) end})
Controls:AddSlider({Name="Performance",Min=0,Max=100,Default=72,Suffix="%",Callback=function(value) print(value) end})
Controls:AddDropdown({Name="Processing mode",Options={"Balanced","Performance","Quality"},Default="Balanced"})
Controls:AddInput({Name="Workspace note",Placeholder="Type here..."})
Controls:AddButton({Name="Run Action",Callback=function() Axiom:Notify({Title="Action complete",Description="The operation finished successfully."}) end})
local Appearance=Inspector:AddPanel({Name="APPEARANCE",MinHeight=340})
Appearance:AddDropdown({Name="Preset",Options={"Axiom","Midnight","Electric"},Default="Axiom"})
Appearance:AddColorPicker({Name="Accent",Default=Color3.fromRGB(139,55,255)})
Appearance:AddButton({Name="Apply appearance"})

local Settings=Window:AddTab({Name="Configuration",Icon="settings"})
Settings:AddSection({Name="Preferences"})
local mode=Settings:AddDropdown({Name="Mode",Options={"Balanced","Performance","Quality"},Default="Balanced",Callback=function(value) print(value) end})
local tags=Settings:AddDropdown({Name="Tags",Options={"UI","Motion","Acrylic"},Multi=true})
local name=Settings:AddInput({Name="Profile name",Placeholder="My workspace",Default="Default"})
local accent=Settings:AddColorPicker({Name="Accent color",Default=Color3.fromRGB(116,92,255)})
local key=Settings:AddKeybind({Name="Toggle interface",Default=Enum.KeyCode.RightShift,Callback=function() print("Keybind activated") end})
Settings:EndSection()

Axiom.Config:Register("mode",mode)
Axiom.Config:Register("tags",tags)
Axiom.Config:Register("profileName",name)
Axiom.Config:Register("accent",accent)
Axiom.Config:Register("toggleKey",key)

Axiom:Notify({Title="Welcome to Axiom",Description="Your premium workspace is ready.",Duration=5})
