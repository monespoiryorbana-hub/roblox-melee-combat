-- ================================================================
-- ROBLOX COMBAT GUI SYSTEM - Health Bars & UI
-- Place this in: StarterPlayer > StarterPlayerScripts
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================================================================
-- GUI CONFIGURATION
-- ================================================================
local GUI_CONFIG = {
    HEALTH_BAR_WIDTH = 150,
    HEALTH_BAR_HEIGHT = 20,
    HEALTH_BAR_OFFSET = Vector3.new(0, 4, 0),
    
    COOLDOWN_BAR_WIDTH = 100,
    COOLDOWN_BAR_HEIGHT = 15,
    
    UPDATE_FREQUENCY = 0.1,
}

-- ================================================================
-- CREATE MAIN GUI SCREEN
-- ================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ================================================================
-- PLAYER HEALTH BAR (Bottom Left)
-- ================================================================
local playerHealthLabel = Instance.new("TextLabel")
playerHealthLabel.Name = "PlayerHealthLabel"
playerHealthLabel.Size = UDim2.new(0, 200, 0, 20)
playerHealthLabel.Position = UDim2.new(0, 10, 1, -110)
playerHealthLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerHealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerHealthLabel.TextSize = 14
playerHealthLabel.Font = Enum.Font.GothamBold
playerHealthLabel.Text = "Your Health"
playerHealthLabel.Parent = screenGui

local playerHealthBar = Instance.new("Frame")
playerHealthBar.Name = "PlayerHealthBar"
playerHealthBar.Size = UDim2.new(0, 200, 0, 25)
playerHealthBar.Position = UDim2.new(0, 10, 1, -85)
playerHealthBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerHealthBar.BorderSizePixel = 2
playerHealthBar.BorderColor3 = Color3.fromRGB(100, 100, 100)
playerHealthBar.Parent = screenGui

local playerHealthFill = Instance.new("Frame")
playerHealthFill.Name = "HealthFill"
playerHealthFill.Size = UDim2.new(1, 0, 1, 0)
playerHealthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
playerHealthFill.BorderSizePixel = 0
playerHealthFill.Parent = playerHealthBar

local playerHealthText = Instance.new("TextLabel")
playerHealthText.Name = "HealthText"
playerHealthText.Size = UDim2.new(1, 0, 1, 0)
playerHealthText.BackgroundTransparency = 1
playerHealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
playerHealthText.TextSize = 12
playerHealthText.Font = Enum.Font.GothamBold
playerHealthText.Text = "100 / 100"
playerHealthText.Parent = playerHealthBar

-- ================================================================
-- COOLDOWN DISPLAY (Bottom Left, under health)
-- ================================================================
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Name = "CooldownLabel"
cooldownLabel.Size = UDim2.new(0, 200, 0, 20)
cooldownLabel.Position = UDim2.new(0, 10, 1, -55)
cooldownLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
cooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cooldownLabel.TextSize = 12
cooldownLabel.Font = Enum.Font.Gotham
cooldownLabel.Text = "Abilities Ready"
cooldownLabel.Parent = screenGui

-- ================================================================
-- COMBO COUNTER (Top Left)
-- ================================================================
local comboLabel = Instance.new("TextLabel")
comboLabel.Name = "ComboLabel"
comboLabel.Size = UDim2.new(0, 150, 0, 50)
comboLabel.Position = UDim2.new(0, 10, 0, 10)
comboLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
comboLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
comboLabel.TextSize = 32
comboLabel.Font = Enum.Font.GothamBold
comboLabel.Text = "COMBO x0"
comboLabel.BorderSizePixel = 2
comboLabel.BorderColor3 = Color3.fromRGB(255, 215, 0)
comboLabel.Parent = screenGui

-- ================================================================
-- ABILITY BUTTONS (Top Right)
-- ================================================================
local buttonSize = UDim2.new(0, 80, 0, 80)
local buttonSpacing = 90

