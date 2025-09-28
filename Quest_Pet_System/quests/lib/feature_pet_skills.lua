-- =============================================================================
-- FEATURE PET SKILL SELECTION SYSTEM
-- 3 Skills Auswahl nach Pet-Erhalt
-- =============================================================================

dofile("lib/feature_pet_system.lua")

function StartSkillSelection(playerID, petID)
    local player = pc.get(playerID)
    if not player then return false end
    
    -- Pet-Info abrufen
    local pet = db.query("SELECT * FROM feature_pets WHERE id = " .. petID)[1]
    if not pet then return false end
    
    -- Skill-Auswahl-Quest starten
    pc.setqf(playerID, "feature_pet_selection", petID)
    pc.setqf(playerID, "feature_pet_skill_slot", 1)
    
    -- Dialog starten
    ShowSkillSelectionDialog(playerID, 1)
    
    return true
end

function ShowSkillSelectionDialog(playerID, skillSlot)
    local petID = pc.getqf(playerID, "feature_pet_selection")
    if not petID then return end
    
    if skillSlot > FEATURE_PET_CONFIG.SKILL_SLOTS then
        -- Alle Skills gewählt - Pet aktivieren
        CompleteSkillSelection(playerID, petID)
        return
    end
    
    local pet = db.query("SELECT name, quality_level FROM feature_pets WHERE id = " .. petID)[1]
    if not pet then return end
    
    pc.say(playerID, string.format("Wähle Skill #%d für %s (Q%d):", skillSlot, pet.name, pet.quality_level))
    
    -- Skill-Kategorien anzeigen
    local categories = {
        {name = "🏹 PvM Schaden", skills = GetSkillsByCategory("PVM_DMG")},
        {name = "🛡️ PvM Resist", skills = GetSkillsByCategory("PVM_RES")},
        {name = "💎 Attribute", skills = GetSkillsByCategory("STATS")},
        {name = "🎯 PvP Schaden", skills = GetSkillsByCategory("PVP_DMG")},
        {name = "⚔️ PvP Resist", skills = GetSkillsByCategory("PVP_RES")},
        {name = "💰 Drops/XP", skills = GetSkillsByCategory("DROPS")}
    }
    
    for i, category in ipairs(categories) do
        select(i, category.name)
    end
    
    -- Selection Handler
    when select with pc.getqf(playerID, "feature_pet_selection") ~= 0 do
        local categoryIndex = tonumber(input)
        local category = categories[categoryIndex]
        
        if category then
            ShowSkillsInCategory(playerID, category.skills, skillSlot)
        end
    end
end

