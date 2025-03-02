local Values = {
    ["Hunger"] = 0.03,
    ["Health"] = -15,
    ["WoundHeal"] = 0.004,
    ["Metabolism"] = 0.5,
    ["LimbHealth"] = 0.5,
    ["Infected"] = false
}

local trait = "influence_perfotoran"
local duration = "perfotoran_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLimbHealth(Values["LimbHealth"])
        Player:alterMetabolism(Values["Metabolism"])
        Player:alterWoundTime(Values["WoundHeal"])
        Player:alterInfected(Values["Infected"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(Values["Hunger"])
    end,
    delay    = Seconds(60),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
    end,
    delay    = Seconds(60),
    duration = Seconds(60),
    postFunc = nil,
    repeated = false
})

function Perfotoran_OnInject(player, item)
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
local function perfotoran_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(perfotoran_OnUpdate)