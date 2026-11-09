-- Full code with KillAura function and optimized remote event handling

local player = game.Players.LocalPlayer -- Get Local Player Object

-- Function to kill enemies within a specified radius (KillAura)
local function KillAura(player)
    local players = game.Players:GetPlayers() -- Get all players currently online

    for _, plyr in pairs(players) do
        if plyr ~= player then -- Exclude the current player
            local character = plyr.Character or plyr.PrimaryPart or plyr
            local pos = character.Position

            local dist = Vector3.new(pos.x, pos.y, pos.z):Distance(Vector3.new(player.Character.PrimaryPart.Position.x, player.Character.PrimaryPart.Position.y, player.Character.PrimaryPart.Position.z))

            if dist <= 100 then -- Adjust the radius as needed
                game:GetService("ReplicatedStorage").RemoteEvent:FireServer(plyr)
            end
        end
    end
end

-- Perform KillAura every 5 seconds
timer.performWithDelay(5, function()
    KillAura(player)
end)

-- Function to handle remote events rapidly without causing client lag (HandleRemoteEvents)
local function HandleRemoteEvents()
    local players = game.Players:GetPlayers() -- Get all players currently online

    while true do
        coroutine.wrap(function()
            for _, plyr in pairs(players) do
                if plyr ~= player then
                    local character = plyr.Character or plyr.PrimaryPart or plyr
                    local pos = character.Position

                    local dist = Vector3.new(pos.x, pos.y, pos.z):Distance(Vector3.new(player.Character.PrimaryPart.Position.x, player.Character.PrimaryPart.Position.y, player.Character.PrimaryPart.Position.z))

                    if dist <= 100 then
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(plyr)
                    end
                end
            end
        end):yield()
    end
end

-- Start the coroutine in a thread to avoid blocking other tasks
HandleRemoteEvents()

-- UI toggles for KillAura and HandleRemoteEvents (ToggleKillAura, ToggleHandleRemoteEvents)
local function ToggleKillAura(enabled)
    if enabled then -- Enable functionality
        timer.performWithDelay(5, function()
            KillAura(player)
        end)
    else -- Disable functionality
        timer.clearAllTimers("killAura")
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, handled)
    if input.KeyCode == Enum.KeyCode.S then -- Press 'S' on your keyboard to toggle
        ToggleKillAura(not timer.isClear("killAura"))
    end
end)

local function ToggleHandleRemoteEvents(enabled)
    if enabled then -- Enable coroutine handling
        HandleRemoteEvents()
    else -- Disable coroutine handling
        game:GetService("RunService").Heartbeat:Disconnect(HandleRemoteEvents)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, handled)
    if input.KeyCode == Enum.KeyCode.R then -- Press 'R' on your keyboard to toggle
        ToggleHandleRemoteEvents(not timer.isClear("remoteEventsHandling"))
    end
end)

-- Setup UI toggles (ToggleKillAuraButton and ToggleHandleRemoteEventsButton)
local function SetupUI()
    local window = game.Workspace:WaitForChild("Window")
    if not window then
        window = Instance.new("ScreenGui")
        window.Name = "Window"
        window.Parent = game.Workspace

        -- Add UI elements like ToggleKillAura and ToggleHandleRemoteEvents here
    end

    local toggleKillAuraButton = window:WaitForChild("ToggleKillAuraButton")
    if not toggleKillAuraButton then
        toggleKillAuraButton = Instance.new("TextButton")
        toggleKillAuraButton.Parent = window
        toggleKillAuraButton.Name = "ToggleKillAuraButton"
        toggleKillAuraButton.Text = "Enable KillAura Functionality"
        toggleKillAuraButton.MouseButton1Click:Connect(function()
            ToggleKillAura(not timer.isClear("killAura"))
        end)
    end

    local toggleRemoteEventsHandlingButton = window:WaitForChild("ToggleRemoteEventsHandlingButton")
    if not toggleRemoteEventsHandlingButton then
        toggleRemoteEventsHandlingButton = Instance.new("TextButton")
        toggleRemoteEventsHandlingButton.Parent = window
        toggleRemoteEventsHandlingButton.Name = "ToggleRemoteEventsHandlingButton"
        toggleRemoteEventsHandlingButton.Text = "Enable Remote Event Handling"
        toggleRemoteEventsHandlingButton.MouseButton1Click:Connect(function()
            ToggleHandleRemoteEvents(not timer.isClear("remoteEventsHandling"))
        end)
    end

end
SetupUI()

-- Call the setup function when the script is loaded
SetupUI()
