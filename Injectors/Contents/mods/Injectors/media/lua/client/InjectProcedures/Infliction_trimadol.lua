local Values = {
    ["Pain"] = -0.08,
    ["Fitness"] = 1,
    ["Strength"] = 1,
    ["Nimble"] = 1,
    ["Stress"] = -0.0003,
    ["EnduranceOneTime"] = 0.1,
    ["Endurance"] = 0.00005,
    ["Hunger"] = 0.25,
    ["Thirst"] = 0.1
}

local trait = "influence_trimadol"
local duration = "trimadol_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterPain(Values["Pain"])
    end,
    delay    = nil,
    duration = Seconds(185),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterEndurance(Values["EnduranceOneTime"])
    end,
    delay    = nil,
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
        Player:alterLevel(Perks.Strength, Values["Strength"])
        Player:alterLevel(Perks.Nimble, Values["Nimble"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = function ()
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
        Player:alterLevel(Perks.Strength, -Values["Strength"])
        Player:alterLevel(Perks.Nimble, -Values["Nimble"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterStress(Values["Stress"])
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(180)))
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(180)))
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = nil,
    repeated = true
})

function Trimadol_OnInject(player, item)
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
local function trimadol_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(trimadol_OnUpdate)