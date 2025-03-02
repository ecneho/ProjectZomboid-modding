InjectorBinds = {
    ["injectorItems.injector_adrenaline"]     = function(player, item) Adrenaline_OnInject      (player, item) end,
    ["injectorItems.injector_ahf1"]           = function(player, item) Ahf1_OnInject            (player, item) end,
    ["injectorItems.injector_btg2a2"]         = function(player, item) Btg2a2_OnInject          (player, item) end,
    ["injectorItems.injector_btg3"]           = function(player, item) Btg3_OnInject            (player, item) end,
    ["injectorItems.injector_etg"]            = function(player, item) Etg_OnInject             (player, item) end,
    ["injectorItems.injector_meldonin"]       = function(player, item) Meldonin_OnInject        (player, item) end,
    ["injectorItems.injector_morphine"]       = function(player, item) Morphine_OnInject        (player, item) end,
    ["injectorItems.injector_mule"]           = function(player, item) Mule_OnInject            (player, item) end,
    ["injectorItems.injector_norepinephrine"] = function(player, item) Norepinephrine_OnInject  (player, item) end,
    ["injectorItems.injector_obdolbos"]       = function(player, item) Obdolbos_OnInject        (player, item) end,
    ["injectorItems.injector_obdolbos2"]      = function(player, item) Obdolbos2_OnInject       (player, item) end,
    ["injectorItems.injector_p22"]            = function(player, item) P22_OnInject             (player, item) end,
    ["injectorItems.injector_perfotoran"]     = function(player, item) Perfotoran_OnInject      (player, item) end,
    ["injectorItems.injector_pnb"]            = function(player, item) Pnb_OnInject             (player, item) end,
    ["injectorItems.injector_propital"]       = function(player, item) Propital_OnInject        (player, item) end,
    ["injectorItems.injector_sj1"]            = function(player, item) Sj1_OnInject             (player, item) end,
    ["injectorItems.injector_sj6"]            = function(player, item) Sj6_OnInject             (player, item) end,
    ["injectorItems.injector_sj9"]            = function(player, item) Sj9_OnInject             (player, item) end,
    ["injectorItems.injector_sj12"]           = function(player, item) Sj12_OnInject            (player, item) end,
    ["injectorItems.injector_trimadol"]       = function(player, item) Trimadol_OnInject        (player, item) end,
    ["injectorItems.injector_xtg"]            = function(player, item) Xtg_OnInject             (player, item) end,
    ["injectorItems.injector_zagustin"]       = function(player, item) Zagustin_OnInject        (player, item) end,
}

local function ContextMenuFill(playerNum, context, items)
    local items = ISInventoryPane.getActualItems(items)
    local player = getSpecificPlayer(playerNum)

    for _, item in ipairs(items) do
        local action = InjectorBinds[item:getFullType()]
        if action then
            context:addOption(getText('IGUI_InjectPrompt'), player, function() action(player, item) end)
            return
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ContextMenuFill)