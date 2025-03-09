local Values = {
    ["Pain"] = -0.08,
    ["Endurance"] = 0.3,
    ["Fitness"] = 1,
    ["Strength"] = 2,
    ["Hunger"] = 0.2,
    ["Thirst"] = 0.25
}

local trait = "influence_norepinephrine"
local duration = "norepinephrine_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterPain(Values["Pain"])
    end,
    delay    = nil,
    duration = Seconds(120),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(1),
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function ()
        Player:alterLevel(Perks.Fitness,  Values["Fitness"])
        Player:alterLevel(Perks.Strength, Values["Strength"])
    end,
    delay    = Seconds(1),
    duration = Seconds(120),
    postFunc = function()
        Player:alterLevel(Perks.Fitness,  -Values["Fitness"])
        Player:alterLevel(Perks.Strength, -Values["Strength"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(60)))
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(60)))
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

function Norepinephrine_OnInject(item, player, _)
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
local function norepinephrine_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(norepinephrine_OnUpdate)