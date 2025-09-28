-- =============================================================================
-- MONSTER KILL SYSTEM
-- Behandelt alle Monster-Kill Events inkl. Feature Pets
-- =============================================================================

-- Feature Pet System Integration
dofile("lib/feature_pet_system.lua")
dofile("lib/feature_pet_missions.lua")
dofile("lib/feature_pet_dna.lua")

function monster_kill(monster, player)
    local playerID = player.get_id()
    local monsterLevel = monster.get_level()
    local monsterRace = monster.get_race()
    
    -- =========================================================================
    -- FEATURE PET SYSTEM
    -- =========================================================================
    
    -- Pet XP für Monster-Kill
    local activePet = feature_pet_system.GetActivePet(playerID)
    if activePet then
        local xpGain = monsterLevel * 10
        feature_pet_system.AddPetXP(playerID, activePet.id, xpGain)
        
        -- Mission-Fortschritt: Monster töten
        feature_pet_missions.UpdateMissionProgress(playerID, "KILL_MOBS", 1)
        
        -- Seelenfresser-DNA Effekt
        feature_pet_dna.ApplySoulEaterEffect(playerID, monsterRace)
    end
    
    -- Boss-Kill
    if monster.is_boss() then
        feature_pet_missions.UpdateMissionProgress(playerID, "KILL_BOSSES", 1)
        
        -- Chance auf DNA-Drop (10%)
        if math.random(1, 100) <= 10 then
            local dnaItems = {1005100, 1005101, 1005102, 1005103, 1005104}
            local randomDNA = dnaItems[math.random(1, #dnaItems)]
            pc.give_item2(playerID, randomDNA, 1)
            pc.say(playerID, "🧬 DNA-Probe vom Boss erhalten!")
        end
    end
    
    -- =========================================================================
    -- DEINE BESTEHENDEN MONSTER-KILL EVENTS (Hier einfügen)
    -- =========================================================================
    
    -- Beispiel: Deine existierenden Monster-Kill Events
    if monsterRace == 1302 then -- greenfrog_general
        pc.say(playerID, "Du hast den Greenfrog General besiegt!")
        -- Dein Code...
    end
    
    -- ... dein bestehender Code ...
    
end