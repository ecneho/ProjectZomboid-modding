local Values = {
    ["Health"] = -10,
    ["Infected"] = false
}

local trait = "influence_xtg"
local duration = "xtg_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterInfected(Values["Infected"])
    end,
    delay    = Seconds(6),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
    end,
    delay    = Seconds(6),
    duration = nil,
    postFunc = nil,
    repeated = false
})

function Xtg_OnInject(player, item)
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
local function xtg_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(xtg_OnUpdate)