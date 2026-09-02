local Dark = require(script.Parent.Dark)

return function(overrides)
    local theme = table.clone(Dark)
    theme.Name = "Axiom Custom"
    for key, value in pairs(overrides or {}) do
        theme[key] = value
    end
    return theme
end
