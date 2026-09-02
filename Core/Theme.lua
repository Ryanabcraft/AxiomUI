local Signal = require(script.Parent.Events)
local Theme = {}
Theme.__index = Theme

function Theme.new(initialTheme)
    return setmetatable({ Current = initialTheme, Changed = Signal.new(), _bindings = {} }, Theme)
end

function Theme:Bind(instance, property, token, transform)
    local binding = { Instance = instance, Property = property, Token = token, Transform = transform }
    table.insert(self._bindings, binding)
    binding.Connection=instance.Destroying:Connect(function()
        for index,item in ipairs(self._bindings) do
            if item==binding then table.remove(self._bindings,index) break end
        end
        binding.Instance=nil
    end)
    local value = self.Current[token]
    if transform then value = transform(value, self.Current) end
    if value ~= nil then instance[property] = value end
    return binding
end

function Theme:Apply(nextTheme)
    self.Current = nextTheme
    for index = #self._bindings, 1, -1 do
        local binding = self._bindings[index]
        if not binding.Instance or not binding.Instance.Parent then
            if binding.Connection then binding.Connection:Disconnect() end
            table.remove(self._bindings, index)
        else
            local value = nextTheme[binding.Token]
            if binding.Transform then value = binding.Transform(value, nextTheme) end
            if value ~= nil then binding.Instance[binding.Property] = value end
        end
    end
    self.Changed:Fire(nextTheme)
end

function Theme:Destroy()
    for _,binding in ipairs(self._bindings) do
        if binding.Connection then binding.Connection:Disconnect() end
        binding.Instance=nil
    end
    table.clear(self._bindings)
    self.Changed:Destroy()
end

return Theme
