local Icons = {
    home = "rbxassetid://10723407389",
    settings = "rbxassetid://10734950309",
    sliders = "rbxassetid://10734951847",
    palette = "rbxassetid://10734973486",
    code = "rbxassetid://10709810463",
    info = "rbxassetid://10723415903",
    bell = "rbxassetid://10709775704",
    check = "rbxassetid://10709790644",
    close = "rbxassetid://10747384394",
}

function Icons.Get(name)
    return Icons[name] or name or ""
end

return Icons