function ShowSkillsInCategory(playerID, skills, skillSlot)
    pc.say(playerID, "Wähle einen Skill:")
    
    for i, skillType in ipairs(skills) do
        local skillName = GetSkillDisplayName(skillType)
        select(i, skillName)
    end
    
    select(#skills + 1, "⬅️ Zurück")
    
    when select with pc.getqf(playerID, "feature_pet_selection") ~= 0 do
        local choice = tonumber(input)
        
        if choice == #skills + 1 then
            -- Zurück zur Kategorie-Auswahl
            ShowSkillSelectionDialog(playerID, skillSlot)
        elseif skills[choice] then
            -- Skill ausgewählt
            SaveSelectedSkill(playerID, skills[choice], skillSlot)
            ShowSkillSelectionDialog(playerID, skillSlot + 1)
        end
    end
end

function SaveSelectedSkill(playerID, skillType, slot)
    local petID = pc.getqf(playerID, "feature_pet_selection")
    if not petID then return false end
    
    local pet = db.query("SELECT quality_level FROM feature_pets WHERE id = " .. petID)[1]
    if not pet then return false end
    
    local baseValue = CalculateBaseSkillValue(slot, pet.quality_level)
    
    -- Skill in DB speichern
    db.execute("INSERT INTO feature_pet_skills (pet_id, skill_type, base_value) VALUES (" .. petID .. ", '" .. skillType .. "', " .. baseValue .. ")")
    
    pc.say(playerID, "✅ Skill gespeichert: " .. GetSkillDisplayName(skillType) .. " (" .. baseValue .. "%)")
    return true
end

function CompleteSkillSelection(playerID, petID)
    -- Pet aktivieren
    ActivatePet(playerID, petID)
    
    local pet = db.query("SELECT name FROM feature_pets WHERE id = " .. petID)[1]
    if pet then
        pc.say(playerID, "🎉 " .. pet.name .. " ist jetzt aktiv! Viel Spaß!")
    end
    
    -- Quest-Flags zurücksetzen
    pc.setqf(playerID, "feature_pet_selection", 0)
    pc.setqf(playerID, "feature_pet_skill_slot", 0)
end

function GetSkillsByCategory(category)
    local categories = {
        PVM_DMG = {"PVM_MOB_DMG", "PVM_BOSS_DMG", "PVM_METIN_DMG", "PVM_HALBMENSCH_DMG", "PVM_UNDEAD_DMG", "PVM_DEVIL_DMG"},
        PVM_RES = {"RESIST_MOB", "RESIST_BOSS", "RESIST_METIN", "RESIST_HALBMENSCH", "RESIST_UNDEAD", "RESIST_DEVIL", "RESIST_WHITE_TAU"},
        STATS = {"STAT_STR", "STAT_DEX", "STAT_INT", "STAT_AW", "STAT_VIT", "STAT_TP", "STAT_DEF"},
        PVP_DMG = {"PVP_DMG_WARRIOR", "PVP_DMG_NINJA", "PVP_DMG_SURA", "PVP_DMG_SHAMAN"},
        PVP_RES = {"PVP_RES_WARRIOR", "PVP_RES_NINJA", "PVP_RES_SURA", "PVP_RES_SHAMAN"},
        DROPS = {"DROP_YANG", "DROP_ITEM", "DROP_EXP"}
    }
    
    return categories[category] or {}
end

function GetSkillDisplayName(skillType)
    local names = {
        -- Attribute
        STAT_STR = "💪 Stärke",
        STAT_DEX = "🎯 Geschicklichkeit", 
        STAT_INT = "🧠 Intelligenz",
        STAT_AW = "⚔️ Angriffswert",
        STAT_VIT = "❤️ Vitalität",
        STAT_TP = "🎯 Trefferpunkte",
        STAT_DEF = "🛡️ Verteidigung",
        
        -- PvM Damage
        PVM_MOB_DMG = "🏹 Schaden vs Monster",
        PVM_BOSS_DMG = "👑 Schaden vs Bosse",
        PVM_METIN_DMG = "💎 Schaden vs Metinsteine",
        PVM_HALBMENSCH_DMG = "🧝 Schaden vs Halbmenschen",
        PVM_UNDEAD_DMG = "☠️ Schaden vs Untote",
        PVM_DEVIL_DMG = "😈 Schaden vs Teufel",
        
        -- PvM Resist
        RESIST_MOB = "🛡️ Resist vs Monster",
        RESIST_BOSS = "👑 Resist vs Bosse", 
        RESIST_METIN = "💎 Resist vs Metinsteine",
        RESIST_HALBMENSCH = "🧝 Resist vs Halbmenschen",
        RESIST_UNDEAD = "☠️ Resist vs Untote",
        RESIST_DEVIL = "😈 Resist vs Teufel",
        RESIST_WHITE_TAU = "❄️ Weißer Tau Resist",
        
        -- Drops
        DROP_YANG = "💰 Yang Drop",
        DROP_ITEM = "🎁 Item Drop", 
        DROP_EXP = "⭐ EXP Bonus",
        
        -- PvP Damage
        PVP_DMG_WARRIOR = "⚔️ Schaden vs Krieger",
        PVP_DMG_NINJA = "🥷 Schaden vs Ninja",
        PVP_DMG_SURA = "🔮 Schaden vs Sura", 
        PVP_DMG_SHAMAN = "🍃 Schaden vs Schamane",
        
        -- PvP Resist
        PVP_RES_WARRIOR = "⚔️ Resist vs Krieger",
        PVP_RES_NINJA = "🥷 Resist vs Ninja",
        PVP_RES_SURA = "🔮 Resist vs Sura",
        PVP_RES_SHAMAN = "🍃 Resist vs Schamane"
    }
    
    return names[skillType] or skillType
end

return {
    StartSkillSelection = StartSkillSelection,
    GetSkillDisplayName = GetSkillDisplayName
}