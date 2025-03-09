local Values = {
    ["Strength"] = 2,
    ["LimbHealth"] = 0.015,
    ["Health"] = -40,
    ["FirstAid"] = -2,
    ["PanicInterval"] = Seconds(5),
    ["PanicChance"] = 50
}

local trait = "influence_pnb"
local duration = "pnb_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Strength, Values["Strength"])
    end,
    delay    = Seconds(1),
    duration = Seconds(40),
    postFunc = function ()
        Player:alterLevel(Perks.Strength, -Values["Strength"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(1),
    duration = Seconds(40),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
    end,
    delay    = Seconds(41),
    duration = nil,
    postFunc = nil,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Doctor, Values["FirstAid"])
    end,
    delay    = Seconds(41),
    duration = Seconds(180),
    postFunc = function ()
        Player:alterLevel(Perks.Doctor, -Values["FirstAid"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
    end,
    delay    = Seconds(41),
    duration = Seconds(20),
    postFunc = nil,
    repeated = true
})

function Pnb_OnInject(item, player, _)
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
local function pnb_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(pnb_OnUpdate)