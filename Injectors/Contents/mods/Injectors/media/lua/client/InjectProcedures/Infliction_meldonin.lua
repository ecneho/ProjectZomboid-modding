local Values = {
    ["Strength"] = 1,
    ["Fitness"] = 2,
    ["Endurance"] = 0.000015,
    ["Hunger"] = 0.7,
    ["Thirst"] = 0.7
}

local trait = "influence_meldonin"
local duration = "meldonin_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Strength, Values["Strength"])
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
    end,
    delay    = Seconds(1),
    duration = Seconds(900),
    postFunc = function ()
        Player:alterLevel(Perks.Strength, -Values["Strength"])
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(1),
    duration = Seconds(900),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(900)))
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(900)))
    end,
    delay    = Seconds(30),
    duration = Seconds(900),
    postFunc = nil,
    repeated = true
})

function Meldonin_OnInject(player, item)
    if player:getTraits():contains(trait) == false then
        player:getModData()[duration] = 0
        player:getTraits():add(trait)

        local inventory = player:getInventory()
        inventory:Remove(item)
        inventory:AddItem('injectorItems.injector_empty')
    else
        player:Say(InjectWhileBuffedPhrase[ZombRand(#InjectWhileBuffedPhrase)+1])
    end
end

---@param player IsoPlayer
local function meldonin_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(meldonin_OnUpdate)