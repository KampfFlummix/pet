-- =============================================================================
-- FEATURE PET DNA SYSTEM
-- DNA-Proben von Bossen für Spezial-Fähigkeiten
-- =============================================================================

dofile("lib/feature_pet_system.lua")

-- DNA-Typen und ihre Effekte
DNA_TYPES = {
    METIN = {
        name = "Metinstein-DNA",
        effect = "Chance auf doppelten Metin-Drop",
        max_level = 5,
        bonus_per_level = 2 -- +2% Chance pro Level
    },
    BOSS = {
        name = "Boss-Seele", 
        effect = "Bonus Schaden vs Bosse",
        max_level = 5,
        bonus_per_level = 5 -- +5% Schaden pro Level
    },
    PVP = {
        name = "PvP-Energie",
        effect = "Reflektiert PvP-Schaden",
        max_level = 3, 
        bonus_per_level = 3 -- +3% Reflekt pro Level
    },
    YANG = {
        name = "Goldene Aura",
        effect = "Erhöht Yang Drop",
        max_level = 5,
        bonus_per_level = 10 -- +10% Yang pro Level
    },
    SOUL_EATER = {
        name = "Seelenfresser-DNA",
        effect = "Heilung bei Monster-Kill",
        max_level = 3,
        bonus_per_level = 2 -- +2% Heilung pro Level
    }
}

-- DNA-Items die von Bossen droppen
DNA_ITEMS = {
    [1005100] = "METIN",
    [1005101] = "BOSS", 
    [1005102] = "PVP",
    [1005103] = "YANG",
    [1005104] = "SOUL_EATER"
}

function UseDNAItem(playerID, itemVnum)
    local dnaType = DNA_ITEMS[itemVnum]
    if not dnaType then return false end
    
    local activePet = GetActivePet(playerID)
    if not activePet then
        pc.say(playerID, "Du musst ein aktives Pet haben um DNA zu verwenden!")
        return false
    end
    
    -- Prüfen ob DNA-Typ bereits vorhanden
    local existingDNA = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. activePet.id .. " AND dna_type = '" .. dnaType .. "'")
    
    if existingDNA and #existingDNA > 0 then
        -- DNA-Level erhöhen
        local currentDNA = existingDNA[1]
        local dnaInfo = DNA_TYPES[dnaType]
        
        if currentDNA.dna_level >= dnaInfo.max_level then
            pc.say(playerID, dnaInfo.name .. " hat bereits maximales Level erreicht!")
            return false
        end
        
        local newLevel = currentDNA.dna_level + 1
        db.execute("UPDATE feature_pet_dna SET dna_level = " .. newLevel .. " WHERE id = " .. currentDNA.id)
        pc.say(playerID, "✨ " .. dnaInfo.name .. " auf Level " .. newLevel .. " verbessert!")
        
    else
        -- Neue DNA hinzufügen
        db.execute("INSERT INTO feature_pet_dna (pet_id, dna_type, dna_level) VALUES (" .. activePet.id .. ", '" .. dnaType .. "', 1)")
        pc.say(playerID, "🧬 " .. DNA_TYPES[dnaType].name .. " hinzugefügt!")
    end
    
    return true
end

function GetDNABonus(petID, bonusType)
    local dnaEntries = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. petID)
    local totalBonus = 0
    
    for _, dna in ipairs(dnaEntries) do
        local dnaInfo = DNA_TYPES[dna.dna_type]
        if dnaInfo then
            if bonusType == "DROP_ITEM" and dna.dna_type == "METIN" then
                totalBonus = totalBonus + (dna.dna_level * dnaInfo.bonus_per_level)
            elseif bonusType == "PVM_BOSS_DMG" and dna.dna_type == "BOSS" then
                totalBonus = totalBonus + (dna.dna_level * dnaInfo.bonus_per_level)
            elseif bonusType == "PVP_REFLECT" and dna.dna_type == "PVP" then
                totalBonus = totalBonus + (dna.dna_level * dnaInfo.bonus_per_level)
            elseif bonusType == "DROP_YANG" and dna.dna_type == "YANG" then
                totalBonus = totalBonus + (dna.dna_level * dnaInfo.bonus_per_level)
            end
        end
    end
    
    return totalBonus
end

-- Spezial-Effekt: Seelenfresser DNA
function ApplySoulEaterEffect(playerID, monsterID)
    local activePet = GetActivePet(playerID)
    if not activePet then return end
    
    local soulEaterDNA = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. activePet.id .. " AND dna_type = 'SOUL_EATER'")
    if not soulEaterDNA or #soulEaterDNA == 0 then return end
    
    local dna = soulEaterDNA[1]
    local healAmount = activePet.level * (dna.dna_level * 2) -- Level * DNA-Level * 2
    
    -- Spieler heilen
    pc.heal(playerID, healAmount)
    pc.say(playerID, "🩸 Seelenfresser heilt " .. healAmount .. " LP!")
end

function GetPetDNAInfo(petID)
    return db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. petID)
end

return {
    UseDNAItem = UseDNAItem,
    GetDNABonus = GetDNABonus,
    ApplySoulEaterEffect = ApplySoulEaterEffect,
    GetPetDNAInfo = GetPetDNAInfo,
    DNA_TYPES = DNA_TYPES
}