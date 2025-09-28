-- =============================================================================
-- FEATURE PET FUSION SYSTEM  
-- Zwei Pets zu einem stärkeren Pet fusionieren
-- =============================================================================

dofile("lib/feature_pet_system.lua")

function StartPetFusion(playerID, mainPetID, sacrificePetID)
    local mainPet = db.query("SELECT * FROM feature_pets WHERE id = " .. mainPetID .. " AND owner_id = " .. playerID)[1]
    local sacrificePet = db.query("SELECT * FROM feature_pets WHERE id = " .. sacrificePetID .. " AND owner_id = " .. playerID)[1]
    
    if not mainPet or not sacrificePet then
        pc.say(playerID, "Ungültige Pets für Fusion!")
        return false
    end
    
    if mainPet.id == sacrificePet.id then
        pc.say(playerID, "Du kannst ein Pet nicht mit sich selbst fusionieren!")
        return false
    end
    
    -- Fusion durchführen
    local success, result = PerformFusion(playerID, mainPet, sacrificePet)
    
    if success then
        pc.say(playerID, result)
        return true
    else
        pc.say(playerID, result)
        return false
    end
end

function PerformFusion(playerID, mainPet, sacrificePet)
    -- Basis-Fusion-Bonus berechnen
    local fusionBonus = math.floor(sacrificePet.level * 0.5)
    
    -- Quality Upgrade Chance (basierend auf Opfer-Qualität)
    local qualityUpgradeChance = sacrificePet.quality_level * 12 -- 12% pro Quality-Level
    local qualityImproved = false
    
    if math.random(1, 100) <= qualityUpgradeChance then
        local newQuality = math.min(FEATURE_PET_CONFIG.MAX_QUALITY, mainPet.quality_level + 1)
        db.execute("UPDATE feature_pets SET quality_level = " .. newQuality .. " WHERE id = " .. mainPet.id)
        qualityImproved = true
    end
    
    -- XP-Transfer (25% vom Opfer-Pet)
    local xpTransfer = math.floor(sacrificePet.xp * 0.25)
    local newXP = mainPet.xp + xpTransfer
    
    -- Skills vom Opfer-Pet übertragen (Chance)
    TransferSkills(mainPet.id, sacrificePet.id, 30) -- 30% Chance pro Skill
    
    -- DNA übertragen (falls vorhanden)
    TransferDNA(mainPet.id, sacrificePet.id)
    
    -- Opfer-Pet löschen
    db.execute("DELETE FROM feature_pets WHERE id = " .. sacrificePet.id)
    
    -- Main-Pet updaten
    db.execute("UPDATE feature_pets SET xp = " .. newXP .. " WHERE id = " .. mainPet.id)
    
    -- Fusion loggen
    db.execute("INSERT INTO feature_pet_fusions (owner_id, main_pet_id, sacrifice_pet_id, fusion_type, success, result_quality) VALUES (" .. playerID .. ", " .. mainPet.id .. ", " .. sacrificePet.id .. ", 'NORMAL', 1, " .. mainPet.quality_level .. ")")
    
    -- Ergebnis-Text
    local resultText = "✅ Fusion abgeschlossen! +" .. fusionBonus .. "% Bonus"
    
    if qualityImproved then
        resultText = resultText .. " | Quality verbessert!"
    end
    
    if xpTransfer > 0 then
        resultText = resultText .. " | +" .. xpTransfer .. " XP"
    end
    
    -- Ultra-Fusion bei gleichem Pet-Typ
    if mainPet.pet_vnum == sacrificePet.pet_vnum then
        resultText = resultText .. " | 🌟 Ultra-Fusion Bonus!"
        GrantUltraFusionBonus(mainPet.id)
    end
    
    return true, resultText
end

function TransferSkills(mainPetID, sacrificePetID, chance)
    local sacrificeSkills = db.query("SELECT * FROM feature_pet_skills WHERE pet_id = " .. sacrificePetID)
    
    for _, skill in ipairs(sacrificeSkills) do
        if math.random(1, 100) <= chance then
            -- Prüfen ob Main-Pet diesen Skill bereits hat
            local existingSkill = db.query("SELECT * FROM feature_pet_skills WHERE pet_id = " .. mainPetID .. " AND skill_type = '" .. skill.skill_type .. "'")
            
            if existingSkill and #existingSkill > 0 then
                -- Skill-Wert erhöhen
                local newValue = math.floor((existingSkill[1].base_value + skill.base_value) * 0.6) -- 60% des kombinierten Werts
                db.execute("UPDATE feature_pet_skills SET base_value = " .. newValue .. " WHERE id = " .. existingSkill[1].id)
            else
                -- Neuen Skill hinzufügen (reduzierter Wert)
                local newValue = math.floor(skill.base_value * 0.8) -- 80% des originalen Werts
                db.execute("INSERT INTO feature_pet_skills (pet_id, skill_type, base_value) VALUES (" .. mainPetID .. ", '" .. skill.skill_type .. "', " .. newValue .. ")")
            end
        end
    end
end

function TransferDNA(mainPetID, sacrificePetID)
    local sacrificeDNA = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. sacrificePetID)
    
    for _, dna in ipairs(sacrificeDNA) do
        -- 50% Chance DNA zu übertragen
        if math.random(1, 100) <= 50 then
            local mainDNA = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. mainPetID .. " AND dna_type = '" .. dna.dna_type .. "'")
            
            if mainDNA and #mainDNA > 0 then
                -- DNA-Level erhöhen (bis zum Maximum)
                local dnaInfo = DNA_TYPES[dna.dna_type]
                local newLevel = math.min(dnaInfo.max_level, mainDNA[1].dna_level + 1)
                db.execute("UPDATE feature_pet_dna SET dna_level = " .. newLevel .. " WHERE id = " .. mainDNA[1].id)
            else
                -- Neue DNA hinzufügen
                db.execute("INSERT INTO feature_pet_dna (pet_id, dna_type, dna_level) VALUES (" .. mainPetID .. ", '" .. dna.dna_type .. "', 1)")
            end
        end
    end
end

function GrantUltraFusionBonus(petID)
    -- Ultra-Fusion: +15% auf alle Skills
    local skills = db.query("SELECT id, base_value FROM feature_pet_skills WHERE pet_id = " .. petID)
    
    for _, skill in ipairs(skills) do
        local newValue = math.floor(skill.base_value * 1.15)
        db.execute("UPDATE feature_pet_skills SET base_value = " .. newValue .. " WHERE id = " .. skill.id)
    end
    
    -- Spezial-DNA für Ultra-Fusion
    db.execute("INSERT INTO feature_pet_dna (pet_id, dna_type, dna_level) VALUES (" .. petID .. ", 'FUSION_MASTER', 1)")
end

function CanFusePets(pet1, pet2)
    -- Prüfen ob Fusion möglich ist
    if pet1.owner_id ~= pet2.owner_id then return false end
    if pet1.is_active then return false end -- Aktives Pet kann nicht geopfert werden
    if pet2.is_active then return false end
    
    return true
end

return {
    StartPetFusion = StartPetFusion,
    CanFusePets = CanFusePets,
    PerformFusion = PerformFusion
}