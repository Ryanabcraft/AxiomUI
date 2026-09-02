<div align="center">

# ◆ AXIOM UI ENGINE

### The desktop-grade interface framework for Roblox Luau

<p>
  <img src="https://img.shields.io/badge/version-1.0.0-8B37FF?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/Luau-strict-00DCFF?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/Rojo-ready-FF5B7A?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/license-MIT-35D399?style=for-the-badge&labelColor=0B0D14" />
</p>

<p>
  <b>Rayfield-class ergonomics × WindUI polish × Native Axiom design system</b><br/>
  Acrylic surfaces · Reactive state · Theme-bound tokens · Motion-first · Profile persistence
</p>

<p>
  <a href="#-quick-start"><b>Quick Start</b></a> •
  <a href="#-components">Components</a> •
  <a href="https://ryanabcraft.github.io/AxiomUI/"><b>Documentation Site</b></a> •
  <a href="Documentation/API.md">API Reference</a> •
  <a href="Documentation/DESIGN_SYSTEM.md">Design System</a>
</p>

<img src="https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/docs/preview-hero.png" width="100%" style="border-radius:16px; border:1px solid #1E2132;" />

</div>

---

## Why Axiom?

| | **Rayfield** | **WindUI** | **◆ Axiom** |
|---|---|---|---|
| **Aesthetic** | Flat, single-tone | Glass, rounded | **Desktop acrylic + layered depth** |
| **Layout** | Single column | Single column | **Sidebar rail + Inspector columns (62/38)** |
| **State** | Callbacks only | Callbacks | **State objects + `Get()/Set()` + `Changed` signal** |
| **Themes** | Hardcoded | Configurable | **Semantic tokens + `Theme:Bind()` live propagation** |
| **Persistence** | File-based | File-based | **Profiles + debounced AutoSave + JSON** |
| **Animation** | Basic tween | Smooth | **Quint 120-340ms + ripple + toast queue** |
| **Typography** | Gotham | Gotham | **Gotham hierarchy 9-14px + 8pt rhythm** |

> Axiom não é um menu. É um **workspace**: 88px icon rail, 66px chrome, borda luminosa, violeta `#8B37FF` → azul `#1F82FF`, notificação toast, resize/minimize/maximize, blur.

---

## ✨ Features

- **Window Manager** — draggable, resizable (620×400 min), minimize, maximize, close com animação, blur `Lighting.AxiomBlur`
- **Sidebar Workspace** — tabs com ícones Lucide, tooltip expansivo, páginas `ScrollingFrame` paginadas
- **8 Controls + Layouts** — Button, Toggle, Slider, Dropdown (multi), Input, Keybind, ColorPicker (HSV + hex), Section, Card, Panel, ColumnGroup
- **Reactive Core** — `State` + `Signal` + `Theme.Bind` — toda cor reage a `SetTheme()` em tempo real
- **Config Profiles** — `Axiom.Config:Register(key, handle)` → `Save("profile")` / `Load()` / `EnableAutoSave(true)` — serializa Color3 e KeyCode para JSON
- **Acrylic Design System** — `Background / Surface / SurfaceAlt / Stroke / Text / Primary` + `AcrylicTransparency`
- **Zero Vendors** — puro Luau, `Utility.Create` factory, recomendado para `ReplicatedStorage` + Rojo

---

## 🚀 Quick Start

### 1 — Rojo / Studio (recomendado)

```lua
-- ReplicatedStorage.Axiom (coloque a pasta Axiom aqui)
local Axiom = require(game.ReplicatedStorage.Axiom)

local Window = Axiom:CreateWindow({
    Title = "Axiom Control Center",
    Subtitle = "PREMIUM INTERFACE · v1.0",
    Theme = "Dark",
    Acrylic = true,
    Blur = true,
    Size = UDim2.fromOffset(780,510),
})

local Dashboard = Window:AddTab({Name="Dashboard", Icon="home"})
local Main, Inspector = Dashboard:AddColumnGroup({Ratio=0.62, Gap=14})

local Controls = Main:AddPanel({Name="CONTROL SURFACE"})
Controls:AddToggle({Name="Enable Feature", Default=false, Callback=function(v) print(v) end})
Controls:AddSlider({Name="Performance", Min=0, Max=100, Default=72, Suffix="%", Callback=print})
Controls:AddDropdown({Name="Processing mode", Options={"Balanced","Performance","Quality"}, Default="Balanced"})
Controls:AddInput({Name="Workspace note", Placeholder="Type here..."})
Controls:AddButton({Name="Run Action", Callback=function()
    Axiom:Notify({Title="Action complete", Description="The operation finished successfully."})
end})

local Appearance = Inspector:AddPanel({Name="APPEARANCE"})
Appearance:AddColorPicker({Name="Accent", Default=Color3.fromRGB(139,55,255)})
Appearance:AddButton({Name="Apply appearance"})
```

### 2 — Loadstring (executors)

```bash
python3 build.py   # gera dist/Axiom.lua (49 KB)
# hospede o conteúdo raw (gist.github / raw.githubusercontent)
```

