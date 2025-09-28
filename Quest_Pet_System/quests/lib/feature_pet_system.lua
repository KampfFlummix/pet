-- =============================================================================
-- FEATURE PET SYSTEM - HAUPTMODUL
-- Komplett ohne Server Source Code - Nur Lua + MySQL
-- =============================================================================

-- Konfiguration
FEATURE_PET_CONFIG = {
    -- System Einstellungen
    MAX_LEVEL = 120,
    EVOLUTION_LEVELS = {30, 60, 90, 120},
    MAX_QUALITY = 8,
    MAX_ACTIVE_PETS = 1,
    SKILL_SLOTS = 3,
    
    -- XP System
    BASE_XP_MULTIPLIER = 100,
    XP_FORMULA = function(lvl) return math.floor(100 * lvl^1.5) end,
    
    -- Scaling
    LEVEL_SCALING = 2.0, -- Bis zu 300% Bonus durch Level
    EVOLUTION_BONUS = 0.15, -- 15% Bonus pro Evolution
    
    -- Quality Multiplikator
    QUALITY_MULTIPLIER = {
        [1] = 0.5, [2] = 0.65, [3] = 0.8, [4] = 1.0,
        [5] = 1.2, [6] = 1.5, [7] = 1.75, [8] = 2.0
    }
}

-- XP Tabelle vorberechnen
FeaturePetXP = {}
for lvl = 1, FEATURE_PET_CONFIG.MAX_LEVEL do
    FeaturePetXP[lvl] = FEATURE_PET_CONFIG.XP_FORMULA(lvl)
end

-- Skill Types (Angepasst an deinen Server)
SKILL_TYPES = {
    -- Attribute (7)
    "STAT_STR", "STAT_DEX", "STAT_INT", "STAT_AW", "STAT_VIT", "STAT_TP", "STAT_DEF",
    
    -- PvM Damage (6)
    "PVM_MOB_DMG", "PVM_BOSS_DMG", "PVM_METIN_DMG", "PVM_HALBMENSCH_DMG", 
    "PVM_UNDEAD_DMG", "PVM_DEVIL_DMG",
    
    -- PvM Resist (7)
    "RESIST_MOB", "RESIST_BOSS", "RESIST_METIN", "RESIST_HALBMENSCH",
    "RESIST_UNDEAD", "RESIST_DEVIL", "RESIST_WHITE_TAU",
    
    -- Drop/XP (3)
    "DROP_YANG", "DROP_ITEM", "DROP_EXP",
    
    -- PvP Damage (4)
    "PVP_DMG_WARRIOR", "PVP_DMG_NINJA", "PVP_DMG_SURA", "PVP_DMG_SHAMAN",
    
    -- PvP Resist (4)
    "PVP_RES_WARRIOR", "PVP_RES_NINJA", "PVP_RES_SURA", "PVP_RES_SHAMAN"
}

-- =============================================================================
-- KERN FUNKTIONEN
-- =============================================================================

function GetXPForLevel(level)
    return FeaturePetXP[level] or 999999999
end

function GetPetBonus(playerID, bonusType)
    local query = db.query("SELECT * FROM feature_pets WHERE owner_id = " .. playerID .. " AND is_active = 1")
    if not query or #query == 0 then return 0 end
    
    local pet = query[1]
    local skillQuery = db.query("SELECT base_value FROM feature_pet_skills WHERE pet_id = " .. pet.id .. " AND skill_type = '" .. bonusType .. "'")
    if not skillQuery or #skillQuery == 0 then return 0 end
    
    local skill = skillQuery[1]
    
    -- ✅ FAIRE SKALIERUNG: Für alle Pets gleich!
    local levelBonus = 1 + (pet.level / FEATURE_PET_CONFIG.MAX_LEVEL) * FEATURE_PET_CONFIG.LEVEL_SCALING
    local evolutionBonus = 1 + (pet.evolution_stage * FEATURE_PET_CONFIG.EVOLUTION_BONUS)
    
    local totalBonus = skill.base_value * levelBonus * evolutionBonus
    return math.floor(totalBonus * 100) / 100
end

function AddPetXP(playerID, petID, xpGain)
    local query = db.query("SELECT * FROM feature_pets WHERE id = " .. petID .. " AND owner_id = " .. playerID)
    if not query or #query == 0 then return false end
    
    local pet = query[1]
    local newXP = pet.xp + xpGain
    local newLevel = pet.level
    local leveledUp = false
    
    -- Level-Up Check
    while newLevel < FEATURE_PET_CONFIG.MAX_LEVEL and newXP >= GetXPForLevel(newLevel) do
        newXP = newXP - GetXPForLevel(newLevel)
        newLevel = newLevel + 1
        leveledUp = true
        
        -- Evolution Check
        local newEvolution = 0
        for _, evoLevel in ipairs(FEATURE_PET_CONFIG.EVOLUTION_LEVELS) do
            if newLevel >= evoLevel then newEvolution = newEvolution + 1 end
        end
        
        if newEvolution > pet.evolution_stage then
            db.execute("UPDATE feature_pets SET evolution_stage = " .. newEvolution .. " WHERE id = " .. petID)
            -- Evolution Event auslösen
            TriggerPetEvolution(playerID, petID, newEvolution)
        end
    end
    
    if leveledUp then
        db.execute("UPDATE feature_pets SET level = " .. newLevel .. ", xp = " .. newXP .. " WHERE id = " .. petID)
        ScalePetSkills(petID, newLevel)
        TriggerPetLevelUp(playerID, petID, newLevel)
        return true
    else
        db.execute("UPDATE feature_pets SET xp = " .. newXP .. " WHERE id = " .. petID)
        return false
    end
end

