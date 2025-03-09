local Values = {
    ["EnduranceOneTime"] = 0.3,
    ["Endurance"] = 0.00007,
    ["LimbHealth"] = 0.002,
    ["PanicInterval"] = Seconds(5),
    ["PanicChance"] = 25
}

local trait = "influence_sj6"
local duration = "sj6_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

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
        Player:alterEndurance(Values["Endurance"])
    end,
    delay    = Seconds(1),
    duration = Seconds(240),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(200),
    duration = Seconds(40),
    postFunc = nil,
    repeated = true
})

function Sj6_OnInject(item, player, _)
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
local function sj6_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(sj6_OnUpdate)