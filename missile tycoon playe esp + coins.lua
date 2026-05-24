-- ==========================================
-- 👑 VIP ESP: BOX + THICK LINES + STATS
-- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
-- 🔴 YAHAN APNE DUSHMAN KA AADHA YA PURA NAAM LIKH 🔴
_G.TargetEnemy = "TargetNameHere" 

local espData = {}
local playerStats = {}

-- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
-- Background Data Scanner (Items hidden in backend, Money updated live)
task.spawn(function()
    while task.wait(2) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                -- 1. Paise (Coins) check karna
                local moneyStr = "0"
                if player:FindFirstChild("leaderstats") then
                    local m = player.leaderstats:FindFirstChild("Money") or player.leaderstats:FindFirstChild("Cash") or player.leaderstats:FindFirstChild("Coins")
                    if m then moneyStr = tostring(m.Value) end
                end

                -- 2. Base Strength Scan (Backend only, hidden from UI)
                local itemCount = 0
                for _, folder in pairs(Workspace:GetDescendants()) do
                    if folder:IsA("ObjectValue") and folder.Name == "Owner" and folder.Value == player then
                        itemCount = itemCount + #(folder.Parent:GetDescendants())
                    elseif folder:IsA("StringValue") and folder.Name == "Owner" and folder.Value == player.Name then
                        itemCount = itemCount + #(folder.Parent:GetDescendants())
                    end
                end
                
                if itemCount == 0 and player:FindFirstChild("leaderstats") then
                    local b = player.leaderstats:FindFirstChild("Buildings") or player.leaderstats:FindFirstChild("Rockets")
                    if b then itemCount = b.Value end
                end

                local strength = (itemCount >= 50) and "STRONG 💪" or "WEAK 🧱"

                playerStats[player] = {
                    Money = moneyStr,
                    Items = itemCount,
                    Status = strength
                }
            end
        end
    end
end)

local function createESP(player)
    if player == LocalPlayer then return end

    -- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
    -- Smooth Line (Tracer)
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 3 
    tracer.Transparency = 1

    -- 2D Box (Avatar ke charo taraf)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 3 
    box.Transparency = 1
    box.Filled = false

    espData[player] = { Line = tracer, Box = box }

    local function setupCharacter(character)
        if character:FindFirstChild("SidHighlight") then character.SidHighlight:Destroy() end
        if character:FindFirstChild("Head") and character.Head:FindFirstChild("SidTextGui") then character.Head.SidTextGui:Destroy() end

        local search = string.lower(_G.TargetEnemy)
        local isEnemy = (search ~= "" and search ~= "targetnamehere") and (string.lower(player.Name):match(search) or string.lower(player.DisplayName):match(search))
        local color = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        
        -- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
        -- Body Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "SidHighlight"
        highlight.FillColor = color
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        -- Text GUI (Name & Money Only)
        local head = character:WaitForChild("Head", 5)
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "SidTextGui"
            billboard.AlwaysOnTop = true 
            billboard.Size = UDim2.new(0, 250, 0, 75) -- Size adjusted for 3 lines
            billboard.StudsOffset = Vector3.new(0, 4, 0) 

            local text = Instance.new("TextLabel")
            text.Name = "Info"
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = color
            text.TextScaled = true
            text.Font = Enum.Font.GothamBlack
            text.TextStrokeTransparency = 0 
            text.Parent = billboard
            billboard.Parent = head
            
            espData[player].GuiText = text
        end
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

-- Initialize sabke liye
for _, player in pairs(Players:GetPlayers()) do createESP(player) end
Players.PlayerAdded:Connect(createESP)

-- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
Players.PlayerRemoving:Connect(function(player)
    if espData[player] then
        espData[player].Line:Remove()
        espData[player].Box:Remove()
        espData[player] = nil
    end
end)

-- 🔄 FAST LOOP: Live Drawing (Lines & Boxes)
RunService.RenderStepped:Connect(function()
    local search = string.lower(_G.TargetEnemy)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and espData[player] then
            local data = espData[player]
            local stats = playerStats[player] or {Money = "0", Items = 0, Status = "Scanning..."}
            
            local isEnemy = (search ~= "" and search ~= "targetnamehere") and (string.lower(player.Name):match(search) or string.lower(player.DisplayName):match(search))
            local drawColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            local titleText = isEnemy and "🚨 ENEMY 🚨" or "🟢 PLAYER 🟢"

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character.Head
                
                -- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy
                -- Live Text Update (Items hidden, only showing Title, Name, Coins)
                if data.GuiText then
                    data.GuiText.Text = string.format("%s\n%s\n💰 Coins: %s", 
                        titleText, player.Name, stats.Money)
                    data.GuiText.TextColor3 = drawColor
                end

                -- 3D to 2D Math for ESP Drawings
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headVector = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legVector = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                if onScreen then
                    -- Draw Line (Top se HRP tak)
                    data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    data.Line.To = Vector2.new(vector.X, vector.Y)
                    data.Line.Color = drawColor
                    data.Line.Visible = true

                    -- Draw Box (Avatar size ke hisaab se)
                    local boxHeight = math.abs(headVector.Y - legVector.Y)
                    local boxWidth = boxHeight * 0.6 
                    data.Box.Size = Vector2.new(boxWidth, boxHeight)
                    data.Box.Position = Vector2.new(vector.X - boxWidth/2, headVector.Y)
                    data.Box.Color = drawColor
                    data.Box.Visible = true
                else
                    data.Line.Visible = false
                    data.Box.Visible = false
                end
            else
                data.Line.Visible = false
                data.Box.Visible = false
            end
        end
    end
end)

print("✅ VIP ESP Loaded: Box + Moti Lines + Live Coins!")
-- Script made by siddharth ( viperdark - lotusismyfavbaby ) enjoy