function ScalePetSkills(petID, newLevel)
    local skills = db.query("SELECT id, base_value, skill_type FROM feature_pet_skills WHERE pet_id = " .. petID)
    for _, skill in ipairs(skills) do
        local scaleFactor = GetSkillScaleFactor(skill.skill_type)
        local newValue = math.floor(skill.base_value * (1 + (newLevel * scaleFactor / 100)))
        db.execute("UPDATE feature_pet_skills SET base_value = " .. newValue .. " WHERE id = " .. skill.id)
    end
end

function GetSkillScaleFactor(skillType)
    -- Unterschiedliche Skalierung je nach Skill-Typ
    if skillType:find("DROP_") then return 0.05 end
    if skillType:find("PVP_") then return 0.08 end
    if skillType:find("STAT_") then return 0.1 end
    return 0.07 -- Standard
end

function GetPetByID(petID)
    local query = db.query("SELECT * FROM feature_pets WHERE id = " .. petID)
    if query and #query > 0 then return query[1] end
    return nil
end

function DeactivatePet(playerID)
    db.execute("UPDATE feature_pets SET is_active = 0 WHERE owner_id = " .. playerID)
    return true
end

function GetPetSkills(petID)
    return db.query("SELECT * FROM feature_pet_skills WHERE pet_id = " .. petID)
end

function GetTotalSkillValue(petID)
    local skills = db.query("SELECT base_value FROM feature_pet_skills WHERE pet_id = " .. petID)
    local total = 0
    for _, skill in ipairs(skills) do
        total = total + skill.base_value
    end
    return total
end
-- =============================================================================
-- PET MANAGEMENT
-- =============================================================================

function ActivatePet(playerID, petID)
    -- Alle Pets deaktivieren
    db.execute("UPDATE feature_pets SET is_active = 0 WHERE owner_id = " .. playerID)
    -- Gewünschtes Pet aktivieren
    db.execute("UPDATE feature_pets SET is_active = 1 WHERE id = " .. petID .. " AND owner_id = " .. playerID)
    return true
end

function GetActivePet(playerID)
    local query = db.query("SELECT * FROM feature_pets WHERE owner_id = " .. playerID .. " AND is_active = 1")
    if query and #query > 0 then return query[1] end
    return nil
end

function CreateNewPet(playerID, petVnum, name, quality)
    db.execute("INSERT INTO feature_pets (owner_id, pet_vnum, name, quality_level) VALUES (" .. playerID .. ", " .. petVnum .. ", '" .. name .. "', " .. quality .. ")")
    local result = db.query("SELECT LAST_INSERT_ID() as id")
    if result and #result > 0 then return result[1].id end
    return nil
end

function GetPlayerPets(playerID)
    return db.query("SELECT * FROM feature_pets WHERE owner_id = " .. playerID .. " ORDER BY is_active DESC, level DESC")
end

-- =============================================================================
-- EVENT HANDLER
-- =============================================================================

function TriggerPetEvolution(playerID, petID, evolutionStage)
    local pet = db.query("SELECT name FROM feature_pets WHERE id = " .. petID)[1]
    if pet then
        pc.say(playerID, "✨ " .. pet.name .. " hat Evolutionsstufe " .. evolutionStage .. " erreicht!")
        
        -- Spezial-Bonus bei Evolution
        if evolutionStage == 4 then -- Max Evolution
            GrantUltraEvolutionBonus(playerID, petID)
        end
    end
end

function TriggerPetLevelUp(playerID, petID, newLevel)
    local pet = db.query("SELECT name FROM feature_pets WHERE id = " .. petID)[1]
    if pet and newLevel % 10 == 0 then -- Jedes 10. Level
        pc.say(playerID, "🎉 " .. pet.name .. " hat Level " .. newLevel .. " erreicht!")
    end
end

function GrantUltraEvolutionBonus(playerID, petID)
    -- Ultra Evolution Bonus: +10% auf alle Stats
    local skills = db.query("SELECT id, base_value FROM feature_pet_skills WHERE pet_id = " .. petID)
    for _, skill in ipairs(skills) do
        local newValue = math.floor(skill.base_value * 1.1)
        db.execute("UPDATE feature_pet_skills SET base_value = " .. newValue .. " WHERE id = " .. skill.id)
    end
    pc.say(playerID, "🌟 Ultra Evolution abgeschlossen! Alle Stats +10%!")
end

-- =============================================================================
-- INITIALISIERUNG
-- =============================================================================

function InitializePetSystem()
    say("✅ Feature Pet System geladen!")
    say("📊 Konfiguration: Level " .. FEATURE_PET_CONFIG.MAX_LEVEL .. ", " .. #SKILL_TYPES .. " Skill-Types")
    return true
end

-- System initialisieren
InitializePetSystem()

return {
    -- Konfiguration
    config = FEATURE_PET_CONFIG,
    skillTypes = SKILL_TYPES,
    
    -- Kern Funktionen
    GetXPForLevel = GetXPForLevel,
    GetPetBonus = GetPetBonus,
    AddPetXP = AddPetXP,
    ScalePetSkills = ScalePetSkills,
    GetSkillScaleFactor = GetSkillScaleFactor,
    
    -- Pet Management
    ActivatePet = ActivatePet,
    GetActivePet = GetActivePet,
    CreateNewPet = CreateNewPet,
    GetPlayerPets = GetPlayerPets,
    GetPetByID = GetPetByID,
    DeactivatePet = DeactivatePet,
    GetPetSkills = GetPetSkills,
    GetTotalSkillValue = GetTotalSkillValue,
    
    -- Events
    TriggerPetEvolution = TriggerPetEvolution,
    TriggerPetLevelUp = TriggerPetLevelUp
    GrantUltraEvolutionBonus = GrantUltraEvolutionBonus
}
