
local rs = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local light = game:GetService("Lighting")
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

local TeamCheckEnabled = false

Aimbot:AddToggle('TeamCheckToggle', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Toggle to enable or disable team check',

    Callback = function(Value)
        TeamCheckEnabled = Value
    end
})

local function isOnSameTeam(player1, player2)
    return player1.Team == player2.Team
end

local function getNearestPlayerToMouse()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild(LockTarget) then
            if not TeamCheckEnabled or (TeamCheckEnabled and not isOnSameTeam(Player, player)) then
                local targetPart = player.Character[LockTarget]
                local screenPoint, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (mousePos - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if distance < closestDistance and distance <= FOVRadius then
                        closestDistance = distance
                        closestPlayer = player
                    end
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
    Tooltip = 'Toggle to enable or disable lock-on feature',

    Callback = function(Value)
        LockEnabled = Value
    end
}):AddKeyPicker('LockOnKey', {
    Default = 'V',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Lock on Nearest Player',
    NoUI = false,

    Callback = function(isPressed)
        if LockEnabled then
            if isPressed then
                local targetPlayer = getNearestPlayerToMouse()
                if targetPlayer then
                    lock = rs.Heartbeat:Connect(function()
                        if targetPlayer.Character and targetPlayer.Character:FindFirstChild(LockTarget) then
                            cam.CFrame = CFrame.new(cam.CFrame.Position, targetPlayer.Character[LockTarget].Position)
                            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then
                                lock:Disconnect()
                                lock = nil
                            end
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


-- // VISUAL

local esp = Tabs.Visual:AddLeftGroupbox('ESP')

local wtvp = cam.WorldToViewportPoint

local headoff = Vector3.new(0, 0.5, 0)
local legoff = Vector3.new(0, 3, 0)

local ESPEnabled = false
local BoxEnabled = false
local BoxOutlineEnabled = false
local HealthBarEnabled = false
local HealthBarOutlineEnabled = false

local BoxColor = Color3.fromRGB(255, 255, 255)
local BoxOutlineColor = Color3.fromRGB(0, 0, 0)
local HealthBarColor = Color3.fromRGB(0, 255, 0)
local HealthBarOutlineColor = Color3.fromRGB(0, 0, 0)

local function createESP(v)
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = BoxOutlineColor
    BoxOutline.Thickness = 2
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = BoxColor
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local healthBarOutline = Drawing.new("Line")
    healthBarOutline.Visible = false
    healthBarOutline.Color = HealthBarOutlineColor
    healthBarOutline.Thickness = 4
    healthBarOutline.Transparency = 1

    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = HealthBarColor
    healthBar.Thickness = 2
    healthBar.Transparency = 1

    game:GetService("RunService").RenderStepped:Connect(function()
        if ESPEnabled and v.Character and v.Character:FindFirstChild("Humanoid") and v ~= Player and v.Character.Humanoid.Health > 0 then
            local vector, onscreen = cam:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)

            local root = v.Character.HumanoidRootPart
            local head = v.Character.Head
            local RootPos = wtvp(cam, root.Position)
            local HeadPos = wtvp(cam, head.Position + headoff)
            local LegPos = wtvp(cam, root.Position - legoff)

            if onscreen then
                if BoxOutlineEnabled then
                    BoxOutline.Size = Vector2.new(1000 / RootPos.Z, HeadPos.Y - LegPos.Y)
                    BoxOutline.Position = Vector2.new(RootPos.X - BoxOutline.Size.X / 2, RootPos.Y - BoxOutline.Size.Y / 2)
                    BoxOutline.Color = BoxOutlineColor
                    BoxOutline.Visible = true
                else
                    BoxOutline.Visible = false
                end

                if BoxEnabled then
                    box.Size = Vector2.new(1000 / RootPos.Z, HeadPos.Y - LegPos.Y)
                    box.Position = Vector2.new(RootPos.X - box.Size.X / 2, RootPos.Y - box.Size.Y / 2)
                    box.Color = BoxColor
                    box.Visible = true
                else
                    box.Visible = false
                end

                if HealthBarOutlineEnabled then
                    local health = v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth
                    healthBarOutline.From = Vector2.new(RootPos.X - BoxOutline.Size.X / 2 - 5, RootPos.Y - BoxOutline.Size.Y / 2 + 1)
                    healthBarOutline.To = Vector2.new(RootPos.X - BoxOutline.Size.X / 2 - 5, RootPos.Y - BoxOutline.Size.Y / 2 + (HeadPos.Y - LegPos.Y) + 1)
                    healthBarOutline.Color = HealthBarOutlineColor
                    healthBarOutline.Visible = true
                else
                    healthBarOutline.Visible = false
                end

                if HealthBarEnabled then
                    local health = v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth
                    healthBar.From = Vector2.new(RootPos.X - BoxOutline.Size.X / 2 - 5, RootPos.Y - BoxOutline.Size.Y / 2)
                    healthBar.To = Vector2.new(RootPos.X - BoxOutline.Size.X / 2 - 5, RootPos.Y - BoxOutline.Size.Y / 2 + (HeadPos.Y - LegPos.Y) * health)
                    healthBar.Color = HealthBarColor
                    healthBar.Visible = true
                else
                    healthBar.Visible = false
                end
            else
                BoxOutline.Visible = false
                box.Visible = false
                healthBar.Visible = false
                healthBarOutline.Visible = false
            end
        else
            BoxOutline.Visible = false
            box.Visible = false
            healthBar.Visible = false
            healthBarOutline.Visible = false
        end
    end)
end

for i, v in pairs(game.Players:GetChildren()) do
    createESP(v)
end

game.Players.PlayerAdded:Connect(function(v)
    createESP(v)
end)

esp:AddToggle('ESP', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'Toggle to enable or disable ESP',
    Callback = function(val)
        ESPEnabled = val
    end
})

esp:AddToggle('Box', {
    Text = 'Enable Box',
    Default = false,
    Tooltip = 'Toggle to enable or disable Box',
    Callback = function(val)
        BoxEnabled = val
    end
}):AddColorPicker('BoxColorPicker', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Box color',
    Transparency = 1,

    Callback = function(Value)
        BoxColor = Value
    end
})

