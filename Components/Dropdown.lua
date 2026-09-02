local State = require(script.Parent.Parent.Core.State)
local Animation = require(script.Parent.Parent.Services.Animation)
local Utility = require(script.Parent.Parent.Services.Utility)
local Base = require(script.Parent.Base)

return function(context, parent, options)
    options = options or {}
    local cleanup=Base.Cleanup()
    local values = options.Options or {}
    local multi = options.Multi == true
    local initial = options.Default or (multi and {} or values[1])
    local state = State.new(initial)
    local row,label = Base.Row(context,parent,options,54)
    row.ClipsDescendants = true
    label.Position = UDim2.fromOffset(16,0)
    label.Size = UDim2.new(0.62,-16,0,54)
    label.TextYAlignment = Enum.TextYAlignment.Center
    local selector = Utility.Create("TextButton", {
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,10), Size=UDim2.new(0.46,0,0,34),
        BackgroundColor3=context.Theme.Current.Background, BackgroundTransparency=0.2, BorderSizePixel=0,
        AutoButtonColor=false, Font=Enum.Font.Gotham, TextColor3=context.Theme.Current.TextMuted,
        TextSize=12, TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    Utility.Corner(selector,UDim.new(0,8)); Utility.Stroke(selector,context.Theme.Current.Stroke,0.55)
    local list = Utility.Create("Frame", { Position=UDim2.new(0,12,0,54), Size=UDim2.new(1,-24,0,0), BackgroundTransparency=1, Parent=row })
    local layout=Utility.Create("UIListLayout",{Padding=UDim.new(0,4),Parent=list})
    local open=false
    local function display(value)
        if multi then
            local selected={}; for key,enabled in pairs(value) do if enabled then table.insert(selected,key) end end
            table.sort(selected); selector.Text=#selected>0 and table.concat(selected,", ") or "Select..."
        else selector.Text=tostring(value or "Select...") end
    end
    local function setOpen(value)
        open=value; local target=value and (#values*32+(#values-1)*4+66) or 54
        Animation.Tween(row,{Size=UDim2.new(1,0,0,target)})
        Animation.Tween(list,{Size=UDim2.new(1,-24,0,value and target-62 or 0)})
    end
    for _,value in ipairs(values) do
        local item=Utility.Create("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=context.Theme.Current.SurfaceHover,BackgroundTransparency=0.18,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.Gotham,Text=tostring(value),TextColor3=context.Theme.Current.Text,TextSize=12,Parent=list})
        Utility.Corner(item,UDim.new(0,7))
        cleanup:Add(item.Activated:Connect(function()
            if not cleanup:IsAlive() then return end
            if multi then local nextValue=table.clone(state:Get()); nextValue[value]=not nextValue[value]; state:Set(nextValue) else state:Set(value); setOpen(false) end
        end))
    end
    cleanup:Add(selector.Activated:Connect(function() if cleanup:IsAlive() then setOpen(not open) end end))
    cleanup:Add(state.Changed:Connect(function(value) if cleanup:IsAlive() then display(value); Utility.SafeCallback(options.Callback,value) end end))
    cleanup:Add(function() open=false; Animation.Cancel(row); Animation.Cancel(list) end)
    display(state:Get())
    return Base.Handle(row,state,cleanup)
end
