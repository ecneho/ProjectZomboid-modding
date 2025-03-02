PlayerInstance = {}
PlayerInstance.__index = PlayerInstance

InjectWhileBuffedPhrase = {
    [1] = "I don't think this is a good idea.",
    [2] = "I shouldn't risk it.",
    [3] = "It may end up bad.",
    [4] = "This could be dangerous.",
    [5] = "I'm not sure.",
    [6] = "I think I should hold off on this.",
    [7] = "This doesn't feel right."
}

function PlayerInstance:init(player)
    self.player = player
end

---@return IsoPlayer
function PlayerInstance:get()
    return self.player
end

Player = setmetatable({player = nil}, PlayerInstance)

---@param player IsoPlayer
local function OnPlayerUpdate(player)
    if player:isDead() then
        Player:init(nil)
        return
    end
    if Player:get() == nil then
        Player:init(player)
    end
end

Events.OnPlayerUpdate.Add(OnPlayerUpdate)
--- --- ---

function PlayerInstance:alterHunger(amount)
    if self.player == nil then return end
    local hunger = self.player:getStats():getHunger() + amount
    self.player:getStats():setHunger(Clamp(hunger, 0, 1))
end

function PlayerInstance:alterThirst(amount)
    if self.player == nil then return end
    local thirst = self.player:getStats():getThirst() + amount
    self.player:getStats():setThirst(Clamp(thirst, 0, 1))
end

function PlayerInstance:alterPain(amount)
    if self.player == nil then return end
    local pain = self.player:getStats():getPain() + amount
    self.player:getStats():setPain(Clamp(pain, 0, 100))
end

function PlayerInstance:alterEndurance(amount)
    if self.player == nil then return end
    local endurance = self.player:getStats():getEndurance() + amount
    self.player:getStats():setEndurance(Clamp(endurance, 0, 1))
end

---@param perk Perk
function PlayerInstance:alterLevel(perk, amount)
    if self.player == nil then return end
    self.player:LevelPerk(perk) -- this part is required to make perklvldebug work :3
    self.player:LoseLevel(perk) -- workaround until I figure out how to avoid level overflow

    local level = self.player:getPerkLevel(perk) + amount
    self.player:setPerkLevelDebug(perk, level)
end

function PlayerInstance:alterStress(amount)
    if self.player == nil then return end
    local stress = self.player:getStats():getStress() + amount
    self.player:getStats():setStress(Clamp(stress, 0, 1))
end

function PlayerInstance:alterHealth(amount)
    if self.player == nil then return end
    local health = self.player:getBodyDamage():getOverallBodyHealth() + amount
    self.player:getBodyDamage():setOverallBodyHealth(Clamp(health, 0, 100))
end

function PlayerInstance:alterLimbHealth(amount)
    if self.player == nil then return end
    local parts = self.player:getBodyDamage():getBodyParts()
    for index = 0, parts:size() - 1 do
        local part = parts:get(index) ---@type BodyPart
        part:AddHealth(Clamp(amount, 0, 100))
    end
end

function PlayerInstance:alterMetabolism(amount)
    if self.player == nil then return end
    local nutrition = self.player:getNutrition()

    nutrition:setCalories(nutrition:getCalories() + amount)
    nutrition:setCarbohydrates(nutrition:getCarbohydrates() + amount)
    nutrition:setLipids(nutrition:getLipids() + amount)
    nutrition:setProteins(nutrition:getProteins() + amount)
end

function PlayerInstance:rollPanicAttack(chance)
    if self.player == nil then return end
    local item = self.player:getPrimaryHandItem() ---@type InventoryItem
    if item ~= nil and item:IsWeapon() then
        if chance > ZombRand(100)+1 then
            if item:getAmmoType() and self.player:IsAiming() then
                item:setJammed(true)
            end
        end
    end
end

function PlayerInstance:alterImmunity(amount)
    if self.player == nil then return end
    self.player:getBodyDamage():setCatchACold(amount)
end

function PlayerInstance:alterInfected(isInfected)
    if self.player == nil then return end
    self.player:getBodyDamage():setInfected(isInfected)
    self.player:getBodyDamage():setIsFakeInfected(isInfected)
end

function PlayerInstance:alterWoundTime(amount)
    if self.player == nil then return end
    local parts = self.player:getBodyDamage():getBodyParts()
    local part = parts:get(ZombRand(parts:size()))
    if part:isDeepWounded() then
        part:setDeepWoundTime(part:getDeepWoundTime() / 1.1)
    end
    part:setBleedingTime(0)
end

function PlayerInstance:alterWeightCap(amount)
    if self.player == nil then return end
    self.player:setMaxWeightDelta(self.player:getMaxWeightDelta() * amount);
end

function PlayerInstance:alterTemperature(amount)
    if self.player == nil then return end
    local temperature = self.player:getBodyDamage():getTemperature() + amount
    self.player:getBodyDamage():setTemperature(Clamp(temperature, 20, 42))
end

function PlayerInstance:alterStifness(amount, targetedParts)
    if self.player == nil then return end
    local parts = self.player:getBodyDamage():getBodyParts()
    for _, index in ipairs(targetedParts) do
        local part = parts:get(index) ---@type BodyPart
        if part:getStiffness() <= amount then
            part:setStiffness(amount)
        end
    end
end