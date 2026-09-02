local Signal = require(script.Parent.Events)
local State = {}
State.__index = State

function State.new(initialValue)
    return setmetatable({ _value = initialValue, Changed = Signal.new(), _destroyed=false }, State)
end

function State:Get()
    return self._value
end

function State:Set(value)
    if self._destroyed then return end
    if self._value == value then return end
    local previous = self._value
    self._value = value
    self.Changed:Fire(value, previous)
end

function State:Update(reducer)
    if self._destroyed then return end
    self:Set(reducer(self._value))
end

function State:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    self.Changed:Destroy()
    self._value=nil
end

return State
