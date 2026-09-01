-- ================================================================
-- ROBLOX MELEE COMBAT SYSTEM - Main Combat Script
-- Place this in: StarterPlayer > StarterCharacterScripts
-- ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ================================================================
-- COMBAT CONFIGURATION
-- ================================================================
local COMBAT_CONFIG = {
    -- Basic Attack Settings
    ATTACK_COOLDOWN = 0.8,
    ATTACK_DAMAGE = 25,
    ATTACK_RANGE = 30,
    ATTACK_SPEED = 0.5,
    
    -- Combo System
    COMBO_RESET_TIME = 2,
    MAX_COMBO = 4,
    COMBO_DAMAGE_MULTIPLIER = 0.15,
    
    -- Ability Settings
    HEAVY_ATTACK_COOLDOWN = 3,
    HEAVY_ATTACK_DAMAGE = 60,
    HEAVY_ATTACK_RANGE = 40,
    
    SPIN_ATTACK_COOLDOWN = 4,
    SPIN_ATTACK_DAMAGE = 45,
    SPIN_ATTACK_RANGE = 35,
    
    CHARGE_ATTACK_COOLDOWN = 5,
    CHARGE_ATTACK_DAMAGE = 80,
    CHARGE_ATTACK_RANGE = 50,
    
    -- Health Settings
    MAX_HEALTH = 100,
    HEALTH_REGEN = 1,
    HEALTH_REGEN_DELAY = 3,
}

-- ================================================================
-- STATE VARIABLES
-- ================================================================
local combatState = {
    isAttacking = false,
    lastAttackTime = 0,
    comboCount = 0,
    lastComboResetTime = 0,
    
    lastHeavyAttackTime = 0,
    lastSpinAttackTime = 0,
    lastChargeAttackTime = 0,
    
    isCharging = false,
    chargeAmount = 0,
    
    lastHealthRegenTime = 0,
}

-- ================================================================
-- ANIMATION SYSTEM
-- ================================================================
local AnimationSystem = {}
AnimationSystem.animations = {}

function AnimationSystem:loadAnimations()
    -- Basic Attack Animations
    self.animations.attack1 = humanoid:LoadAnimation(self:createAttackAnimation(1))
    self.animations.attack2 = humanoid:LoadAnimation(self:createAttackAnimation(2))
    self.animations.attack3 = humanoid:LoadAnimation(self:createAttackAnimation(3))
    self.animations.attack4 = humanoid:LoadAnimation(self:createAttackAnimation(4))
    
    -- Special Ability Animations
    self.animations.heavyAttack = humanoid:LoadAnimation(self:createHeavyAttackAnimation())
    self.animations.spinAttack = humanoid:LoadAnimation(self:createSpinAttackAnimation())
    self.animations.chargeAttack = humanoid:LoadAnimation(self:createChargeAttackAnimation())
    self.animations.idle = humanoid:LoadAnimation(self:createIdleAnimation())
end

function AnimationSystem:createAttackAnimation(comboNumber)
    -- Create a basic attack animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://0"  -- Replace with your animation IDs
    return anim
end

function AnimationSystem:createHeavyAttackAnimation()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://0"  -- Replace with your animation ID
    return anim
end

function AnimationSystem:createSpinAttackAnimation()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://0"  -- Replace with your animation ID
    return anim
end

function AnimationSystem:createChargeAttackAnimation()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://0"  -- Replace with your animation ID
    return anim
end

function AnimationSystem:createIdleAnimation()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://0"  -- Replace with your animation ID
    return anim
end

function AnimationSystem:playAttackAnimation(comboCount)
    comboCount = math.min(comboCount, 4)
    local animKey = "attack" .. comboCount
    if self.animations[animKey] then
        self.animations[animKey]:Play()
    end
end

function AnimationSystem:playAbilityAnimation(abilityName)
    if self.animations[abilityName] then
        self.animations[abilityName]:Play()
    end
end

function AnimationSystem:stopAllAnimations()
    for _, anim in pairs(self.animations) do
        if anim then
            anim:Stop()
        end
    end
end

-- Load animations
AnimationSystem:loadAnimations()

-- ================================================================
-- SOUND SYSTEM
-- ================================================================
local SoundSystem = {}
SoundSystem.sounds = {}

function SoundSystem:loadSounds()
    -- Create sound instances
    self.sounds.attack = self:createSound("rbxassetid://471881954", 0.5)  -- Sword slash
    self.sounds.heavyAttack = self:createSound("rbxassetid://471881954", 0.7)  -- Heavy hit
    self.sounds.spinAttack = self:createSound("rbxassetid://471881954", 0.6)  -- Spin whoosh
    self.sounds.chargeAttack = self:createSound("rbxassetid://471881954", 0.8)  -- Charge release
    self.sounds.hit = self:createSound("rbxassetid://471881980", 0.5)  -- Hit impact
    self.sounds.dodge = self:createSound("rbxassetid://471881954", 0.4)  -- Dodge sound
