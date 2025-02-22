
local rs = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Player = Players.LocalPlayer
local chr = Player.Character
local hum = chr.Humanoid
local root = chr.HumanoidRootPart
local cam = workspace.CurrentCamera

local function Notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Horizon Universal",
        Text = text,
        Duration = 5
    })
end
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
-- // AIMBOT
local Aimbot = Tabs.Main:AddLeftGroupbox('Aimbot')
local mouse = Player:GetMouse()

local FOVRadius = 100
local LockTarget = "HumanoidRootPart"
local LockEnabled = false

local function getNearestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild(LockTarget) then
            local screenPoint, onScreen = cam:WorldToViewportPoint(player.Character[LockTarget].Position)
            if onScreen then
                local distance = (mousePos - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if distance < closestDistance and distance <= FOVRadius then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

Aimbot:AddSlider('FOVSlider', {
    Text = 'FOV',
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        FOVRadius = Value
    end
})

Aimbot:AddDropdown('LockTargetDropdown', {
    Values = { 'HumanoidRootPart', 'Head' },
    Default = 'HumanoidRootPart',
    Multi = false,
    Text = 'Target part',
    Tooltip = 'Choose which part to lock onto',

    Callback = function(Value)
        LockTarget = Value
    end
})

Aimbot:AddToggle('LockToggle', {
    Text = 'Enabled',
    Default = false,

    Callback = function(Value)
        LockEnabled = Value
    end
}):AddKeyPicker('LockOnKey', {
    Default = 'MB2',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Lock on Nearest Player',
    NoUI = false,

    Callback = function(isPressed)
        if LockEnabled then
            if isPressed then
                local targetPlayer = getNearestPlayer()
                if targetPlayer then
                    lock = rs.Heartbeat:Connect(function()
                        if targetPlayer.Character and targetPlayer.Character:FindFirstChild(LockTarget) then
                            cam.CFrame = CFrame.new(cam.CFrame.Position, targetPlayer.Character[LockTarget].Position)
                        else
                            lock:Disconnect()
                            lock = nil
                        end
                    end)
                end
            else
                if lock then
                    lock:Disconnect()
                    lock = nil
                end
            end
        end
    end,
})

-- // PLAYERS
local Players = Tabs.Players:AddLeftGroupbox('Players')

Players:AddDropdown('PlayerDropdown', {
    SpecialType = 'Player',
    Text = 'Player selected:',

    Callback = function(plr)
        Player = game.Players[plr]
    end
})
-- TELEPORT
Players:AddButton({
    Text = 'Teleport',
    Func = function()
        root.CFrame = Player.Character.HumanoidRootPart.CFrame
    end,
    DoubleClick = true
})

-- WACKY ASS FLING
function miniFling(playerToFling)
    local targetPlayers = {playerToFling}
    local isFlinging = false
    local flingPlayer = function(targetPlayer)
        local targetCharacter = targetPlayer.Character
        local targetHumanoid
        local targetRootPart
        local targetHead
        local targetAccessory
        local targetHandle

        if targetCharacter:FindFirstChildOfClass("Humanoid") then
            targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
        end
        if targetHumanoid and targetHumanoid.RootPart then
            targetRootPart = targetHumanoid.RootPart
        end
        if targetCharacter:FindFirstChild("Head") then
            targetHead = targetCharacter.Head
        end
        if targetCharacter:FindFirstChildOfClass("Accessory") then
            targetAccessory = targetCharacter:FindFirstChildOfClass("Accessory")
        end
        if targetAccessory and targetAccessory:FindFirstChild("Handle") then
            targetHandle = targetAccessory.Handle
        end
        if chr and hum and root then
            if root.Velocity.Magnitude < 50 then
                getgenv().OldPos = root.CFrame
            end
            if targetHumanoid and targetHumanoid.Sit and not isFlinging then
            end
            if targetHead then
                if targetHead.Velocity.Magnitude > 500 then
                    fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
                    if fu.waitfordialog() == "No" then
                        return fu.closedialog()
                    end
                    fu.closedialog()
                end
            elseif not targetHead and targetHandle then
                if targetHandle.Velocity.Magnitude > 500 then
                    fu.dialog("Player flung", "Player is already flung. Fling again?", {"Fling again", "No"})
                    if fu.waitfordialog() == "No" then
                        return fu.closedialog()
                    end
                    fu.closedialog()
                end
            end
            if targetHead then
                cam.CameraSubject = targetHead
            elseif not targetHead and targetHandle then
                cam.CameraSubject = targetHandle
            elseif targetHumanoid and targetRootPart then
                cam.CameraSubject = targetHumanoid
            end
            if not targetCharacter:FindFirstChildWhichIsA("BasePart") then
                return
            end
            local fling = function(part, offset, rotation)
                root.CFrame = CFrame.new(part.Position) * offset * rotation
                chr:SetPrimaryPartCFrame(CFrame.new(part.Position) * offset * rotation)
                root.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            local performFling = function(part)
                local duration = 2
                local startTime = tick()
                local angle = 0
                repeat
                    if root and targetHumanoid then
                        if part.Velocity.Magnitude < 50 then
                            angle = angle + 100
                            fling(
                                part,
                                CFrame.new(0, 1.5, 0) + targetHumanoid.MoveDirection * part.Velocity.Magnitude / 1.25,
                                CFrame.Angles(math.rad(angle), 0, 0)
                            )
                            task.wait()
                            fling(
                                part,
                                CFrame.new(0, -1.5, 0) + targetHumanoid.MoveDirection * part.Velocity.Magnitude / 1.25,
                                CFrame.Angles(math.rad(angle), 0, 0)
                            )
                            task.wait()
                            fling(
                                part,
                                CFrame.new(2.25, 1.5, -2.25) + targetHumanoid.MoveDirection * part.Velocity.Magnitude / 1.25,
                                CFrame.Angles(math.rad(angle), 0, 0)
                            )
                            task.wait()
                            fling(
                                part,
                                CFrame.new(-2.25, -1.5, 2.25) + targetHumanoid.MoveDirection * part.Velocity.Magnitude / 1.25,
                                CFrame.Angles(math.rad(angle), 0, 0)
                            )
                            task.wait()
                            fling(part, CFrame.new(0, 1.5, 0) + targetHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, 0) + targetHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                            task.wait()
                        else
                            fling(part, CFrame.new(0, 1.5, targetHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, -targetHumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, 1.5, targetHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, 1.5, targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, -targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, 1.5, targetRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                            task.wait()
                            fling(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    else
                        break
                    end
                until part.Velocity.Magnitude > 500 or part.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= players or targetPlayer.Character ~= targetCharacter or
                    targetHumanoid.Sit or
                    hum.Health <= 0 or
                    tick() > startTime + duration
            end
            workspace.FallenPartsDestroyHeight = 0 / 0
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "vel"
            bodyVelocity.Parent = root
            bodyVelocity.Velocity = Vector3.new(9e8, 9e8, 9e8)
            bodyVelocity.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            if targetRootPart and targetHead then
                if (targetRootPart.CFrame.p - targetHead.CFrame.p).Magnitude > 5 then
                    performFling(targetHead)
                else
                    performFling(targetRootPart)
                end
            elseif targetRootPart and not targetHead then
                performFling(targetRootPart)
            elseif not targetRootPart and targetHead then
                performFling(targetHead)
            elseif not targetRootPart and not targetHead and targetAccessory and targetHandle then
                performFling(targetHandle)
            else
                fu.notification("Can't find a proper part of target player to fling.")
            end
            bodyVelocity:Destroy()
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            cam.CameraSubject = hum
            repeat
                root.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                chr:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                hum:ChangeState("GettingUp")
                table.foreach(
                    chr:GetChildren(),
                    function(index, part)
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                )
                task.wait()
            until (root.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        else
            fu.notification("No valid character of said target player. May have died.")
        end
        for _, c in pairs(chr:GetDescendants()) do
            if c:IsA("BasePart") and c.CanCollide == false then
                fu.notification("Player has anti-fling!")
            end
        end
    end
    flingPlayer(targetPlayers[1])
end

Players:AddButton({
    Text = 'Fling',
    Func = function()
        miniFling(Player)
    end,
    DoubleClick = true
})
-- SPECTATE
Players:AddToggle('Spectate', {
    Text = 'Spectate',
    Default = false,

    Callback = function(val)
        if val then
            cam.CameraSubject = Player.Character.Humanoid
        else
            cam.CameraSubject = hum
        end
    end
})

-- // PLAYERS:SELF
local Self = Tabs.Players:AddLeftGroupbox('Self')
-- WALKSPEED
Self:AddSlider('Walkspeed', {
    Text = 'Walkspeed',
    Default = 16,
    Min = 16,
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
    Min = 50,
    Max = 512,
    Rounding = 1,
    Compact = false,

    Callback = function(val)
        hum.JumpPower = val
    end
})
-- ANTI FLING
Self:AddToggle('antifling', {
    Text = 'Anti Fling',
    Default = false,

    Callback = function(val)
        if not val then
            antifling:Disconnect()
            antifling = nil
        else
    antifling = rs.Stepped:Connect(function()
        for _, Player in pairs(players:GetPlayers()) do
            if Player ~= player and Player.Character then
                for _, v in pairs(Player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
        end
    end
})

-- NOCLIP
Self:AddToggle('noclip', {
    Text = 'Noclip',
    Default = false,

    Callback = function(val)
        if not val then
            noclip:Disconnect()
            clip = true
        else
            clip = false
            noclip = rs.Stepped:Connect(function()
                if not clip and chr then
                    for _, c in pairs(chr:GetDescendants()) do
                        if c:IsA("BasePart") and c.CanCollide then
                            c.CanCollide = false
                        end
                    end
                end
            end)
        end
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
