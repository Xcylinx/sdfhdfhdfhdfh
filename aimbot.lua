local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

local FOV = 50
local MaxDistance = 200
local AimKey = Enum.KeyCode.E
local StopKey = Enum.KeyCode.Q
local TeamCheck = false
local WallCheck = false

local target = nil
local aimbotActive = false
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = FOV
fovCircle.Color = Color3.new(1, 1, 1) -- Default color
fovCircle.Thickness = 2
fovCircle.Filled = false

-- Track input position (mouse or touch)
local inputPosition = Vector2.new(0, 0)

-- Function to update input position
local function updateInputPosition()
    if UserInputService.MouseEnabled then
        -- Desktop: Use mouse position
        local pos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        inputPosition = pos - Vector2.new(0, FOV)
        fovCircle.Position = pos
    elseif UserInputService.TouchEnabled then
        -- Mobile: Set FOV circle to the center of the screen
        local screenCenter = Camera.ViewportSize / 2
        fovCircle.Position = screenCenter
        inputPosition = screenCenter - Vector2.new(0, FOV)
    end
end

local function worldToScreen(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function isWithinFOV(position)
    local screenPos, onScreen = worldToScreen(position)
    if not onScreen then return false end
    return (screenPos - inputPosition).Magnitude <= FOV
end

local function isWithinDistance(object)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return root and (object.Position - root.Position).Magnitude <= MaxDistance
end

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * 100)
    local hit, _ = workspace:FindPartOnRay(ray, player.Character)
    return hit == part
end

local function findTarget()
    local closest = nil
    local closestDistance = FOV

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            if TeamCheck and otherPlayer.Team == player.Team then
                continue
            end

            local head = otherPlayer.Character.Head
            if isWithinFOV(head.Position) and isWithinDistance(head) and (not WallCheck or isVisible(head)) then
                local screenPos = worldToScreen(head.Position)
                local distance = (inputPosition - screenPos).Magnitude
                if distance < closestDistance then
                    closest = head
                    closestDistance = distance
                end
            end
        end
    end

    return closest
end

local function aimlock()
    if target and target.Parent then
        local targetPosition = target.Position
        local cameraPosition = Camera.CFrame.Position
        local direction = (targetPosition - cameraPosition).Unit
        Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + direction)
    else
        target = nil
    end
end

local function stopAimbot()
    aimbotActive = false
    target = nil
end

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.ResetOnSpawn = false

local connection1
local connection2
local connection3
local connection4

local function stopScript()
    stopAimbot()

    connection1:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()

    fovCircle:Remove()
    screenGui:Destroy()
end

connection1 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == AimKey then
        aimbotActive = not aimbotActive
        if aimbotActive then
            target = findTarget()
        else
            stopAimbot()
        end
    elseif input.KeyCode == StopKey then
        stopScript()
    end
end)

connection2 = UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
    if gameProcessed then
        return
    end

    inputPosition = Vector2.new(touch.Position.X, touch.Position.Y)
end)

connection3 = UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
    if gameProcessed then
        return
    end

    inputPosition = Vector2.new(touch.Position.X, touch.Position.Y)
end)

connection4 = RunService.RenderStepped:Connect(function()
    -- Update input position every frame
    updateInputPosition()

    if aimbotActive then
        target = findTarget()
        if target then
            fovCircle.Color = Color3.new(0, 1, 0) -- Green: Locked on
            aimlock()
        else
            fovCircle.Color = Color3.new(0, 0, 1) -- Blue: Active but no target
        end
    else
        fovCircle.Color = Color3.new(1, 0, 0) -- Red: Paused
    end
end)

--if UserInputService.TouchEnabled then
    do -- Toggle button
        local frame = Instance.new("Frame", screenGui)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, 40, 0, 40)
        frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        frame.Position = UDim2.new(1, -20, 0.5, -20)

        local textLabel = Instance.new("TextLabel", frame)
        textLabel.BorderSizePixel = 0
        textLabel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        textLabel.Text = "AIMBOT"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.BackgroundTransparency = 0.35
        textLabel.TextScaled = true
        textLabel.FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255);

        local uiStroke = Instance.new("UIStroke", textLabel)
        uiStroke.Color = Color3.fromRGB(241, 241, 241)
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local uiCorner = Instance.new("UICorner", textLabel)
        uiCorner.CornerRadius = UDim.new(1, 0)

        local uiPadding = Instance.new("UIPadding", textLabel);
        uiPadding.PaddingRight = UDim.new(0, 10)
        uiPadding.PaddingLeft = UDim.new(0, 10)

        local textButton = Instance.new("TextButton", frame)
        textButton.BorderSizePixel = 0
        textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        textButton.TextSize = 14
        textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        textButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        textButton.Size = UDim2.new(1, 0, 1, 0)
        textButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textButton.Text = ""
        textButton.BackgroundTransparency = 1

        local uiCornerButton = Instance.new("UICorner", textButton)
        uiCornerButton.CornerRadius = UDim.new(1, 0)

        textButton.MouseButton1Click:Connect(function()
            aimbotActive = not aimbotActive
        end)
    end

    do -- Stop button
        local frame = Instance.new("Frame", screenGui)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, 30, 0, 30)
        frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        frame.Position = UDim2.new(1, -20, 0.5, -40)

        local textLabel = Instance.new("TextLabel", frame)
        textLabel.BorderSizePixel = 0
        textLabel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        textLabel.Text = "STOP"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.BackgroundTransparency = 0.35
        textLabel.TextScaled = true
        textLabel.FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        textLabel.TextColor3 = Color3.fromRGB(255, 25, 25);

        local uiStroke = Instance.new("UIStroke", textLabel)
        uiStroke.Color = Color3.fromRGB(241, 241, 241)
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local uiCorner = Instance.new("UICorner", textLabel)
        uiCorner.CornerRadius = UDim.new(1, 0)

        local uiPadding = Instance.new("UIPadding", textLabel);
        uiPadding.PaddingRight = UDim.new(0, 10)
        uiPadding.PaddingLeft = UDim.new(0, 10)

        local textButton = Instance.new("TextButton", frame)
        textButton.BorderSizePixel = 0
        textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        textButton.TextSize = 14
        textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        textButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        textButton.Size = UDim2.new(1, 0, 1, 0)
        textButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textButton.Text = ""
        textButton.BackgroundTransparency = 1

        local uiCornerButton = Instance.new("UICorner", textButton)
        uiCornerButton.CornerRadius = UDim.new(1, 0)

        textButton.MouseButton1Click:Connect(function()
            stopScript()
        end)
    end
--end
