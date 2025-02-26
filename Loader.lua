local repo = "https://raw.githubusercontent.com/NilInstances/Horizon/refs/heads/main"
local function l(o) loadstring(game:HttpGet(o))() end

if game.PlaceId = "10449761463" then
l(repo.."TSB.lua")
else
l(repo.."Universal.lua")
end
