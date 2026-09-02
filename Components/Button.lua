local Animation = require(script.Parent.Parent.Services.Animation)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
    local theme = context.Theme.Current
    local button = Utility.Create("TextButton", {
        Name = options.Name or "Button", Size = UDim2.new(1, 0, 0, 44), AutoButtonColor = false,
        BackgroundColor3 = theme.SurfaceAlt, BackgroundTransparency = theme.Transparency,
        BorderSizePixel = 0, Text = options.Name or "Button", TextColor3 = theme.Text,
        TextSize = 13, Font = Enum.Font.GothamMedium, ClipsDescendants = true, Parent = parent,
    })
    Utility.Corner(button, theme.Radius)
    local stroke = Utility.Stroke(button, theme.Stroke, 0.62)
    context.Theme:Bind(button, "BackgroundColor3", "SurfaceAlt")
    context.Theme:Bind(button, "TextColor3", "Text")
    context.Theme:Bind(stroke, "Color", "Stroke")
    cleanup:Add(button.MouseEnter:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceHover }) end))
    cleanup:Add(button.MouseLeave:Connect(function() Animation.Tween(button, { BackgroundColor3 = context.Theme.Current.SurfaceAlt }) end))
    cleanup:Add(button.Activated:Connect(function()
        if not cleanup:IsAlive() then return end
        Animation.Ripple(button,theme.Primary,cleanup)
        Utility.SafeCallback(options.Callback)
    end))
    cleanup:Add(function() Animation.Cancel(button) end)
    return Base.Handle(button,nil,cleanup)
end
