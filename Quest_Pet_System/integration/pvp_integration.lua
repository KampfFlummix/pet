-- =============================================================================
-- PVP INTEGRATION
-- Füge diese Funktionen in deine bestehende pvp_events.lua ein
-- =============================================================================

dofile("lib/feature_pet_system.lua")
dofile("lib/feature_pet_missions.lua")

function pvp_kill(killer, victim)
    local killerID = killer.get_id()
    local victimID = victim.get_id()
    
    -- Pet XP für PvP-Kill
    local activePet = GetActivePet(killerID)
    if activePet then
        local xpGain = 15
        AddPetXP(killerID, activePet.id, xpGain)
        
        -- Mission-Fortschritt: PvP-Sieg
        UpdateMissionProgress(killerID, "PVP_WINS", 1)
    end
end