esp:AddToggle('BoxOutline', {
    Text = 'Enable Box Outline',
    Default = false,
    Tooltip = 'Toggle to enable or disable Box Outline',
    Callback = function(val)
        BoxOutlineEnabled = val
    end
}):AddColorPicker('BoxOutlineColorPicker', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = 'Box Outline color',
    Transparency = 1,

    Callback = function(Value)
        BoxOutlineColor = Value
    end
})

esp:AddToggle('HealthBar', {
    Text = 'Enable Health Bar',
    Default = false,
    Tooltip = 'Toggle to enable or disable Health Bar',
    Callback = function(val)
        HealthBarEnabled = val
    end
}):AddColorPicker('HealthBarColorPicker', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = 'Health Bar color',
    Transparency = 1,

    Callback = function(Value)
        HealthBarColor = Value
    end
})

esp:AddToggle('HealthBarOutline', {
    Text = 'Enable Health Bar Outline',
    Default = false,
    Tooltip = 'Toggle to enable or disable Health Bar Outline',
    Callback = function(val)
        HealthBarOutlineEnabled = val
    end
}):AddColorPicker('HealthBarOutlineColorPicker', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = 'Health Bar Outline color',
    Transparency = 1,

    Callback = function(Value)
        HealthBarOutlineColor = Value
    end
})

-- // ENVIRONMENT
local Env = Tabs.Visual:AddLeftGroupbox('Environment')

Env:AddSlider('TimeOfDay', {
    Text = 'Time Of Day',
    Default = light.ClockTime,
    Min = 0,
    Max = 24,
    Rounding = 0,
    Compact = false,

    Callback = function(val)
        light.ClockTime = val
    end
})

Env:AddSlider('FogStart', {
    Text = 'Fog Start',
    Default = light.FogStart,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Compact = false,

    Callback = function(val)
        light.FogStart = val
    end
})
Env:AddSlider('FogEnd', {
    Text = 'Fog End',
    Default = light.FogEnd,
    Min = 0,
    Max = 512,
    Rounding = 0,
    Compact = false,

    Callback = function(val)
        light.FogEnd = val
    end
})
Env:AddLabel('Fog Color'):AddColorPicker('FogColor', {
    Default = light.FogColor,
    Title = 'Fog Color',
    Transparency = 1,

    Callback = function(val)
        light.FogColor = val
    end
})
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
