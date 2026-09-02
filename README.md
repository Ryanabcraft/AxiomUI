<div align="center">

# AXIOM UI ENGINE

**Uma control surface responsiva para scripts Roblox.**

[![Pages](https://github.com/Ryanabcraft/AxiomUI/actions/workflows/pages.yml/badge.svg)](https://github.com/Ryanabcraft/AxiomUI/actions/workflows/pages.yml)
[![Build](https://github.com/Ryanabcraft/AxiomUI/actions/workflows/release.yml/badge.svg)](https://github.com/Ryanabcraft/AxiomUI/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-65E6A7?labelColor=090A10)](LICENSE)
[![Icons](https://img.shields.io/badge/icons-247_Lucide-8B5CF6?labelColor=090A10)](Documentation/ICONS.md)

[Site](https://ryanabcraft.github.io/AxiomUI/) · [API](Documentation/API.md) · [Ícones](Documentation/ICONS.md) · [Design system](Documentation/DESIGN_SYSTEM.md) · [MCP para IA](mcp/README.md) · [Exemplos](Examples)

</div>

---

Axiom organiza scripts Roblox como uma aplicação compacta: window manager, sidebar com scroll, componentes stateful, layouts em colunas, temas semânticos e perfis opcionais. Tudo é distribuído como um único arquivo Luau compatível com `loadstring`.

## Instalação

```lua
local Axiom=loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua"
))()
```

O bundle atual possui **110.727 bytes**. A URL de `main` acompanha o desenvolvimento; consulte [Releases](https://github.com/Ryanabcraft/AxiomUI/releases) para snapshots publicados.

Requisitos do executor:

- `loadstring` e `game:HttpGet` para carregamento remoto.
- `gethui` é usado quando disponível; `PlayerGui`/`CoreGui` são os fallbacks.
- `writefile`, `readfile`, `isfile` e `makefolder` são opcionais e usados apenas para persistência de perfis.

## Primeiro painel

```lua
local Window=Axiom:CreateWindow({
    Title="My Hub",
    Subtitle="AXIOM / LIVE",
    Theme="Dark",
    Acrylic=true,
    Blur=true,
    ReopenPill=true,
})

local Combat=Window:AddTab({Name="Combat",Icon="crosshair"})

local enabled=Combat:AddToggle({
    Name="Enable feature",
    Default=false,
    Callback=function(value)
        print("Enabled:",value)
    end,
})

Combat:AddSlider({
    Name="Movement speed",
    Min=16,
    Max=100,
    Default=32,
    Increment=1,
})

Axiom.Config:Register("enabled",enabled)
Axiom:Notify({Title="Ready",Description="Axiom is running."})
```

## O que está incluído

### Window system

- Drag de mouse/touch sem jump inicial e com clamp na safe area.
- Resize desktop com limites mínimos e máximos.
- Minimize/restore e maximize/restore preservando geometria.
- `Hide()`, `Show()` e `ToggleVisibility()` preservando estado.
- ReopenPill opcional e responsivo.
- Modos Desktop, Tablet e Mobile, com escala de usuário entre `0.75` e `1.25`.
- Sidebar de 56/72/88 px com scroll vertical e auto-scroll da tab ativa.
- `ColumnGroup` que empilha automaticamente em telas estreitas.

### Componentes

| API | Retorno | Uso principal |
| --- | --- | --- |
| `AddButton` | handle base | Executar uma ação |
| `AddToggle` | handle stateful | Boolean |
| `AddSlider` | handle stateful | Número incremental |
| `AddDropdown` | handle stateful | Seleção única ou múltipla |
| `AddInput` | handle stateful | Texto e validação |
| `AddKeybind` | handle stateful | `Enum.KeyCode` |
| `AddColorPicker` | handle stateful | `Color3` e HEX |
| `AddCard` | `Frame` | Surface visual |

Handles stateful expõem `Get()`, `Set(value)`, `SetVisible(boolean)`, `Destroy()` e `Changed`. Buttons usam o mesmo handle base, mas não possuem estado ou evento `Changed`. `Section`, `Panel` e `ColumnGroup` são helpers de composição.

## 247 ícones validados

O registry usa uma única família Lucide linear para Roblox, com **247 nomes oficiais** e **51 aliases**. Nomes são normalizados:

```lua
Axiom.Icons.Get("MapPin")
Axiom.Icons.Get("map-pin")
Axiom.Icons.Get("map_pin")
Axiom.Icons.Get("MAP PIN")
-- Todos retornam o mesmo asset.

Axiom.Icons.Exists("crosshair") -- true
local names=Axiom.Icons.List()  -- cópia ordenada
```

IDs numéricos, `rbxassetid://`, `rbxasset://` e URLs de conteúdo continuam aceitos. Nomes desconhecidos usam o ícone `info` validado. Consulte o [catálogo completo](Documentation/ICONS.md).

## Layout estruturado

```lua
local Dashboard=Window:AddTab({Name="Dashboard",Icon="layout-dashboard"})
local Main,Inspector=Dashboard:AddColumnGroup({Ratio=0.62,Gap=14})

local Controls=Main:AddPanel({Name="CONTROL SURFACE"})
Controls:AddToggle({Name="Automation"})

local Details=Inspector:AddPanel({Name="INSPECTOR"})
Details:AddDropdown({Name="Mode",Options={"Balanced","Performance"}})
```

## Configuração

```lua
Axiom.Config:Register("mode",modeControl)
Axiom.Config:EnableAutoSave(true,"default")
Axiom.Config:Save("default")
Axiom.Config:Load("default")
```

Sem filesystem, os perfis continuam disponíveis em memória durante a sessão. Consulte a [referência da API](Documentation/API.md) para `Serialize()` e `LoadTable()`.

## Temas

```lua
Axiom:SetTheme("Light")

local Neon=Axiom:CreateTheme({
    Name="Neon",
    Primary=Color3.fromRGB(0,220,255),
    Secondary=Color3.fromRGB(174,72,255),
})
Axiom:SetTheme(Neon)
```

`Acrylic` cria surfaces translúcidas inspiradas em acrylic. `Blur` ajusta o tratamento local de profundidade; Axiom não cria `BlurEffect` em `Lighting` nem altera a câmera.

## API de Window

`AddTab`, `SelectTab`, `GetDeviceMode`, `Minimize`, `Maximize`, `Hide`, `Show`, `ToggleVisibility`, `Close`, `SetTheme` e `Destroy`.

## MCP para assistentes de IA

O servidor local em `mcp/axiom_mcp.py` entrega a documentação oficial como resources MCP e oferece tools para pesquisar a API, consultar documentos, resolver ícones e ler metadados reais do projeto.

```bash
python mcp/axiom_mcp.py
```

Ele usa `stdio`, não possui dependências externas e inclui exemplos de configuração para Claude Desktop, Cursor e OpenCode. Consulte o [guia do Axiom MCP](mcp/README.md).

## Desenvolvimento

```bash
python build.py
```

O build reúne os módulos de `Core`, `Components`, `Services` e `Themes` em `dist/Axiom.lua`. Exemplos não entram no bundle.

```text
Core/           Engine, Window, Theme, State e Events
Components/     Componentes e handles
Services/       Animation, Cleanup, Config, Icons e Utility
Themes/         Dark, Light e Custom
Documentation/  API, catálogo de ícones e design system
Examples/       Showcase e validação de integridade
docs/           Site estático publicado no GitHub Pages
mcp/            Servidor de documentação para assistentes de IA
```

## Compatibilidade

Axiom oferece uma API familiar para quem já construiu hubs com outras bibliotecas Roblox, mas **não é uma implementação drop-in** de Rayfield ou WindUI. Opções, retornos e recursos devem seguir a documentação Axiom.

## Licença

[MIT](LICENSE). Cópias ou porções substanciais devem preservar o aviso de copyright e permissão incluído na licença.
