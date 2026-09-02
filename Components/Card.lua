local Utility=require(script.Parent.Parent.Services.Utility)

return function(context,parent,options)
    options=options or {}; local theme=context.Theme.Current
    local card=Utility.Create("Frame",{Name=options.Name or "Card",Size=options.Size or UDim2.new(1,0,0,100),BackgroundColor3=theme.SurfaceAlt,BackgroundTransparency=theme.Transparency,BorderSizePixel=0,Parent=parent})
    Utility.Corner(card,theme.Radius); Utility.Stroke(card,theme.Stroke,0.62); Utility.Padding(card,16)
    if options.Name then Utility.Create("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=options.Name,TextColor3=theme.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=card}) end
    return card
end
