local Values = {
    ["Nimble"] = 3,
    ["Aiming"] = 3,
    ["Strength"] = 1,
    ["Endurance"] = 0.000025,
    ["Hunger"] = 0.25,
    ["PanicInterval"] = Seconds(5),
    ["PanicChance"] = 25
}

local trait = "influence_btg3"
local duration = "btg3_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Nimble, Values["Nimble"])
        Player:alterLevel(Perks.Aiming, Values["Aiming"])
        Player:alterLevel(Perks.Strength, Values["Strength"])
    end,
    delay    = Seconds(1),
    duration = Seconds(240),
    postFunc = function ()
        Player:alterLevel(Perks.Nimble, -Values["Nimble"])
        Player:alterLevel(Perks.Aiming, -Values["Aiming"])
        Player:alterLevel(Perks.Strength, -Values["Strength"])
    end,
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
        Player:alterHunger(OverTime(Values["Hunger"], Seconds(120)))
    end,
    delay    = Seconds(120),
    duration = Seconds(120),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
    end,
    delay    = Seconds(220),
    duration = Seconds(45),
    postFunc = nil,
    repeated = true
})

function Btg3_OnInject(item, player, _)
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
local function btg3_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(btg3_OnUpdate)