# Axiom UI Engine — API Reference

## Carregamento

```lua
local Axiom=loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua"
))()
```

`Axiom.Version` informa a versão do engine. O objeto retornado mantém `Windows`, `Config`, `Icons`, `Theme` e a `ScreenGui` raiz enquanto estiver ativo.

## Engine

### `Axiom:CreateWindow(options)`

Cria e retorna uma Window.

| Option | Tipo | Default | Descrição |
| --- | --- | --- | --- |
| `Title` | string | `AXIOM` | Título da janela |
| `Subtitle` | string | `UI ENGINE` | Linha auxiliar |
| `Theme` | string/table | tema atual | `Dark`, `Light` ou tema customizado |
| `Size` | UDim2 | `500x475` | Tamanho lógico de referência |
| `Scale` | number | `1` | Multiplicador entre `0.75` e `1.25` |
| `Acrylic` | boolean | `true` | Surface translúcida |
| `Blur` | boolean | `false` | Tratamento local adicional de profundidade |
| `ReopenPill` | boolean | `true` | X esconde e oferece cápsula de retorno |

A janela se ajusta ao viewport e à safe area. `Blur` não cria `BlurEffect`, não altera `Lighting` e não modifica `CurrentCamera`.

### `Axiom:SetTheme(theme)`

Aceita `"Dark"`, `"Light"` ou uma tabela criada com `CreateTheme`. O Theme é compartilhado pelas Windows da mesma instância Axiom.

### `Axiom:CreateTheme(overrides)`

Retorna um tema baseado no Dark com os tokens informados sobrescritos.

### `Axiom:Notify(options)`

Cria um toast e retorna sua instância. Options: `Title`, `Description`, `Duration` e `Color`.

### `Axiom:Destroy()`

Destrói todas as Windows, listeners, tasks, animações, perfis em memória e a `ScreenGui`. A instância não deve ser reutilizada.

## Window

| Método | Descrição |
| --- | --- |
| `AddTab(options)` | Cria uma Tab com `Name` e `Icon` |
| `SelectTab(tab)` | Ativa uma Tab pertencente à Window |
| `GetDeviceMode()` | Retorna `Desktop`, `Tablet` ou `Mobile` |
| `Minimize()` | Alterna entre header compacto e geometria anterior |
| `Maximize()` | Alterna entre safe area máxima e geometria anterior |
| `Hide()` | Esconde preservando instância e estado |
| `Show()` | Restaura a mesma instância |
| `ToggleVisibility()` | Alterna `Hide`/`Show` |
| `Close()` | Esconde com ReopenPill; sem pill, encerra permanentemente |
| `SetTheme(themeTable)` | Aplica diretamente uma tabela de tema compartilhada |
| `Destroy()` | Remove definitivamente Window, pill e listeners |

Drag aceita mouse e touch, preserva o offset inicial e faz clamp na área segura. Resize aparece em dispositivos com mouse quando a Window não está minimizada ou maximizada. Tabs excedentes usam scroll vertical e a ativa permanece visível.

## Tab e containers

`Window:AddTab({Name,Icon})` retorna uma Tab. `Icon` aceita nome Axiom, alias, ID numérico ou ContentId suportado.

| Método | Retorno |
| --- | --- |
| `Tab:Select()` | nada; ativa a própria Tab |
| `Tab:AddColumnGroup({Ratio,Gap})` | dois containers (`left`, `right`) |
| `AddSection({Name})` | o mesmo container, agora apontando para a Section |
| `EndSection()` | o mesmo container, novamente na raiz |
| `AddPanel({Name,MinHeight})` | container com a API `Add...` |
| `AddCard(options)` | `Frame` visual |

Column groups usam `Ratio=0.62` e `Gap=14` quando omitidos. Eles empilham em Mobile portrait ou quando o conteúdo lógico fica menor que 340 px.

## Componentes

| Método | Options principais | Retorno |
| --- | --- | --- |
| `AddButton` | `Name`, `Callback` | handle base |
| `AddToggle` | `Name`, `Default`, `Callback` | handle boolean |
| `AddSlider` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `Callback` | handle number |
| `AddDropdown` | `Name`, `Options`, `Default`, `Multi`, `Callback` | handle string/list |
| `AddInput` | `Name`, `Default`, `Placeholder`, `Validate`, `Finished`, `Callback` | handle string |
| `AddKeybind` | `Name`, `Default`, `Callback` | handle `Enum.KeyCode` |
| `AddColorPicker` | `Name`, `Default`, `Callback(color,hex)` | handle `Color3` |
| `AddCard` | options visuais | `Frame` |

### Stateful handle

Toggle, Slider, Dropdown, Input, Keybind e ColorPicker expõem:

- `Get()`
- `Set(value)`
- `SetVisible(boolean)`
- `Destroy()`
- `Changed`
- `Instance`

Button usa o handle base para `SetVisible`, `Destroy` e `Instance`, mas não possui estado ou `Changed`. Card retorna diretamente um `Frame`.

## Icons

### `Axiom.Icons.Get(nameOrId)`

Resolve nomes oficiais, aliases, IDs numéricos e ContentIds. Nomes aceitam caixa livre, espaços, underscore, hífen e forma compacta. Falhas retornam o ícone `info`.

### `Axiom.Icons.Exists(name)`

Retorna `true` para nome oficial, alias ou variante normalizada. IDs e URLs customizados não fazem parte do registry e retornam `false` aqui, mesmo que `Get` os aceite.

### `Axiom.Icons.List()`

Retorna uma nova lista ordenada com os 247 nomes oficiais. Alterar a lista retornada não modifica o registry.

Consulte [ICONS.md](ICONS.md).

## Config

### `Axiom.Config:Register(key,control)`

Registra um handle stateful e retorna o próprio handle. A entrada é removida quando o controle é destruído.

### `Axiom.Config:EnableAutoSave(enabled,profile)`

Ativa/desativa autosave com debounce de 350 ms.

### `Axiom.Config:Serialize()`

Retorna uma tabela com os valores registrados. `Color3` e `Enum.KeyCode` recebem representação serializável.

### `Axiom.Config:LoadTable(data)`

Aplica uma tabela diretamente aos controles registrados.

### `Axiom.Config:Save(profile)`

Salva em memória e retorna a tabela serializada. Quando `writefile` existe, escreve `<namespace>/<profile>.json`.

### `Axiom.Config:Load(profile)`

Carrega memória primeiro e filesystem depois. Retorna `true` quando encontrou um perfil.

### `Axiom.Config:Destroy()`

Desconecta autosave e limpa perfis/controles em memória.

## Theme tokens

`Background`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `Stroke`, `Text`, `TextMuted`, `Primary`, `Secondary`, `Success`, `Warning`, `Danger`, `Radius`, `Transparency` e `AcrylicTransparency`.

Bindings de tema atualizam propriedades registradas pelo engine. Cores locais não vinculadas permanecem como foram criadas.
