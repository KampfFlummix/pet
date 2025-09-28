-- =============================================================================
-- FEATURE PET QUALITY SYSTEM
-- Quality-Wechsel mit Item von 1-8
-- =============================================================================

dofile("lib/feature_pet_system.lua")

function UseQualitySwitchItem(playerID, targetPetID, newQuality)
    local pet = db.query("SELECT * FROM feature_pets WHERE id = " .. targetPetID .. " AND owner_id = " .. playerID)[1]
    if not pet then
        pc.say(playerID, "Pet nicht gefunden!")
        return false
    end
    
    if newQuality < 1 or newQuality > FEATURE_PET_CONFIG.MAX_QUALITY then
        pc.say(playerID, "Ungültige Quality-Stufe!")
        return false
    end
    
    if pet.quality_level == newQuality then
        pc.say(playerID, "Das Pet hat bereits diese Quality-Stufe!")
        return false
    end
    
    -- Quality ändern
    local oldQuality = pet.quality_level
    local success = SwitchPetQuality(playerID, targetPetID, newQuality)
    
    if success then
        local qualityNames = {"Schlecht", "Mäßig", "Durchschnittlich", "Gut", "Sehr Gut", "Exzellent", "Perfekt", "Legendär"}
        pc.say(playerID, string.format("✨ Quality geändert: %s → %s", qualityNames[oldQuality], qualityNames[newQuality]))
        return true
    else
        pc.say(playerID, "Fehler beim Quality-Wechsel!")
        return false
    end
end

function SwitchPetQuality(playerID, petID, newQuality)
    local pet = db.query("SELECT * FROM feature_pets WHERE id = " .. petID .. " AND owner_id = " .. playerID)[1]
    if not pet then return false end
    
    -- Alten Quality-Multiplikator
    local oldMultiplier = FEATURE_PET_CONFIG.QUALITY_MULTIPLIER[pet.quality_level] or 1.0
    local newMultiplier = FEATURE_PET_CONFIG.QUALITY_MULTIPLIER[newQuality] or 1.0
    
    -- Skills anpassen
    local skills = db.query("SELECT id, base_value FROM feature_pet_skills WHERE pet_id = " .. petID)
    for _, skill in ipairs(skills) do
        -- Basiswert ohne alten Multiplikator berechnen
        local baseValueWithoutMultiplier = skill.base_value / oldMultiplier
        -- Neuen Basiswert mit neuem Multiplikator
        local newBaseValue = math.floor(baseValueWithoutMultiplier * newMultiplier)
        db.execute("UPDATE feature_pet_skills SET base_value = " .. newBaseValue .. " WHERE id = " .. skill.id)
    end
    
    -- Quality in DB updaten
    db.execute("UPDATE feature_pets SET quality_level = " .. newQuality .. " WHERE id = " .. petID)
    
    return true
end

function GetQualityDisplayName(qualityLevel)
    local names = {
        [1] = "Schlecht",
        [2] = "Mäßig", 
        [3] = "Durchschnittlich",
        [4] = "Gut",
        [5] = "Sehr Gut",
        [6] = "Exzellent",
        [7] = "Perfekt",
        [8] = "Legendär"
    }
    return names[qualityLevel] or "Unbekannt"
end

return {
    UseQualitySwitchItem = UseQualitySwitchItem,
    SwitchPetQuality = SwitchPetQuality,
    GetQualityDisplayName = GetQualityDisplayName
}