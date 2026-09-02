local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {}, _destroyed = false }, Signal)
end

function Signal:Connect(callback)
    assert(type(callback) == "function", "Signal callback must be a function")
    assert(not self._destroyed, "Cannot connect to a destroyed Signal")
    local connection = { Connected = true }
    self._listeners[connection] = callback
    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        connection._owner._listeners[self] = nil
    end
    connection._owner = self
    return connection
end

function Signal:Fire(...)
    if self._destroyed then return end
    for connection, callback in pairs(self._listeners) do
        if connection.Connected then
            task.spawn(callback, ...)
        end
    end
end

function Signal:Destroy()
    self._destroyed = true
    for connection in pairs(self._listeners) do connection.Connected = false end
    table.clear(self._listeners)
end

return Signal