```lua
local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua"))()

local Window = Axiom:CreateWindow({Title="Axiom Example", Theme="Dark", Acrylic=true})
Window:AddTab({Name="Home", Icon="home"}):AddButton({Name="Hello Axiom", Callback=function() print("◆") end})
```

### 3 — Wally

```toml
# wally.toml
[dependencies]
Axiom = "ryanabcraft/axiom@1.0.0"
```

---

## 🧩 Components

Toda chamada `Add*` retorna um handle com `Get()`, `Set(value)`, `SetVisible(bool)`, `Destroy()` e `Changed` quando stateful.

```lua
local Tab = Window:AddTab({Name="Configuration", Icon="settings"})

Tab:AddSection({Name="Preferences"})

local mode = Tab:AddDropdown({
    Name="Mode", Options={"Balanced","Performance","Quality"},
    Default="Balanced", Callback=function(v) print(v) end
})

local tags = Tab:AddDropdown({Name="Tags", Options={"UI","Motion","Acrylic"}, Multi=true})

Tab:AddInput({Name="Profile name", Placeholder="My workspace", Default="Default", Validate=function(t) return #t > 2 end})

Tab:AddColorPicker({Name="Accent color", Default=Color3.fromRGB(116,92,255), Callback=function(color, hex) print(hex) end})

Tab:AddKeybind({Name="Toggle interface", Default=Enum.KeyCode.RightShift, Callback=function() print("hotkey") end})

Tab:AddSlider({Name="Intensity", Min=0, Max=100, Increment=5, Suffix="%" })

Tab:EndSection()

-- Config com persistência
Axiom.Config:Register("mode", mode)
Axiom.Config:EnableAutoSave(true, "default")
Axiom.Config:Save("default")
```

| Method | Options chave |
|---|---|
| `AddButton` | `Name`, `Callback` |
| `AddToggle` | `Name`, `Default`, `Callback(value)` |
| `AddSlider` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `Callback` |
| `AddDropdown` | `Name`, `Options`, `Default`, `Multi`, `Callback` |
| `AddInput` | `Name`, `Default`, `Placeholder`, `Validate`, `Finished`, `Callback(value, enter)` |
| `AddKeybind` | `Name`, `Default` (KeyCode), `Callback` |
| `AddColorPicker` | `Name`, `Default` (Color3), `Callback(color, hex)` |
| `AddSection` / `EndSection` | `Name` — agrupa controles seguintes |
| `AddPanel` | `Name`, `MinHeight` — retorna container com mesma API |
| `AddColumnGroup` | `Ratio`, `Gap` — retorna `left, right` containers |

---

## 🎨 Themes

```lua
-- Built-in
Axiom:SetTheme("Light")
Axiom:SetTheme("Dark")

-- Custom
local Neon = Axiom:CreateTheme({
    Name = "Neon",
    Primary = Color3.fromRGB(0,220,255),
    Secondary = Color3.fromRGB(174,72,255),
    Radius = UDim.new(0,12),
    AcrylicTransparency = 0.18,
})
Axiom:SetTheme(Neon)
```

Tokens: `Background`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `Stroke`, `Text`, `TextMuted`, `Primary`, `Secondary`, `Success`, `Danger`, `Warning`, `Radius`, `Transparency`, `AcrylicTransparency`.

Veja `Documentation/DESIGN_SYSTEM.md` para princípios (hierarquia espacial, quiet glow, 120–340ms quintic).

---

## 🗂 Structure

```
Axiom/
├── Core/         → Engine, Window, Theme, State, Events (Signal)
├── Components/   → Base, Button, Toggle, Slider, Dropdown, Input, Keybind, ColorPicker, Section, Card
├── Services/     → Animation, Utility, Icons (Lucide), Config (profiles)
├── Themes/       → Dark, Light, Custom factory
├── Documentation/→ API.md + DESIGN_SYSTEM.md
├── Examples/     → Showcase.client.lua
└── dist/         → Axiom.lua (bundle loadstring)
```

---

## 🔔 Notifications

```lua
Axiom:Notify({
    Title="Welcome to Axiom",
    Description="Your premium workspace is ready.",
    Duration=5,
    Color=Color3.fromRGB(139,55,255)
})
```

---

## 📦 Build

```bash
python3 build.py  # → dist/Axiom.lua
```

Transpila `require(script.Parent.X)` → `__require("path")` e empacota todos os módulos em uma factory com cache.

---

## 🛣 Roadmap

- **v1.1** — modal manager, command palette, HSV picker rico
- **v1.2** — plugin registry, component slots, localização
- **v2.0** — declarative renderer + diff reconciliation

---

## 📄 License

MIT © 2026 Axiom UI Engine contributors. Feito para scripters que exigem nível Rayfield/WindUI com alma desktop.

<div align="center">

**[ ◆ Live Demo → ryanabcraft.github.io/AxiomUI ]** • **[ API Docs ]** • **[ Discord ]**

*If you ship with Axiom, star the repo — it fuels v1.1.*

</div>
