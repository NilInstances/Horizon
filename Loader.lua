local repo = "https://raw.githubusercontent.com/NilInstances/Horizon/refs/heads/main"
local function l(o) loadstring(game:HttpGet(o))() end

if identifyexecutor then
if table.find({'JJSploit'}, ({identifyexecutor()})[1]) then
warn("Fuck you im not loading your script")
elseif table.find({'Velocity'}, ({identifyexecutor()})[1]) then -- you're welcome
local JsonWrite
JsonWrite = hookfunction(writefile, function(Event,...)

    if (Event):match("%.json$") ~= nil then
        warn((Event):gsub("%.json$", ".txt"),...)
        return JsonWrite((Event):gsub("%.json$", ".txt"),...)
    else
        warn(Event,...)
        return JsonWrite(Event,...)
    end

end)

local JasonRead
JasonRead = hookfunction(readfile, function(Event,...)

    if (Event):match("%.json$") ~= nil then
        warn((Event):gsub("%.json$", ".txt"),...)
        return JasonRead((Event):gsub("%.json$", ".txt"),...)
    else
        warn(Event,...)
        return JasonRead(Event,...)
    end

end)
  elseif table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
  end
end

if game.PlaceId = "10449761463" then
l(repo.."TSB.lua")
else
l(repo.."Universal.lua")
end
