local Values = {
    ["Fitness"] = 2,
    ["Strength"] = 2,
    ["Aiming"] = 2,
    ["Nimble"] = 2,
    ["WeightCap"] = 1.45,
    ["EnduranceOneTime"] = -0.2,
    ["Endurance"] = -0.3,
    ["LimbHealth"] = -0.0025,
}

local trait = "influence_obdolbos2"
local duration = "obdolbos2_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
        Player:alterLevel(Perks.Strength, Values["Strength"])
        Player:alterLevel(Perks.Nimble, Values["Nimble"])
        Player:alterLevel(Perks.Aiming, Values["Aiming"])
        Player:alterWeightCap(Values["WeightCap"])
    end,
    delay    = Seconds(1),
    duration = Seconds(1800),
    postFunc = function ()
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
        Player:alterLevel(Perks.Strength, -Values["Strength"])
        Player:alterLevel(Perks.Nimble, -Values["Nimble"])
        Player:alterLevel(Perks.Aiming, -Values["Aiming"])
        Player:alterWeightCap(-Values["WeightCap"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterEndurance(Values["EnduranceOneTime"])
    end,
    delay    = Seconds(1),
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterEndurance(OverTime(Values["EnduranceOneTime"], Seconds(1800)))
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(1),
    duration = Seconds(1800),
    postFunc = nil,
    repeated = true
})

function Obdolbos2_OnInject(item, player, _)
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
local function obdolbos2_OnUpdate(player)
    if player:getTraits():contains(trait) then
        local modData = player:getModData()

        modData[duration] = (modData[duration] or 0) + 1
        event.ticks = modData[duration]
        event:process()

        if modData[duration] >= event:duration() then
            player:getTraits():remove(trait)
        end
    end
end

Events.OnPlayerUpdate.Add(obdolbos2_OnUpdate)