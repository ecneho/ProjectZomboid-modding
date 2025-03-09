local Values = {
    ["LimbHealth"] = -0.0002,
    ["WeightCap"] = 1.5
}

local trait = "influence_mule"
local duration = "mule_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterWeightCap(Values["WeightCap"])
    end,
    delay    = Seconds(1),
    duration = Seconds(600),
    postFunc = function ()
        Player:alterWeightCap(-Values["WeightCap"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(200),
    duration = Seconds(400),
    postFunc = nil,
    repeated = true
})

function Mule_OnInject(item, player, _)
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
local function mule_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(mule_OnUpdate)