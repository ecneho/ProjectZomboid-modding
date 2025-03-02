local Values = {
    ["Nimble"] = 1,
    ["Aiming"] = 1,
    ["Endurance"] = 0.3,
    ["Thirst"] = 0.4,
    ["WeightCap"] = 1.15,
    ["LimbHealth"] = -0.0005,
}

local trait = "influence_btg2a2"
local duration = "btg2a2_duration"
local event = TimedEvent:new()

TraitFactory.addTrait(trait, trait, -50, trait, true);

event:plan({
    mainFunc = function()
        Player:alterLevel(Perks.Nimble, Values["Nimble"])
        Player:alterLevel(Perks.Aiming, Values["Aiming"])
        Player:alterWeightCap(Values["WeightCap"])
    end,
    delay    = Seconds(1),
    duration = Seconds(900),
    postFunc = function ()
        Player:alterLevel(Perks.Nimble, -Values["Nimble"])
        Player:alterLevel(Perks.Aiming, -Values["Aiming"])
        Player:alterWeightCap(-Values["WeightCap"])
    end,
    repeated = false
})

event:plan({
    mainFunc = function()
        Player:alterThirst(OverTime(Values["Thirst"], Seconds(900)))
        Player:alterLimbHealth(Values["LimbHealth"])
    end,
    delay    = Seconds(1),
    duration = Seconds(900),
    postFunc = nil,
    repeated = true
})

function Btg2a2_OnInject(player, item)
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
local function btg2a2_OnUpdate(player)
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

Events.OnPlayerUpdate.Add(btg2a2_OnUpdate)