local TweenService = game:GetService("TweenService")
local Animation = {}
local activeTweens=setmetatable({},{__mode="k"})

function Animation.Tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then return nil end
    local previous=activeTweens[instance]
    if previous then pcall(function() previous:Cancel() end) end
    local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    activeTweens[instance]=tween
    tween.Completed:Once(function()
        if activeTweens[instance]==tween then activeTweens[instance]=nil end
    end)
    tween:Play()
    return tween
end

function Animation.Cancel(instance)
    local tween=activeTweens[instance]
    if tween then pcall(function() tween:Cancel() end); activeTweens[instance]=nil end
end

function Animation.Hover(gui, normal, hovered, cleanup)
    local enter=gui.MouseEnter:Connect(function() Animation.Tween(gui, hovered) end)
    local leave=gui.MouseLeave:Connect(function() Animation.Tween(gui, normal) end)
    if cleanup then cleanup:Add(enter); cleanup:Add(leave) end
    return enter,leave
end

function Animation.Ripple(button, color, cleanup)
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
    local thread=task.delay(0.45, function() if ripple.Parent then ripple:Destroy() end end)
    if cleanup then cleanup:Add(thread) end
end

return Animation
