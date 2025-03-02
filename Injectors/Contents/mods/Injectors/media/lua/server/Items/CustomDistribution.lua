AllowedSpawns = {
    ["Adrenaline"]      = false,
    ["Ahf1"]            = false,
    ["Btg2a2"]          = false,
    ["Btg3"]            = false,
    ["Etg"]             = false,
    ["Meldonin"]        = false,
    ["Morphine"]        = false,
    ["Mule"]            = false,
    ["Norepinephrine"]  = false,
    ["Obdolbos"]        = false,
    ["Obdolbos2"]       = false,
    ["P22"]             = false,
    ["Perfotoran"]      = false,
    ["Pnb"]             = false,
    ["Propital"]        = false,
    ["Sj1"]             = false,
    ["Sj6"]             = false,
    ["Sj9"]             = false,
    ["Sj12"]            = false,
    ["Trimadol"]        = false,
    ["Xtg"]             = false,
    ["Zagustin"]        = false
}

SpawnChances = {
    ["Adrenaline"]      = 0.0,
    ["Ahf1"]            = 0.0,
    ["Btg2a2"]          = 0.0,
    ["Btg3"]            = 0.0,
    ["Etg"]             = 0.0,
    ["Meldonin"]        = 0.0,
    ["Morphine"]        = 0.0,
    ["Mule"]            = 0.0,
    ["Norepinephrine"]  = 0.0,
    ["Obdolbos"]        = 0.0,
    ["Obdolbos2"]       = 0.0,
    ["P22"]             = 0.0,
    ["Perfotoran"]      = 0.0,
    ["Pnb"]             = 0.0,
    ["Propital"]        = 0.0,
    ["Sj1"]             = 0.0,
    ["Sj6"]             = 0.0,
    ["Sj9"]             = 0.0,
    ["Sj12"]            = 0.0,
    ["Trimadol"]        = 0.0,
    ["Xtg"]             = 0.0,
    ["Zagustin"]        = 0.0
}

local function contains(table, value)
    for i = 1, #table do
      if (table[i] == value) then
        return true
      end
    end
    return false
end

SpawnRooms = {}

