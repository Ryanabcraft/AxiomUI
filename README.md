<div align="center">

# ◆ AXIOM UI ENGINE

### A UI definitiva para **scripts Roblox** — Rayfield e WindUI level

<p>
  <img src="https://img.shields.io/badge/version-1.0.0-8B37FF?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/SCRIPTS-loadstring-00DCFF?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/EXECUTOR-ready-FF5B7A?style=for-the-badge&labelColor=0B0D14" />
  <img src="https://img.shields.io/badge/license-MIT-35D399?style=for-the-badge&labelColor=0B0D14" />
</p>

<p>
  <b>Feita para quem faz SCRIPT.</b><br/>
  1 linha <code>loadstring</code> · Acrylic desktop · Sidebar inspector · Estado reativo · Temas live
</p>

<p>
  <a href="#-uso-em-3-segundos"><b>Usar Agora</b></a> •
  <a href="#-components">Components</a> •
  <a href="https://ryanabcraft.github.io/AxiomUI/"><b>Site Oficial</b></a> •
  <a href="Documentation/API.md">API</a>
</p>

</div>

---

## ⚡ Por que Axiom vs Rayfield/WindUI?

| | **Rayfield** | **WindUI** | **◆ Axiom** |
|---|---|---|---|
| **Foco** | Scripts ✓ | Scripts ✓ | **Scripts ✓ — 1 linha loadstring** |
| **Visual** | Flat | Glass | **Desktop acrylic + depth** |
| **Layout** | Coluna única | Coluna única | **Sidebar 88px + Inspector 62/38** |
| **State** | Só callback | Só callback | **State `Get()/Set()` + `Changed`** |
| **Temas** | Hardcoded | Configurável | **Tokens live `Theme:Bind()`** |
| **Tamanho** | ~80KB | ~120KB | **94KB — compacto** |
| **Motion** | Básica | Suave | **Quint 120-340ms + ripple + toast** |

> **Axiom é drop-in replacement para Rayfield/WindUI.** Mesma ideia, acabamento de produto desktop. Copiar, colar e sair usando.

Responsive across desktop, tablet, mobile portrait, and mobile landscape, with automatic safe-area fitting and stacked columns on narrow screens.

---

## 🚀 Uso em 3 segundos (PARA SCRIPTS)

### ✅ JEITO CERTO — Loadstring (igual Rayfield/WindUI)

Cole isso no seu script/executor — **é só isso**:

```lua
local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua"))()

local Window = Axiom:CreateWindow({
    Title = "Meu Script",
    Subtitle = "powered by Axiom",
    Theme = "Dark",
    Acrylic = true,
    Blur = true,
    ReopenPill = true,
})

local Tab = Window:AddTab({Name="Main", Icon="home"})
Tab:AddToggle({Name="Auto Farm", Default=false, Callback=function(v) print("Farm:", v) end})
Tab:AddSlider({Name="Speed", Min=0, Max=100, Default=50, Suffix="%", Callback=print})
Tab:AddButton({Name="Ativar", Callback=function()
    Axiom:Notify({Title="Ativado!", Description="Seu script rodou."})
end})
```

**Pronto.** Seu executor roda e a UI aparece no jogo instantaneamente.

O botão X preserva a instância e abre uma cápsula discreta no topo para reabrir a mesma Window. Posição, tamanho, tab ativa e valores dos controles permanecem intactos. Use `Window:Hide()`, `Window:Show()` ou `Window:ToggleVisibility()` para controlar isso por código. `Window:Destroy()` continua sendo a remoção definitiva. Para manter o X destrutivo, crie a janela com `ReopenPill = false`.

### 📦 Alternativa — Arquivo local

Se seu executor suporta `writefile`/`readfile`, baixe `dist/Axiom.lua` e:

```lua
local Axiom = loadstring(readfile("Axiom.lua"))()
-- resto igual
```

---

## 🧩 Components — mesma API Rayfield, mais poderosa

Todo `Add*` retorna handle com `Get()`, `Set(value)`, `SetVisible(bool)`, `Destroy()` e evento `Changed`.

