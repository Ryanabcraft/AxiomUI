# Axiom Icons

Axiom ships a curated Roblox build of the Lucide linear icon family. The registry is lookup-only: loading Axiom does not create or preload an instance for each icon.

```lua
local Tab=Window:AddTab({
    Name="Combat",
    Icon="crosshair",
})
```

Names are case-insensitive. Spaces, underscores, hyphens, compact names, and documented aliases resolve consistently, so `MapPin`, `map-pin`, `map_pin`, and `MAP PIN` all select `map-pin`.

Custom Roblox content remains supported:

```lua
Window:AddTab({Name="Custom",Icon=123456789})
Window:AddTab({Name="Custom",Icon="rbxassetid://123456789"})
```

Use `Axiom.Icons.Exists(name)` to check a name and `Axiom.Icons.List()` to receive a new, alphabetically sorted list of official names. Unknown names always resolve to the validated `info` fallback.

## General

`accessibility`, `activity`, `archive`, `at-sign`, `award`, `bookmark`, `calendar`, `check`, `check-circle`, `circle`, `clock`, `copy`, `download`, `edit`, `external-link`, `help-circle`, `history`, `home`, `info`, `menu`, `minus`, `more-horizontal`, `more-vertical`, `plus`, `refresh-cw`, `save`, `search`, `settings`, `trash`, `upload`, `x`

## Arrows

`arrow-down`, `arrow-down-left`, `arrow-down-right`, `arrow-left`, `arrow-left-right`, `arrow-right`, `arrow-up`, `arrow-up-down`, `arrow-up-left`, `arrow-up-right`, `chevron-down`, `chevron-left`, `chevron-right`, `chevron-up`, `chevrons-down`, `chevrons-up`

## Combat

`axe`, `bomb`, `bone`, `crosshair`, `flame`, `focus`, `shield`, `shield-alert`, `shield-check`, `shield-off`, `skull`, `sword`, `swords`, `target`, `zap`

## Player

`baby`, `contact`, `heart`, `heart-pulse`, `person-standing`, `shirt`, `smile`, `user`, `user-check`, `user-cog`, `user-minus`, `user-plus`, `user-x`, `users`

## Movement

`compass`, `gauge`, `grab`, `hand`, `move`, `move-diagonal`, `move-horizontal`, `move-vertical`, `navigation`, `plane`, `rocket`, `wind`

## Visual

`aperture`, `camera`, `contrast`, `eye`, `eye-off`, `image`, `palette`, `scan`, `scan-face`, `sun`, `moon`, `wand`, `zoom-in`, `zoom-out`

## World

`anchor`, `building`, `factory`, `flag`, `globe`, `landmark`, `leaf`, `map`, `map-pin`, `mountain`, `palmtree`, `sailboat`, `shrub`, `sprout`, `tent`, `tree-pine`, `trees`

## Vehicles

`bike`, `bus`, `car`, `fuel`, `train`, `truck`

## Development And Tools

`binary`, `bot`, `box`, `boxes`, `briefcase`, `bug`, `code`, `code-2`, `command`, `component`, `cpu`, `curly-braces`, `database`, `file-code`, `grid`, `hammer`, `hard-drive`, `hardhat`, `layers`, `package`, `server`, `sliders`, `terminal`, `terminal-square`, `wrench`

## Network

`bluetooth`, `cloud`, `link`, `network`, `radio`, `rss`, `signal`, `signal-high`, `signal-low`, `signal-medium`, `unlink`, `wifi`, `wifi-off`

## Security

`fingerprint`, `key`, `lock`, `file-key`, `file-lock`, `folder-key`, `folder-lock`, `siren`, `unlock`, `verified`

## Files

`clipboard`, `clipboard-check`, `clipboard-copy`, `file`, `file-audio`, `file-check`, `file-image`, `file-json`, `file-plus`, `file-search`, `file-text`, `files`, `folder`, `folder-check`, `folder-open`, `folder-plus`, `folder-search`, `folders`, `newspaper`, `paperclip`

## Game

`coins`, `crown`, `diamond`, `dices`, `gamepad`, `gem`, `ghost`, `gift`, `joystick`, `medal`, `puzzle`, `star`, `trophy`, `venetian-mask`

## Audio

`album`, `disc`, `fast-forward`, `headphones`, `list-music`, `mic`, `mic-off`, `music`, `pause`, `play`, `podcast`, `rewind`, `speaker`, `volume`, `volume-off`

## Devices And UI

`airplay`, `cast`, `keyboard`, `layout-dashboard`, `list`, `monitor`, `mouse`, `mouse-pointer`, `sidebar`, `smartphone`, `tablet`, `toggle-left`, `toggle-right`, `tv`, `webcam`

## Social

`bell`, `mail`, `mail-open`, `message-circle`, `message-square`, `phone`, `send`, `share`, `thumbs-down`, `thumbs-up`

## Friendly Aliases

`aim`, `aimbot`, `alert`, `arrowdown`, `arrowleft`, `arrowright`, `arrowup`, `body`, `bolt`, `braces`, `camera-off`, `close`, `combat`, `config`, `configuration`, `default`, `developer`, `document`, `earth`, `esp`, `farm`, `fly`, `gear`, `gun`, `health`, `help`, `house`, `location`, `mappin`, `misc`, `movement`, `player`, `profile`, `radar`, `refresh`, `running`, `scope`, `scripts`, `ship`, `slider`, `speed`, `sparkles`, `teleport`, `tool`, `tp`, `tree`, `vehicle`, `vision`, `visual`, `walk`, `world`
