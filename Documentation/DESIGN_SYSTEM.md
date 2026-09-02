# Axiom Design System

Axiom uses semantic tokens instead of hard-coded component palettes. A theme defines `Background`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `Stroke`, `Text`, `TextMuted`, `Primary`, `Secondary`, state colors, radius, transparency, and motion timing.

## Principles

1. **Spatial hierarchy:** the canvas is darkest; elevated surfaces become progressively lighter.
2. **Quiet glow:** saturated color communicates focus and state, never decoration alone.
3. **Responsive motion:** transitions last 120–340 ms and use quintic easing.
4. **Readable density:** 10–15 px typography, 8 px spacing rhythm, 10–14 px radii.
5. **Accessible feedback:** active states combine color, position, and motion.

## Reference layout

The default shell uses an 88 px icon rail, 58 px window chrome, compact window controls, a thin luminous border, a violet-to-blue accent pair, and optional 62/38 content columns. This creates the same hierarchy as a professional editor: navigation, primary canvas, and contextual inspector.

## Conceptual logo

The Axiom mark is a split orbital “A”: two ascending planes intersected by a luminous horizontal axis. It represents a stable rule becoming a system. Recommended wordmark: uppercase geometric lettering, generous tracking, electric-violet axis.

## Custom theme

```lua
local Neon=Axiom:CreateTheme({
    Name="Neon",
    Primary=Color3.fromRGB(0,220,255),
    Secondary=Color3.fromRGB(174,72,255),
    Radius=UDim.new(0,12),
    AcrylicTransparency=0.18,
})

Axiom:SetTheme(Neon)
```
