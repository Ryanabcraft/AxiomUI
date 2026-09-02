# Axiom UI Engine — API Reference

## Engine

### `Axiom:CreateWindow(options)`

Creates a desktop-style window. Options: `Title`, `Subtitle`, `Theme`, `Size`, `Acrylic`, and `Blur`. `Acrylic` controls the window surface transparency. `Blur` adds depth to that local surface only; it never creates or changes a `BlurEffect`, `Lighting`, or `CurrentCamera` object.

### `Axiom:SetTheme(theme)`

Accepts `"Dark"`, `"Light"`, or a custom theme table.

### `Axiom:CreateTheme(overrides)`

Returns a theme based on Axiom Dark with the specified token overrides.

### `Axiom:Notify(options)`

Creates a toast. Options: `Title`, `Description`, `Duration`, and `Color`.

### `Axiom:Destroy()`

Removes all Axiom UI, listeners, pending tasks, and active animations.

## Window

| Method | Description |
| --- | --- |
| `AddTab(options)` | Adds a sidebar tab and returns a Tab. |
| `SelectTab(tab)` | Activates a tab. |
| `Minimize()` | Toggles compact mode. |
| `Close()` | Closes with animation. |
| `SetTheme(theme)` | Applies a theme to bound properties. |
| `Destroy()` | Immediately destroys the window. |

## Tab and controls

Every `Add...` method accepts an options table and returns a control handle.

| Method | Important options |
| --- | --- |
| `AddButton` | `Name`, `Callback` |
| `AddToggle` | `Name`, `Default`, `Callback` |
| `AddSlider` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `Callback` |
| `AddDropdown` | `Name`, `Options`, `Default`, `Multi`, `Callback` |
| `AddInput` | `Name`, `Default`, `Placeholder`, `Validate`, `Finished`, `Callback` |
| `AddKeybind` | `Name`, `Default`, `Callback` |
| `AddColorPicker` | `Name`, `Default`, `Callback(color, hex)` |
| `AddSection` | `Name`; subsequent controls enter the section |
| `EndSection` | Returns subsequent controls to the page root |
| `AddPanel` | Creates a bordered acrylic panel and returns a container API |

Use `local left, right = Tab:AddColumnGroup({Ratio = 0.62, Gap = 14})` to reproduce a desktop inspector layout. Both columns, and panels returned by `AddPanel`, expose the same `Add...` component methods as a tab.

Control handles expose `Get()`, `Set(value)`, `SetVisible(boolean)`, `Destroy()`, and `Changed` when stateful.

## Configuration

Register a stateful control with `Axiom.Config:Register(key, control)`. Use `Save(profile)` and `Load(profile)`. Enable debounced automatic updates with `EnableAutoSave(true, profile)`. Profiles use JSON on executors that expose filesystem functions; otherwise they remain available in memory for the current session.
