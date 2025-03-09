local Values = {
    ["Pain"] = -0.08,
    ["Hunger"] = 0.1,
    ["Thirst"] = 0.15
}

local trait = "influence_morphine"
local duration = "morphine_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterPain(Values["Pain"])
    end,
    delay    = nil,
    duration = Seconds(405),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHunger(Values["Hunger"])
        Player:alterThirst(Values["Thirst"])
    end,
    delay    = nil,
    duration = nil,
    postFunc = nil,
    repeated = false
})

function Morphine_OnInject(item, player, _)
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
local function morphine_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(morphine_OnUpdate)