local Values = {
    ["Strength"] = 2,
    ["Fitness"] = 2,
    ["Stress"] = -0.0005,
    ["Hunger"] = 0.3,
    ["Thirst"] = 0.4
}

local trait = "influence_sj1"
local duration = "sj1_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Strength, Values["Strength"])
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = function ()
        Player:alterLevel(Perks.Strength, -Values["Strength"])
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterStress(Values["Stress"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(200)))
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(200)))
    end,
    delay    = Seconds(100),
    duration = Seconds(200),
    postFunc = nil,
    repeated = true
})

function Sj1_OnInject(item, player, _)
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
local function sj1_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(sj1_OnUpdate)