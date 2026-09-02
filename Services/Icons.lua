local Icons = {
    home = "rbxassetid://10723407389",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10747373176",
    eye = "rbxassetid://10723346959",
    search = "rbxassetid://10734943674",
    sliders = "rbxassetid://10734951847",
    palette = "rbxassetid://10734973486",
    code = "rbxassetid://10709810463",
    info = "rbxassetid://10723415903",
    bell = "rbxassetid://10709775704",
    check = "rbxassetid://10709790644",
    close = "rbxassetid://10747384394",
}

local aliases = {
    default = "info",
    visual = "eye",
    movement = "sliders",
    config = "settings",
    configuration = "settings",
    profile = "user",
}

local function isValidContentId(value)
    return value:match("^rbxassetid://%d+$")
        or value:match("^rbxasset://.+")
        or value:match("^https?://.+")
end

function Icons.Get(name)
    if type(name) == "number" and name > 0 then
        return "rbxassetid://" .. math.floor(name)
    end
    if type(name) == "string" then
        local key = string.lower(name)
        key = aliases[key] or key
        if Icons[key] then return Icons[key] end
        if isValidContentId(name) then return name end
    end
    return Icons[aliases.default]
end

return Icons
