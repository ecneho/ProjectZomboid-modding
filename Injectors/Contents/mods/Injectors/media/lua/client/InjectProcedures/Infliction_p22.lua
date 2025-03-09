local Values = {
    ["Stress"] = -0.5,
    ["Health"] = 30,
    ["FirstAid"] = 3,
    ["Fitness"] = -1,
    ["Endurance"] = -0.07,
}

local trait = "influence_p22"
local duration = "p22_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Doctor, Values["FirstAid"])
        Player:alterHealth(Values["Health"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = function ()
        Player:alterLevel(Perks.Doctor, -Values["FirstAid"])
    end,
    repeated = false
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
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(65),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Fitness, Values["Fitness"])
    end,
    delay    = Seconds(65),
    duration = Seconds(60),
    postFunc = function ()
        Player:alterLevel(Perks.Fitness, -Values["Fitness"])
    end,
    repeated = false
})

function P22_OnInject(item, player, _)
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
local function p22_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(p22_OnUpdate)