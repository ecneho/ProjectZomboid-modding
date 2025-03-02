local Values = {
    ["Thirst"] = 0.3,
    ["Health"] = 10,
    ["WoundHeal"] = 0.004
}

local trait = "influence_ahf1"
local duration = "ahf1_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
    end,
    delay    = nil,
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterWoundTime(Values["WoundHeal"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(120)))
    end,
    delay    = Seconds(1),
    duration = Seconds(120),
    postFunc = nil,
    repeated = true
})

function Ahf1_OnInject(player, item)
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
local function ahf1_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(ahf1_OnUpdate)