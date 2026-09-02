local TweenService = game:GetService("TweenService")
local Animation = {}

function Animation.Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Animation.Hover(gui, normal, hovered)
    gui.MouseEnter:Connect(function() Animation.Tween(gui, hovered) end)
    gui.MouseLeave:Connect(function() Animation.Tween(gui, normal) end)
end

function Animation.Ripple(button, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "AxiomRipple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.fromScale(0.5, 0.5)
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.72
    ripple.ZIndex = button.ZIndex + 2
    ripple.Parent = button
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    local target = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.8
    Animation.Tween(ripple, { Size = UDim2.fromOffset(target, target), BackgroundTransparency = 1 }, 0.42)
    task.delay(0.45, function() ripple:Destroy() end)
end

return Animation
