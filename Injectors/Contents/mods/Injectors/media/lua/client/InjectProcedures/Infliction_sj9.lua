local Values = {
    ["Temperature"] = -20,
    ["Metabolism"] = -0.0002,
    ["Health"] = -0.1,
    ["PanicChance"] = 35,
    ["PanicInterval"] = Seconds(1),
    ["Stifness"] = 20
}

local trait = "influence_sj9"
local duration = "sj9_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterStifness(Values["Stifness"], {4, 5, 6})
    end,
    delay    = Seconds(300),
    duration = Seconds(120),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterHealth(Values["Health"])
        if event.ticks % Values["PanicInterval"] == 0 then
            Player:rollPanicAttack(Values["PanicChance"])
        end
    end,
    delay    = Seconds(6),
    duration = Seconds(420),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterMetabolism(Values["Metabolism"])
    end,
    delay    = Seconds(6),
    duration = Seconds(300),
    postFunc = nil,
    repeated = true
})

event:plan({
    mainFunc = function()
        Player:alterTemperature(Values["Temperature"])
    end,
    delay    = Seconds(6),
    duration = Seconds(300),
    postFunc = nil,
    repeated = true
})

function Sj9_OnInject(player, item)
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
local function sj9_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(sj9_OnUpdate)