local function createAbilityButton(name, position, keyBind, cooldown)
    local button = Instance.new("Frame")
    button.Name = name .. "Button"
    button.Size = buttonSize
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Text = name
    title.Parent = button
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Name = "KeyLabel"
    keyLabel.Size = UDim2.new(1, 0, 0, 20)
    keyLabel.Position = UDim2.new(0, 0, 0, 30)
    keyLabel.BackgroundTransparency = 1
    keyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    keyLabel.TextSize = 10
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.Text = keyBind
    keyLabel.Parent = button
    
    local cooldownBar = Instance.new("Frame")
    cooldownBar.Name = "CooldownBar"
    cooldownBar.Size = UDim2.new(1, 0, 0, 3)
    cooldownBar.Position = UDim2.new(0, 0, 1, -3)
    cooldownBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    cooldownBar.BorderSizePixel = 0
    cooldownBar.Parent = button
    
    local cooldownText = Instance.new("TextLabel")
    cooldownText.Name = "CooldownText"
    cooldownText.Size = UDim2.new(1, 0, 1, 0)
    cooldownText.BackgroundTransparency = 1
    cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    cooldownText.TextSize = 12
    cooldownText.Font = Enum.Font.GothamBold
    cooldownText.Text = ""
    cooldownText.Parent = button
    
    return button, cooldownBar, cooldownText
end

local basicAttackBtn, basicCooldownBar, basicCooldownText = createAbilityButton("BASIC", UDim2.new(1, -280, 0, 10), "E", 0.8)
local heavyAttackBtn, heavyCooldownBar, heavyCooldownText = createAbilityButton("HEAVY", UDim2.new(1, -190, 0, 10), "R", 3)
local spinAttackBtn, spinCooldownBar, spinCooldownText = createAbilityButton("SPIN", UDim2.new(1, -100, 0, 10), "F", 4)
local chargeAttackBtn, chargeCooldownBar, chargeCooldownText = createAbilityButton("CHARGE", UDim2.new(1, -280, 0, 100), "Q", 5)

-- ================================================================
-- ENEMY HEALTH BARS (World Space)
-- ================================================================
local EnemyHealthBars = {}