```lua
local Tab = Window:AddTab({Name="Config", Icon="settings"})
Tab:AddSection({Name="Farm"})

local mode = Tab:AddDropdown({
    Name="Mode", Options={"Legit","Rage","Farming"},
    Default="Legit", Callback=function(v) print(v) end
})

Tab:AddDropdown({Name="Tags", Options={"Auto","Safe","Fast"}, Multi=true})

Tab:AddInput({Name="Webhook", Placeholder="https://discord.com/...", Validate=function(t) return #t > 10 end})

Tab:AddColorPicker({Name="Cor", Default=Color3.fromRGB(139,55,255), Callback=function(color, hex) print(hex) end})

Tab:AddKeybind({Name="Abrir/Fechar", Default=Enum.KeyCode.RightShift, Callback=function() print("toggle") end})

Tab:AddSlider({Name="Delay", Min=0, Max=10, Increment=0.5, Suffix="s" })

Tab:EndSection()

-- Salvar config (opcional, igual Rayfield)
Axiom.Config:Register("mode", mode)
Axiom.Config:EnableAutoSave(true, "meuScript")
Axiom.Config:Save("default") -- salva em AxiomUI/default.json se executor tiver writefile
```

| Method | O que faz |
|---|---|
| `AddButton` | `Name`, `Callback` |
| `AddToggle` | `Name`, `Default` (bool), `Callback(bool)` |
| `AddSlider` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix` |
| `AddDropdown` | `Name`, `Options` (lista), `Default`, `Multi` (multi-select) |
| `AddInput` | `Name`, `Placeholder`, `Validate` |
| `AddKeybind` | `Name`, `Default` (KeyCode), `Callback` — aperta a tecla e dispara |
| `AddColorPicker` | `Name`, `Default` (Color3), `Callback(color, hex)` |
| `AddSection` / `EndSection` | Agrupa controles com título |
| `AddPanel` | Cria painel com borda — retorna container com mesma API |
| `AddColumnGroup` | `Ratio`, `Gap` — cria 2 colunas (ex: `local Main, Side = Tab:AddColumnGroup({Ratio=0.62})`) |

---

## 🎨 Temas — troca em 1 linha

```lua
Axiom:SetTheme("Light") -- ou "Dark"

local Neon = Axiom:CreateTheme({
    Name = "Neon",
    Primary = Color3.fromRGB(0,220,255),
    Secondary = Color3.fromRGB(174,72,255),
    Radius = UDim.new(0,12),
})
Axiom:SetTheme(Neon)
```

Tokens: `Background`, `Surface`, `SurfaceAlt`, `Stroke`, `Text`, `Primary`, `Secondary`.

---

## 🔔 Notificação (toast)

```lua
Axiom:Notify({
    Title="Farm completo!",
    Description="Você ganhou 1,250 coins.",
    Duration=4,
    Color=Color3.fromRGB(139,55,255)
})
```

---

## 💡 Exemplo completo — estilo WindUI/Rayfield

```lua
local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua"))()

local Window = Axiom:CreateWindow({Title="Meu Hub", Subtitle="v1.0 · Axiom", Theme="Dark", Acrylic=true, Blur=true})
local Main = Window:AddTab({Name="Main", Icon="home"})
local Left, Right = Main:AddColumnGroup({Ratio=0.62, Gap=14})

local Controls = Left:AddPanel({Name="CONTROL SURFACE"})
Controls:AddToggle({Name="Auto Farm", Default=false, Callback=function(v) _G.Farm=v end})
Controls:AddSlider({Name="Speed", Min=16, Max=100, Default=32, Suffix=" walkspeed"})
Controls:AddDropdown({Name="Mode", Options={"Balanced","Performance","Quality"}, Default="Balanced"})

local Visual = Right:AddPanel({Name="VISUAL"})
Visual:AddColorPicker({Name="Accent", Default=Color3.fromRGB(139,55,255)})
Visual:AddKeybind({Name="Toggle UI", Default=Enum.KeyCode.RightShift})

Axiom:Notify({Title="Axiom carregada!", Description="Pronto para usar."})
```

---

## ❓ FAQ para scripters

**Funciona em qual executor?** Qualquer um que tenha `loadstring` + `game:HttpGet` (Synapse, Fluxus, Hydrogen, etc). Testado com `gethui` fallback.

**Como hospedar?** O arquivo já está hospedado no GitHub raw. Só usar a URL. Se quiser, hospede `dist/Axiom.lua` no seu próprio raw/gist.

**É pesada?** Não — o bundle atual tem 94KB com window manager, 8 controles, temas, profiles e animações.

---

## 🛣 Roadmap

- **v1.1** — modal, command palette, ColorPicker HSV melhor
- **v1.2** — plugin registry, slots, localização
- **v2.0** — renderer declarativo

---

## 📄 Licença

MIT © 2026 Axiom contributors — Use em qualquer script, hub, loader. Só mantém o crédito.

<div align="center">

**[ ◆ Site → ryanabcraft.github.io/AxiomUI ]** • **[ Raw → dist/Axiom.lua ]** • **[ API Docs ]**

*Curtiu? Deixa a ★ no repo — ajuda o projeto crescer.*

</div>