local function getItems()
    local possibleItems = {}
    local actualItems = {}

    local function addItem(condition, itemType, chance)
        if condition then
            local roll = ZombRand(10001) / 100
            if roll < chance then
                return table.insert(possibleItems, itemType)
            end
        end
    end

    for _ = 1, SandboxVars.Injectors.RollCount or 0 do
        addItem(AllowedSpawns["Adrenaline"],     "injectorItems.injector_adrenaline",     SpawnChances["Adrenaline"])
        addItem(AllowedSpawns["Ahf1"],           "injectorItems.injector_ahf1",           SpawnChances["Ahf1"])
        addItem(AllowedSpawns["Btg2a2"],         "injectorItems.injector_btg2a2",         SpawnChances["Btg2a2"])
        addItem(AllowedSpawns["Btg3"],           "injectorItems.injector_btg3",           SpawnChances["Btg3"])
        addItem(AllowedSpawns["Etg"],            "injectorItems.injector_etg",            SpawnChances["Etg"])
        addItem(AllowedSpawns["Meldonin"],       "injectorItems.injector_meldonin",       SpawnChances["Meldonin"])
        addItem(AllowedSpawns["Morphine"],       "injectorItems.injector_morphine",       SpawnChances["Morphine"])
        addItem(AllowedSpawns["Mule"],           "injectorItems.injector_mule",           SpawnChances["Mule"])
        addItem(AllowedSpawns["Norepinephrine"], "injectorItems.injector_norepinephrine", SpawnChances["Norepinephrine"])
        addItem(AllowedSpawns["Obdolbos"],       "injectorItems.injector_obdolbos",       SpawnChances["Obdolbos"])
        addItem(AllowedSpawns["Obdolbos2"],      "injectorItems.injector_obdolbos2",      SpawnChances["Obdolbos2"])
        addItem(AllowedSpawns["P22"],            "injectorItems.injector_p22",            SpawnChances["P22"])
        addItem(AllowedSpawns["Perfotoran"],     "injectorItems.injector_perfotoran",     SpawnChances["Perfotoran"])
        addItem(AllowedSpawns["Pnb"],            "injectorItems.injector_pnb",            SpawnChances["Pnb"])
        addItem(AllowedSpawns["Propital"],       "injectorItems.injector_propital",       SpawnChances["Propital"])
        addItem(AllowedSpawns["Sj1"],            "injectorItems.injector_sj1",            SpawnChances["Sj1"])
        addItem(AllowedSpawns["Sj6"],            "injectorItems.injector_sj6",            SpawnChances["Sj6"])
        addItem(AllowedSpawns["Sj9"],            "injectorItems.injector_sj9",            SpawnChances["Sj9"])
        addItem(AllowedSpawns["Sj12"],           "injectorItems.injector_sj12",           SpawnChances["Sj12"])
        addItem(AllowedSpawns["Trimadol"],       "injectorItems.injector_trimadol",       SpawnChances["Trimadol"])
        addItem(AllowedSpawns["Xtg"],            "injectorItems.injector_xtg",            SpawnChances["Xtg"])
        addItem(AllowedSpawns["Zagustin"],       "injectorItems.injector_zagustin",       SpawnChances["Zagustin"])
        
        table.insert(actualItems, possibleItems[ZombRand(#possibleItems)+1])
    end
    return actualItems
end

---@param roomType string
---@param containerType string
---@param container ItemContainer
local function OnFillContainer(roomType, containerType, container)
    if contains(SpawnRooms, roomType) then
        local items = getItems()
        for _, item in ipairs(items) do
            container:AddItem(item)
        end
    end
end

Events.OnFillContainer.Add(OnFillContainer)

function InitSpawnRooms()
    AllowedSpawns["Adrenaline"]     = SandboxVars.Injectors.AllowAdrenaline      or false
    AllowedSpawns["Ahf1"]           = SandboxVars.Injectors.AllowAhf1            or false
    AllowedSpawns["Btg2a2"]         = SandboxVars.Injectors.AllowBtg2a2          or false
    AllowedSpawns["Btg3"]           = SandboxVars.Injectors.AllowBtg3            or false
    AllowedSpawns["Etg"]            = SandboxVars.Injectors.AllowEtg             or false
    AllowedSpawns["Meldonin"]       = SandboxVars.Injectors.AllowMeldonin        or false
    AllowedSpawns["Morphine"]       = SandboxVars.Injectors.AllowMorphine        or false
    AllowedSpawns["Mule"]           = SandboxVars.Injectors.AllowMule            or false
    AllowedSpawns["Norepinephrine"] = SandboxVars.Injectors.AllowNorepinephrine  or false
    AllowedSpawns["Obdolbos"]       = SandboxVars.Injectors.AllowObdolbos        or false
    AllowedSpawns["Obdolbos2"]      = SandboxVars.Injectors.AllowObdolbos2       or false
    AllowedSpawns["P22"]            = SandboxVars.Injectors.AllowP22             or false
    AllowedSpawns["Perfotoran"]     = SandboxVars.Injectors.AllowPerfotoran      or false
    AllowedSpawns["Pnb"]            = SandboxVars.Injectors.AllowPnb             or false
    AllowedSpawns["Propital"]       = SandboxVars.Injectors.AllowPropital        or false
    AllowedSpawns["Sj1"]            = SandboxVars.Injectors.AllowSj1             or false
    AllowedSpawns["Sj6"]            = SandboxVars.Injectors.AllowSj6             or false
    AllowedSpawns["Sj9"]            = SandboxVars.Injectors.AllowSj9             or false
    AllowedSpawns["Sj12"]           = SandboxVars.Injectors.AllowSj12            or false
    AllowedSpawns["Trimadol"]       = SandboxVars.Injectors.AllowTrimadol        or false
    AllowedSpawns["Xtg"]            = SandboxVars.Injectors.AllowXtg             or false
    AllowedSpawns["Zagustin"]       = SandboxVars.Injectors.AllowZagustin        or false

    SpawnChances["Adrenaline"]      = SandboxVars.Injectors.AdrenalineChance     or 0.0
    SpawnChances["Ahf1"]            = SandboxVars.Injectors.Ahf1Chance           or 0.0
    SpawnChances["Btg2a2"]          = SandboxVars.Injectors.Btg2a2Chance         or 0.0
    SpawnChances["Btg3"]            = SandboxVars.Injectors.Btg3Chance           or 0.0
    SpawnChances["Etg"]             = SandboxVars.Injectors.EtgChance            or 0.0
    SpawnChances["Meldonin"]        = SandboxVars.Injectors.MeldoninChance       or 0.0
    SpawnChances["Morphine"]        = SandboxVars.Injectors.MorphineChance       or 0.0
    SpawnChances["Mule"]            = SandboxVars.Injectors.MuleChance           or 0.0
    SpawnChances["Norepinephrine"]  = SandboxVars.Injectors.NorepinephrineChance or 0.0
    SpawnChances["Obdolbos"]        = SandboxVars.Injectors.ObdolbosChance       or 0.0
    SpawnChances["Obdolbos2"]       = SandboxVars.Injectors.Obdolbos2Chance      or 0.0
    SpawnChances["P22"]             = SandboxVars.Injectors.P22Chance            or 0.0
    SpawnChances["Perfotoran"]      = SandboxVars.Injectors.PerfotoranChance     or 0.0
    SpawnChances["Pnb"]             = SandboxVars.Injectors.PnbChance            or 0.0
    SpawnChances["Propital"]        = SandboxVars.Injectors.PropitalChance       or 0.0
    SpawnChances["Sj1"]             = SandboxVars.Injectors.Sj1Chance            or 0.0
    SpawnChances["Sj6"]             = SandboxVars.Injectors.Sj6Chance            or 0.0
    SpawnChances["Sj9"]             = SandboxVars.Injectors.Sj9Chance            or 0.0
    SpawnChances["Sj12"]            = SandboxVars.Injectors.Sj12Chance           or 0.0
    SpawnChances["Trimadol"]        = SandboxVars.Injectors.TrimadolChance       or 0.0
    SpawnChances["Xtg"]             = SandboxVars.Injectors.XtgChance            or 0.0
    SpawnChances["Zagustin"]        = SandboxVars.Injectors.ZagustinChance       or 0.0

    for word in string.gmatch(SandboxVars.Injectors.SpawnRooms or '', "[^;]+") do
        word = word:match("^%s*(.-)%s*$")
        table.insert(SpawnRooms, word)
    end
end

function InitSpawnRoomsSP()
    if not isClient() and not isServer() then
        InitSpawnRooms()
    end
end

Events.OnServerStarted.Add(InitSpawnRooms)
Events.OnGameStart.Add(InitSpawnRoomsSP)