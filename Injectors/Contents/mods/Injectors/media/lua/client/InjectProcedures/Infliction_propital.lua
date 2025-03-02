local Values = {
    ["Pain"] = -0.08,
    ["Health"] = 20,
    ["LimbHealth"] = 1,
    ["Metabolism"] = 0.0002,
    ["FirstAid"] = 2,
    ["PanicInterval"] = Seconds(0.5),
    ["PanicChance"] = 2
}

local trait = "influence_propital"
local duration = "propital_duration"
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
        Player:alterPain(Values["Pain"])
    end,
    delay    = nil,
    duration = Seconds(245),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Doctor, Values["FirstAid"])
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
        Player:alterMetabolism(Values["Metabolism"])
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(1),
    duration = Seconds(60),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
    end,
    delay    = Seconds(270),
    duration = Seconds(30),
    postFunc = nil,
    repeated = true
})

function Propital_OnInject(player, item)
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
local function propital_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(propital_OnUpdate)