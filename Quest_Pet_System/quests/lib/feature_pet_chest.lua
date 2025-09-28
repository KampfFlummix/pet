-- =============================================================================
-- FEATURE PET CHEST SYSTEM
-- 10 verschiedene Pets random aus Truhe + Quality 1-8
-- =============================================================================

dofile("lib/feature_pet_system.lua")

-- Deine 10 Feature Pets
FEATURE_PETS = {
    [5001] = {name = "Drachenkrieger", base_power = 10, element = "Feuer"},
    [5002] = {name = "Eisphönix", base_power = 9, element = "Eis"},
    [5003] = {name = "Dunkelwolf", base_power = 8, element = "Dunkelheit"},
    [5004] = {name = "Lichtgeist", base_power = 7, element = "Licht"},
    [5005] = {name = "Steingolem", base_power = 10, element = "Erde"},
    [5006] = {name = "Blitzdrache", base_power = 9, element = "Blitz"},
    [5007] = {name = "Feuerteufel", base_power = 8, element = "Inferno"},
    [5008] = {name = "Wassernixe", base_power = 7, element = "Wasser"},
    [5009] = {name = "Windfalke", base_power = 6, element = "Wind"},
    [5010] = {name = "Erddämon", base_power = 10, element = "Vulkan"}
}

function UseFeaturePetChest(playerID)
    local player = pc.get(playerID)
    if not player then return false end
    
    -- Random Pet auswählen
    local petKeys = {}
    for k, _ in pairs(FEATURE_PETS) do table.insert(petKeys, k) end
    local randomKey = petKeys[math.random(1, #petKeys)]
    local selectedPet = FEATURE_PETS[randomKey]
    
    -- Random Quality 1-8
    local quality = math.random(1, 8)
    
    -- Pet in DB erstellen
    local petID = CreateNewPet(playerID, randomKey, selectedPet.name, quality)
    if not petID then
        pc.say(playerID, "Fehler beim Erstellen des Pets!")
        return false
    end
    
    -- Erfolgsmeldung mit Quality
    local qualityNames = {"Schlecht", "Mäßig", "Durchschnittlich", "Gut", "Sehr Gut", "Exzellent", "Perfekt", "Legendär"}
    pc.say(playerID, string.format("🎁 Du hast %s (Qualität: %s) erhalten!", selectedPet.name, qualityNames[quality]))
    
    -- Skill-Auswahl starten
    StartSkillSelection(playerID, petID)
    
    return true
end

function GetPetInfo(petVnum)
    return FEATURE_PETS[petVnum] or {name = "Unbekannt", base_power = 5, element = "Normal"}
end

function CalculateBaseSkillValue(slot, quality)
    local baseValues = {15, 10, 8} -- Slot 1, 2, 3 Basiswerte für Quality 4
    local qualityMultiplier = FEATURE_PET_CONFIG.QUALITY_MULTIPLIER[quality] or 1.0
    
    return math.floor(baseValues[slot] * qualityMultiplier)
end

-- Pet Set Boni
PET_SETS = {
    ["Drachentrio"] = {
        pets = {5001, 5004, 5006}, -- Drachenkrieger, Lichtgeist, Blitzdrache
        bonus = {PVM_ALL_DMG = 15, DROP_ITEM = 10},
        description = "Die Macht der Drachen vereint!"
    },
    ["Elementar"] = {
        pets = {5002, 5005, 5007, 5008}, -- Eis, Stein, Feuer, Wasser
        bonus = {STAT_STR = 5, STAT_DEX = 5, STAT_INT = 5, STAT_AW = 5},
        description = "Harmonie der vier Elemente"
    },
    ["Schattenbund"] = {
        pets = {5003, 5009, 5010}, -- Wolf, Falke, Dämon
        bonus = {PVP_ALL_DMG = 20, MOVEMENT_SPEED = 10},
        description = "Jäger der Nacht"
    }
}

function CalculateSetBonus(playerID)
    local playerPets = GetPlayerPets(playerID)
    local totalBonus = {}
    
    for setName, setData in pairs(PET_SETS) do
        local ownedCount = 0
        for _, petVnum in ipairs(setData.pets) do
            if HasPet(playerPets, petVnum) then
                ownedCount = ownedCount + 1
            end
        end
        
        if ownedCount >= 2 then
            -- 2er-Set Bonus (50% des Bonus)
            for bonusType, bonusValue in pairs(setData.bonus) do
                totalBonus[bonusType] = (totalBonus[bonusType] or 0) + math.floor(bonusValue * 0.5)
            end
        end
        
        if ownedCount >= 3 then
            -- 3er-Set Bonus (voll)
            for bonusType, bonusValue in pairs(setData.bonus) do
                totalBonus[bonusType] = (totalBonus[bonusType] or 0) + bonusValue
            end
            pc.say(playerID, "🌟 Set-Bonus aktiviert: " .. setName)
        end
    end
    
    return totalBonus
end

function HasPet(playerPets, petVnum)
    for _, pet in ipairs(playerPets) do
        if pet.pet_vnum == petVnum then
            return true
        end
    end
    return false
end

return {
    UseFeaturePetChest = UseFeaturePetChest,
    GetPetInfo = GetPetInfo,
    CalculateSetBonus = CalculateSetBonus,
    FEATURE_PETS = FEATURE_PETS,
    PET_SETS = PET_SETS
}