end

function SoundSystem:createSound(id, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = volume
    sound.Parent = humanoidRootPart
    return sound
end

function SoundSystem:playSound(soundName)
    if self.sounds[soundName] then
        self.sounds[soundName]:Play()
    end
end

-- Load sounds
SoundSystem:loadSounds()

-- ================================================================
-- DAMAGE & HITBOX SYSTEM
-- ================================================================
local HitboxSystem = {}
HitboxSystem.hitEnemies = {}

function HitboxSystem:findNearbyEnemies(range)
    local enemies = {}
    local hitEnemies = {}
    
    for _, other in pairs(workspace:GetDescendants()) do
        if other:IsA("Humanoid") and other ~= humanoid then
            local character = other.Parent
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if distance <= range then
                    table.insert(enemies, other)
                end
            end
        end
    end
    
    return enemies
end

function HitboxSystem:dealDamage(targetHumanoid, damage, attackType)
    if targetHumanoid and targetHumanoid.Health > 0 then
        targetHumanoid:TakeDamage(damage)
        SoundSystem:playSound("hit")
        print("Dealt " .. damage .. " damage with " .. attackType)
    end
end

function HitboxSystem:clearHitEnemies()
    self.hitEnemies = {}
end

function HitboxSystem:hasHitEnemy(humanoid)
    return table.find(self.hitEnemies, humanoid) ~= nil
end

function HitboxSystem:addHitEnemy(humanoid)
    table.insert(self.hitEnemies, humanoid)
end

-- ================================================================
-- COMBAT ABILITIES
-- ================================================================
local CombatAbilities = {}

function CombatAbilities:basicAttack()
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - combatState.lastAttackTime < COMBAT_CONFIG.ATTACK_COOLDOWN then
        return false
    end
    
    combatState.lastAttackTime = currentTime
    combatState.comboCount = combatState.comboCount + 1
    
    -- Cap combo at max
    if combatState.comboCount > COMBAT_CONFIG.MAX_COMBO then
        combatState.comboCount = 1
    end
    
    combatState.isAttacking = true
    
    -- Play animation
    AnimationSystem:playAttackAnimation(combatState.comboCount)
    SoundSystem:playSound("attack")
    
    -- Calculate damage with combo multiplier
    local damage = COMBAT_CONFIG.ATTACK_DAMAGE * (1 + (combatState.comboCount - 1) * COMBAT_CONFIG.COMBO_DAMAGE_MULTIPLIER)
    
    -- Deal damage to nearby enemies
    local enemies = HitboxSystem:findNearbyEnemies(COMBAT_CONFIG.ATTACK_RANGE)
    HitboxSystem:clearHitEnemies()
    
    for _, enemy in pairs(enemies) do
        if not HitboxSystem:hasHitEnemy(enemy) then
            HitboxSystem:dealDamage(enemy, damage, "Basic Attack")
            HitboxSystem:addHitEnemy(enemy)
        end
    end
    
    -- Reset combo after delay
    task.delay(COMBAT_CONFIG.COMBO_RESET_TIME, function()
        if tick() - combatState.lastAttackTime >= COMBAT_CONFIG.COMBO_RESET_TIME then
            combatState.comboCount = 0
        end
    end)
    
    task.delay(0.5, function()
        combatState.isAttacking = false
    end)
    
    return true
end

function CombatAbilities:heavyAttack()
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - combatState.lastHeavyAttackTime < COMBAT_CONFIG.HEAVY_ATTACK_COOLDOWN then
        return false
    end
    
    combatState.lastHeavyAttackTime = currentTime
    combatState.isAttacking = true
    
    -- Play animation
    AnimationSystem:playAbilityAnimation("heavyAttack")
    SoundSystem:playSound("heavyAttack")
    
    -- Deal damage
    local enemies = HitboxSystem:findNearbyEnemies(COMBAT_CONFIG.HEAVY_ATTACK_RANGE)
    HitboxSystem:clearHitEnemies()
    
    for _, enemy in pairs(enemies) do
        if not HitboxSystem:hasHitEnemy(enemy) then
            HitboxSystem:dealDamage(enemy, COMBAT_CONFIG.HEAVY_ATTACK_DAMAGE, "Heavy Attack")
            HitboxSystem:addHitEnemy(enemy)
        end
    end
    
    task.delay(1, function()
        combatState.isAttacking = false
    end)
    
    return true
end

function CombatAbilities:spinAttack()
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - combatState.lastSpinAttackTime < COMBAT_CONFIG.SPIN_ATTACK_COOLDOWN then
        return false
    end
    
    combatState.lastSpinAttackTime = currentTime
    combatState.isAttacking = true
    
    -- Play animation
    AnimationSystem:playAbilityAnimation("spinAttack")
    SoundSystem:playSound("spinAttack")
    
    -- Rotate character while attacking
    local spinDuration = 1
    local spinStart = tick()
    
    local spinConnection
    spinConnection = RunService.RenderStepped:Connect(function()
        if tick() - spinStart < spinDuration then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
        else
            spinConnection:Disconnect()
        end
    end)
    
    -- Deal damage multiple times during spin
    local enemies = HitboxSystem:findNearbyEnemies(COMBAT_CONFIG.SPIN_ATTACK_RANGE)
    HitboxSystem:clearHitEnemies()
    
    for _, enemy in pairs(enemies) do
        if not HitboxSystem:hasHitEnemy(enemy) then
            HitboxSystem:dealDamage(enemy, COMBAT_CONFIG.SPIN_ATTACK_DAMAGE, "Spin Attack")
            HitboxSystem:addHitEnemy(enemy)
        end
    end
    
    task.delay(spinDuration, function()
        combatState.isAttacking = false
    end)
    
    return true
end

function CombatAbilities:chargeAttack()
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - combatState.lastChargeAttackTime < COMBAT_CONFIG.CHARGE_ATTACK_COOLDOWN then
        return false
    end
    
    combatState.lastChargeAttackTime = currentTime
    combatState.isCharging = true
    combatState.chargeAmount = 0
    
    SoundSystem:playSound("chargeAttack")
    
    -- Charge for up to 2 seconds
    local chargeStart = tick()
    local chargeDuration = 2
    
    while combatState.isCharging and tick() - chargeStart < chargeDuration do
        combatState.chargeAmount = math.min((tick() - chargeStart) / chargeDuration, 1)
        task.wait(0.01)
    end
    
    combatState.isAttacking = true
    
    -- Play animation
    AnimationSystem:playAbilityAnimation("chargeAttack")
    
    -- Deal damage based on charge amount
    local baseDamage = COMBAT_CONFIG.CHARGE_ATTACK_DAMAGE
    local finalDamage = baseDamage * (0.5 + combatState.chargeAmount * 0.5)
    
    local enemies = HitboxSystem:findNearbyEnemies(COMBAT_CONFIG.CHARGE_ATTACK_RANGE)
    HitboxSystem:clearHitEnemies()
    
    for _, enemy in pairs(enemies) do
        if not HitboxSystem:hasHitEnemy(enemy) then
            HitboxSystem:dealDamage(enemy, finalDamage, "Charge Attack")
            HitboxSystem:addHitEnemy(enemy)
        end
    end
    
    task.delay(1, function()
        combatState.isAttacking = false
        combatState.isCharging = false
        combatState.chargeAmount = 0
    end)
    
    return true
end

-- ================================================================
-- HEALTH & REGENERATION SYSTEM
-- ================================================================
local HealthSystem = {}

function HealthSystem:regenerateHealth()
    local currentTime = tick()
    
    if currentTime - combatState.lastHealthRegenTime >= COMBAT_CONFIG.HEALTH_REGEN_DELAY then
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = math.min(humanoid.Health + COMBAT_CONFIG.HEALTH_REGEN, humanoid.MaxHealth)
            combatState.lastHealthRegenTime = currentTime
        end
    end
end

-- ================================================================
-- COOLDOWN HELPER FUNCTIONS
-- ================================================================
local function getCooldownRemaining(lastTime, cooldown)
    return math.max(0, cooldown - (tick() - lastTime))
end

local function formatCooldown(seconds)
    return string.format("%.1f", seconds)
end

-- ================================================================
-- INPUT HANDLING
-- ================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or combatState.isAttacking then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.E then
        -- Basic Attack (Left Click or E)
        CombatAbilities:basicAttack()
    elseif input.KeyCode == Enum.KeyCode.R then
        -- Heavy Attack
        CombatAbilities:heavyAttack()
    elseif input.KeyCode == Enum.KeyCode.F then
        -- Spin Attack
        CombatAbilities:spinAttack()
    elseif input.KeyCode == Enum.KeyCode.Q then
        -- Charge Attack
        combatState.isCharging = not combatState.isCharging
        if combatState.isCharging then
            CombatAbilities:chargeAttack()
        end
    end
end)

-- ================================================================
-- MAIN GAME LOOP
-- ================================================================
RunService.Heartbeat:Connect(function()
    -- Regenerate health
    HealthSystem:regenerateHealth()
end)

-- ================================================================
-- CLEANUP
-- ================================================================
humanoid.Died:Connect(function()
    AnimationSystem:stopAllAnimations()
    script:Destroy()
end)

print("✓ Combat System Loaded Successfully!")
print("Controls:")
print("  E - Basic Attack (Combo)")
print("  R - Heavy Attack")
print("  F - Spin Attack")
print("  Q - Charge Attack")
