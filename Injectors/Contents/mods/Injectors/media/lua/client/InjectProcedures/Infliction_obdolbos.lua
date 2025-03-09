local Values = {
    ["Fitness"] = 1,
    ["Strength"] = 1,
    ["Aiming"] = 1,
    ["Stress"] = -0.1,
    ["LimbHealth"] = 0.1,
    ["EnduranceOneTime"] = 0.2,
    ["Endurance"] = 0.0002,
    ["WeightCap"] = 1.05,
    ["Hunger"] = 0.0005,
    ["Thirst"] = 0.0005,
    ["LimbDamageIncrease"] = 1.25
}

local trait = "influence_obdolbos"
local duration = "obdolbos_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

local function rerollEffects()
    return {
        stamina     = ZombRand(4) == 0,
        endurance   = ZombRand(4) == 0,
        fitness     = ZombRand(4) == 0,
        aiming      = ZombRand(4) == 0,
        strength    = ZombRand(4) == 0,
        weightcap   = ZombRand(4) == 0,
        limbhealth  = ZombRand(4) == 0,
        stress      = ZombRand(4) == 0,
        death       = ZombRand(4) == 0,
        alldamage   = ZombRand(4) == 0,
        hunger      = ZombRand(4) == 0,
        thirst      = ZombRand(4) == 0,
    }
end

ObdolbosRolls = {}

event:plan({
    mainFunc = function()
        if ObdolbosRolls.stamina then Player:alterEndurance(Values["EnduranceOneTime"]) end
        if ObdolbosRolls.death then Player:alterHealth(-1000) end
    end,
    delay    = Seconds(1),
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        if ObdolbosRolls.fitness    then Player:alterLevel(Perks.Fitness, Values["Fitness"]) end
        if ObdolbosRolls.aiming     then Player:alterLevel(Perks.Aiming, Values["Aiming"]) end
        if ObdolbosRolls.strength   then Player:alterLevel(Perks.Strength, Values["Strength"]) end
        if ObdolbosRolls.weightcap  then Player:alterWeightCap(Values["WeightCap"]) end
        if ObdolbosRolls.alldamage  then Player:alterLimbHealth(Values["LimbDamageIncrease"]) end
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = function ()
        if ObdolbosRolls.fitness    then Player:alterLevel(Perks.Fitness, -Values["Fitness"]) end
        if ObdolbosRolls.aiming     then Player:alterLevel(Perks.Aiming, -Values["Aiming"]) end
        if ObdolbosRolls.strength   then Player:alterLevel(Perks.Strength, -Values["Strength"]) end
        if ObdolbosRolls.weightcap  then Player:alterWeightCap(-Values["WeightCap"]) end
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        if ObdolbosRolls.limbhealth then Player:alterLimbHealth(Values["LimbHealth"]) end
        if ObdolbosRolls.endurance  then Player:alterEndurance(Values["Endurance"]) end
        if ObdolbosRolls.stress     then Player:alterStress(Values["Stress"]) end
        if ObdolbosRolls.hunger     then Player:alterHunger(OverTime(Values["Stress"], Seconds(600))) end
        if ObdolbosRolls.thirst     then Player:alterHunger(OverTime(Values["Thirst"], Seconds(600))) end
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = nil,
    repeated = true
})

function Obdolbos_OnInject(item, player, _)
    local inventory = player:getInventory()
    if player:getTraits():contains(trait) == false then
        player:getModData()[duration] = 0
        player:getTraits():add(trait)
    else
        inventory:AddItem(item:getFullType())
        player:Say(InjectWhileBuffedPhrase[ZombRand(#InjectWhileBuffedPhrase)+1])
    end
end

---@param player IsoPlayer
local function obdolbos_OnUpdate(player)
    if player:getTraits():contains(trait) then
        local modData = player:getModData()
        ObdolbosRolls = modData.obdolbos_rolls

        modData[duration] = (modData[duration] or 0) + 1
        event.ticks = modData[duration]
        event:process()

        if modData[duration] >= event:duration() then
            player:getTraits():remove(trait)
        end
    end
end

Events.OnPlayerUpdate.Add(obdolbos_OnUpdate)