local function createWorldHealthBar(character)
    if not character or not character:FindFirstChild("Humanoid") then
        return nil
    end
    
    local humanoid = character.Humanoid
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then
        return nil
    end
    
    -- Create BillboardGui for world space
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBillboard"
    billboard.Size = UDim2.new(GUI_CONFIG.HEALTH_BAR_WIDTH, 0, GUI_CONFIG.HEALTH_BAR_HEIGHT, 0)
    billboard.MaxDistance = 100
    billboard.Adornee = humanoidRootPart
    billboard.Parent = humanoidRootPart
    
    -- Background bar
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    background.BorderSizePixel = 1
    background.BorderColor3 = Color3.fromRGB(100, 100, 100)
    background.Parent = billboard
    
    -- Health fill
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = background
    
    -- Health text
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 10
    healthText.Font = Enum.Font.GothamBold
    healthText.Text = ""
    healthText.Parent = background
    
    -- Character name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 15)
    nameLabel.Position = UDim2.new(0, 0, 0, -20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = character.Name
    nameLabel.Parent = billboard
    
    return {
        billboard = billboard,
        healthFill = healthFill,
        healthText = healthText,
        humanoid = humanoid
    }
end

-- ================================================================
-- UPDATE FUNCTIONS
-- ================================================================
local function updatePlayerHealth(character)
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local healthPercent = math.max(0, humanoid.Health / humanoid.MaxHealth)
    
    playerHealthFill:TweenSize(
        UDim2.new(healthPercent, 0, 1, 0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
    
    playerHealthText.Text = string.format("%.0f / %.0f", humanoid.Health, humanoid.MaxHealth)
    
    -- Change color based on health percentage
    if healthPercent > 0.5 then
        playerHealthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    elseif healthPercent > 0.25 then
        playerHealthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    else
        playerHealthFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

local function updateComboCounter(comboCount)
    if comboCount > 0 then
        comboLabel.Text = "COMBO x" .. comboCount
        comboLabel.Visible = true
    else
        comboLabel.Visible = false
    end
end

local function updateCooldowns(combatState)
    -- Basic Attack
    local basicCooldown = math.max(0, 0.8 - (tick() - combatState.lastAttackTime))
    if basicCooldown > 0 then
        basicCooldownBar.Size = UDim2.new(basicCooldown / 0.8, 0, 0.15, 0)
        basicCooldownText.Text = string.format("%.1f", basicCooldown)
    else
        basicCooldownBar.Size = UDim2.new(0, 0, 0.15, 0)
        basicCooldownText.Text = ""
    end
    
    -- Heavy Attack
    local heavyCooldown = math.max(0, 3 - (tick() - combatState.lastHeavyAttackTime))
    if heavyCooldown > 0 then
        heavyCooldownBar.Size = UDim2.new(heavyCooldown / 3, 0, 0.15, 0)
        heavyCooldownText.Text = string.format("%.1f", heavyCooldown)
    else
        heavyCooldownBar.Size = UDim2.new(0, 0, 0.15, 0)
        heavyCooldownText.Text = ""
    end
    
    -- Spin Attack
    local spinCooldown = math.max(0, 4 - (tick() - combatState.lastSpinAttackTime))
    if spinCooldown > 0 then
        spinCooldownBar.Size = UDim2.new(spinCooldown / 4, 0, 0.15, 0)
        spinCooldownText.Text = string.format("%.1f", spinCooldown)
    else
        spinCooldownBar.Size = UDim2.new(0, 0, 0.15, 0)
        spinCooldownText.Text = ""
    end
    
    -- Charge Attack
    local chargeCooldown = math.max(0, 5 - (tick() - combatState.lastChargeAttackTime))
    if chargeCooldown > 0 then
        chargeCooldownBar.Size = UDim2.new(chargeCooldown / 5, 0, 0.15, 0)
        chargeCooldownText.Text = string.format("%.1f", chargeCooldown)
    else
        chargeCooldownBar.Size = UDim2.new(0, 0, 0.15, 0)
        chargeCooldownText.Text = ""
    end
end

local function updateEnemyHealthBars()
    -- Update existing health bars
    for character, healthBar in pairs(EnemyHealthBars) do
        if not character or not character.Parent or healthBar.humanoid.Health <= 0 then
            if healthBar.billboard then
                healthBar.billboard:Destroy()
            end
            EnemyHealthBars[character] = nil
        else
            -- Update health bar
            local healthPercent = math.max(0, healthBar.humanoid.Health / healthBar.humanoid.MaxHealth)
            healthBar.healthFill:TweenSize(
                UDim2.new(healthPercent, 0, 1, 0),
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Quad,
                0.1,
                true
            )
            
            healthBar.healthText.Text = string.format("%.0f", healthBar.humanoid.Health)
            
            -- Change color based on health
            if healthPercent > 0.5 then
                healthBar.healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            elseif healthPercent > 0.25 then
                healthBar.healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            else
                healthBar.healthFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
        end
    end
    
    -- Find new enemies
    for _, character in pairs(workspace:GetDescendants()) do
        if character:IsA("Model") and character ~= player.Character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and not EnemyHealthBars[character] then
                local healthBar = createWorldHealthBar(character)
                if healthBar then
                    EnemyHealthBars[character] = healthBar
                end
            end
        end
    end
end

-- ================================================================
-- MAIN UPDATE LOOP
-- ================================================================
RunService.Heartbeat:Connect(function()
    if player.Character then
        updatePlayerHealth(player.Character)
        updateEnemyHealthBars()
    end
end)

-- Listen for combat state changes from the character script
local combatStateConnection
local function setupCombatStateListener()
    if player.Character then
        local character = player.Character
        
        RunService.Heartbeat:Connect(function()
            -- This will be updated by the combat script
            -- For now, we'll update based on available info
            if character:FindFirstChild("Humanoid") then
                updatePlayerHealth(character)
            end
        end)
    end
end

player.CharacterAdded:Connect(function(character)
    setupCombatStateListener()
end)

setupCombatStateListener()

print("✓ Combat GUI System Loaded!")
print("Displaying health bars, cooldowns, and combo counter")
