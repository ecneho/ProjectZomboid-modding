local Values = {
    ["Aiming"] = 3,
    ["TemperatureDecrease"] = -10,
    ["TemperatureIncrease"] = 20,
    ["Hunger"] = -0.0005,
    ["Thirst"] = -0.0005,
}

local trait = "influence_sj12"
local duration = "sj12_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterHunger(Values["Hunger"])
        Player:alterThirst(Values["Thirst"])
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Aiming, Values["Aiming"])
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = function ()
        Player:alterLevel(Perks.Aiming, -Values["Aiming"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterTemperature(Values["TemperatureDecrease"])
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterTemperature(Values["TemperatureIncrease"])
    end,
    delay    = Seconds(606),
    duration = Seconds(300),
    postFunc = nil,
    repeated = true
})

function Sj12_OnInject(item, player, _)
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
local function sj12_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(sj12_OnUpdate)