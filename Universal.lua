
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")

local player = players.LocalPlayer
local char = player.Character
local hum = char.Humanoid
local root = char.HumanoidRootPart
local cam = workspace.CurrentCamera

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Horizon Universal V0.1',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visual = Window:AddTab('Visual'),
    Players = Window:AddTab('Players'),
    Scripts = Window:AddTab('Scripts'),
    ['UI Settings'] = Window:AddTab('Settings'),
}

-- // PLAYERS
local Players = Tabs.Players:AddLeftGroupbox('Players')

Players:AddDropdown('PlayerDropdown', {
    SpecialType = 'Player',
    Text = 'Player selected:',

    Callback = function(plr)
        Player = game.Players[plr].Character
    end
})

Players:AddButton({
    Text = 'Teleport',
    Func = function()
        root.CFrame = Player.HumanoidRootPart.CFrame
    end,
    DoubleClick = false
})

Players:AddToggle('Spectate', {
    Text = 'Spectate',
    Default = false,

    Callback = function(val)
        if val then
            cam.CameraSubject = Player.Humanoid
        else
            cam.CameraSubject = char
        end
    end
})

-- // PLAYERS:SELF
local Self = Tabs.Players:AddLeftGroupbox('Self')
-- WALKSPEED
Self:AddSlider('Walkspeed', {
    Text = 'Walkspeed',
    Default = 16,
    Min = 0,
    Max = 512,
    Rounding = 1,
    Compact = false,

    Callback = function(val)
        hum.WalkSpeed = val
    end
})
-- JUMP POWER
Self:AddSlider('JumpPower', {
    Text = 'Jump Power',
    Default = 50,
    Min = 0,
    Max = 512,
    Rounding = 1,
    Compact = false,

    Callback = function(val)
        hum.JumpPower = val
    end
})
-- // END OF SELF
-- // END OF PLAYERS

-- // SCRIPTS
local Scripts = Tabs.Scripts:AddLeftGroupbox('Scripts')
Scripts:AddButton({
    Text = 'Infinite Yield',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
    DoubleClick = false
})
Scripts:AddButton({
    Text = 'Nameless Admin',
    Func = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source'))()
    end,
    DoubleClick = false
})
Scripts:AddButton({
    Text = 'Dex Explorer',
    Func = function()
        loadstring(game:HttpGet("https://github.com/LorekeeperZinnia/Dex/releases/download/1.0.0/out.lua"))()
    end,
    DoubleClick = false
})
Scripts:AddButton({
    Text = 'Remote Spy',
    Func = function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end,
    DoubleClick = false
})
-- // UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('Horizon')
SaveManager:SetFolder('Horizon/Universal')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
