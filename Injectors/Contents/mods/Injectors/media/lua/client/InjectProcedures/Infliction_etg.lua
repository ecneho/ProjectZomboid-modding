local Values = {
    ["Metabolism"] = 0.0002,
    ["Endurance"] = -0.2,
    ["LimbHealth"] = 0.65,
    ["Health"] = -20,
    ["HungerBuff"] = -0.005,
    ["HungerDebuff"] = 0.003,
    ["Immunity"] = 0
}

local trait = "influence_etg"
local duration = "etg_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterMetabolism(Values["Metabolism"])
        Player:alterImmunity(Values["Immunity"])
    end,
    delay    = Seconds(1),
    duration = Seconds(90),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterLimbHealth(Values["LimbHealth"])
        Player:alterHunger(Values["HungerBuff"])
    end,
    delay    = Seconds(1),
    duration = Seconds(90),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(65),
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterHunger(Values["HungerDebuff"])
    end,
    delay    = Seconds(65),
    duration = Seconds(20),
    postFunc = nil,
    repeated = true
})

function Etg_OnInject(item, player, _)
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
local function etg_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(etg_OnUpdate)