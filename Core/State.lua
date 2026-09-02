local Signal = require(script.Parent.Events)
local State = {}
State.__index = State

function State.new(initialValue)
    return setmetatable({ _value = initialValue, Changed = Signal.new() }, State)
end

function State:Get()
    return self._value
end

function State:Set(value)
    if self._value == value then return end
    local previous = self._value
    self._value = value
    self.Changed:Fire(value, previous)
end

function State:Update(reducer)
    self:Set(reducer(self._value))
end

function State:Destroy()
    self.Changed:Destroy()
end

return State
