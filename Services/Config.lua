local HttpService=game:GetService("HttpService")
local Config={}; Config.__index=Config

function Config.new(namespace)
    return setmetatable({Namespace=namespace or "Axiom",Values={},Profiles={},AutoSave=false,AutoSaveProfile="default",_connections={},_destroyed=false},Config)
end

function Config:Register(key,control)
    if self._destroyed then return control end
    if self._connections[key] then self._connections[key]:Disconnect() end
    self.Values[key]=control
    if control.Changed then
        self._connections[key]=control.Changed:Connect(function()
            if self.AutoSave then
                local revision=tick(); self._pendingRevision=revision
                task.delay(0.35,function() if not self._destroyed and self._pendingRevision==revision then self:Save(self.AutoSaveProfile) end end)
            end
        end)
    end
    if control._OnDestroy then
        control:_OnDestroy(function()
            if self.Values[key]==control then
                self.Values[key]=nil
                if self._connections[key] then self._connections[key]:Disconnect(); self._connections[key]=nil end
            end
        end)
    end
    return control
end

function Config:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    self.AutoSave=false
    self._pendingRevision=nil
    for key,connection in pairs(self._connections) do connection:Disconnect(); self._connections[key]=nil end
    table.clear(self.Values)
    table.clear(self.Profiles)
end

function Config:EnableAutoSave(enabled,profile)
    self.AutoSave=enabled~=false
    self.AutoSaveProfile=profile or self.AutoSaveProfile
end

function Config:Serialize()
    local output={}
    for key,control in pairs(self.Values) do
        local value=control:Get()
        if typeof(value)=="Color3" then value={__type="Color3",r=value.R,g=value.G,b=value.B}
        elseif typeof(value)=="EnumItem" then value={__type="EnumItem",enum=tostring(value.EnumType),name=value.Name} end
        output[key]=value
    end
    return output
end

function Config:LoadTable(data)
    for key,value in pairs(data or {}) do
        local control=self.Values[key]
        if control then
            if type(value)=="table" and value.__type=="Color3" then value=Color3.new(value.r,value.g,value.b)
            elseif type(value)=="table" and value.__type=="EnumItem" and value.enum=="Enum.KeyCode" then value=Enum.KeyCode[value.name] end
            control:Set(value)
        end
    end
end

function Config:Save(profile)
    if self._destroyed then return nil end
    profile=profile or "default"; local data=self:Serialize(); self.Profiles[profile]=data
    if writefile then
        if makefolder then pcall(makefolder,self.Namespace) end
        writefile(self.Namespace.."/"..profile..".json",HttpService:JSONEncode(data))
    end
    return data
end

function Config:Load(profile)
    if self._destroyed then return false end
    profile=profile or "default"; local data=self.Profiles[profile]
    if not data and readfile and isfile and isfile(self.Namespace.."/"..profile..".json") then
        local ok,result=pcall(function() return HttpService:JSONDecode(readfile(self.Namespace.."/"..profile..".json")) end)
        if ok then data=result end
    end
    self:LoadTable(data or {}); return data~=nil
end

return Config
