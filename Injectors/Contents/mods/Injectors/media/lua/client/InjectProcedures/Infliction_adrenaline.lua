local Values = {
    ["Pain"] = -0.08,
    ["Fitness"] = 1,
    ["Strength"] = 1,
    ["Health"] = 0.015,
    ["Stress"] = 0.0003,
    ["Hunger"] = 0.1,
    ["Thirst"] = 0.2
}

local trait = "influence_adrenaline"
local duration = "adrenaline_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterPain(Values["Pain"])
    end,
    delay    = nil,
    duration = Seconds(65),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
        Player:alterLevel(Perks.Strength, Values["Strength"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = function ()
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
        Player:alterLevel(Perks.Strength, -Values["Strength"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
    end,
    delay    = Seconds(1),
    duration = Seconds(15),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterStress(Values["Stress"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(30)))
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(30)))
    end,
    delay    = Seconds(50),
    duration = Seconds(30),
    postFunc = nil,
    repeated = true
})

function Adrenaline_OnInject(item, player, _)
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
local function adrenaline_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(adrenaline_OnUpdate)