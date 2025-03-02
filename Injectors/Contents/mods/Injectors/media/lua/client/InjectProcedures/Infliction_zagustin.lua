local Values = {
    ["WoundHeal"] = 0.002,
    ["FirstAid"] = 2,
    ["Metabolism"] = -0.00003,
    ["Thirst"] = 0.0001,
    ["PanicInterval"] = Seconds(5),
    ["PanicChance"] = 25
}

local trait = "influence_zagustin"
local duration = "zagustin_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Doctor, Values["FirstAid"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = function()
        Player:alterLevel(Perks.Doctor, -Values["FirstAid"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterWoundTime(Values["WoundHeal"])
    end,
    delay    = nil,
    duration = Seconds(200),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterMetabolism(Values["Metabolism"])
    end,
    delay    = Seconds(1),
    duration = Seconds(180),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterThirst(Values["Thirst"])
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
    end,
    delay    = Seconds(170),
    duration = Seconds(40),
    postFunc = nil,
    repeated = true
})

function Zagustin_OnInject(player, item)
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
local function zagustin_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(zagustin_OnUpdate)