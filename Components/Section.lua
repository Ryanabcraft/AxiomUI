local Utility=require(script.Parent.Parent.Services.Utility)

return function(context,parent,options)
    options=options or {}; local theme=context.Theme.Current
    local section=Utility.Create("Frame",{Name=options.Name or "Section",Size=UDim2.new(1,0,0,32),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=parent})
    Utility.Create("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=string.upper(options.Name or "SECTION"),TextColor3=theme.TextMuted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=section})
    local content=Utility.Create("Frame",{Position=UDim2.fromOffset(0,30),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=section})
    Utility.Create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=content})
    return content
end
