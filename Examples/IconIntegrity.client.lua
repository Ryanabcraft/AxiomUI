local Icons=require(script.Parent.Parent.Services.Icons)

local names=Icons.List()
local seenAssets={}

assert(#names>=100,"Axiom must provide at least 100 official icons")
for index,name in ipairs(names) do
    local asset=Icons.Get(name)
    assert(type(name)=="string" and name~="","Invalid icon name")
    assert(type(asset)=="string" and asset:match("^rbxassetid://%d+$"),"Invalid asset for "..name)
    assert(not seenAssets[asset],string.format("Duplicate asset: %s and %s",seenAssets[asset] or "",name))
    assert(index==1 or names[index-1]<name,"Icons.List() must be sorted")
    seenAssets[asset]=name
end

assert(Icons.Exists("MapPin"))
assert(Icons.Exists("map_pin"))
assert(Icons.Exists("MAP PIN"))
assert(not Icons.Exists("not-a-real-icon"))
assert(Icons.Get("not-a-real-icon")==Icons.Get("info"))
assert(Icons.Get(123)=="rbxassetid://123")
assert(Icons.Get("rbxassetid://123")=="rbxassetid://123")

print(string.format("Axiom icon integrity passed: %d official icons",#names))
