local Cleanup={}
Cleanup.__index=Cleanup

function Cleanup.new()
    return setmetatable({_tasks={},_destroyed=false},Cleanup)
end

function Cleanup:Add(item)
    if item==nil then return nil end
    if self._destroyed then
        self:_Clean(item)
        return item
    end
    table.insert(self._tasks,item)
    return item
end

function Cleanup:_Clean(item)
    local kind=typeof(item)
    if kind=="RBXScriptConnection" then
        if item.Connected then item:Disconnect() end
    elseif kind=="Instance" then
        if item:IsA("TweenBase") then item:Cancel() end
        item:Destroy()
    elseif kind=="function" then
        item()
    elseif kind=="thread" then
        pcall(task.cancel,item)
    elseif type(item)=="table" then
        if item.Disconnect then item:Disconnect()
        elseif item.Cancel then item:Cancel()
        elseif item.Destroy then item:Destroy() end
    end
end

function Cleanup:IsAlive()
    return not self._destroyed
end

function Cleanup:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    for i=#self._tasks,1,-1 do
        pcall(function() self:_Clean(self._tasks[i]) end)
        self._tasks[i]=nil
    end
end

return Cleanup
