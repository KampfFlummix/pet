-- =============================================================================
-- FEATURE PET MISSIONS SYSTEM
-- Tägliche Missionen für Pets mit Belohnungen
-- =============================================================================

dofile("lib/feature_pet_system.lua")

-- Missionstypen
PET_MISSIONS = {
    {
        id = "KILL_MOBS",
        name = "Monsterjäger",
        description = "Töte 100 Monster mit aktivem Pet",
        target = 100,
        reward_xp = 50000,
        reward_item = 1005100, -- Metin-DNA
        reward_yang = 0
    },
    {
        id = "KILL_BOSSES", 
        name = "Boss-Herausforderer",
        description = "Besiege 5 Bosse mit aktivem Pet",
        target = 5,
        reward_xp = 100000,
        reward_item = 1005101, -- Boss-DNA
        reward_yang = 500000
    },
    {
        id = "COLLECT_YANG",
        name = "Yang-Magnet",
        description = "Sammle 1.000.000 Yang mit Pet-Bonus",
        target = 1000000,
        reward_xp = 75000,
        reward_item = 1005103, -- Yang-DNA
        reward_yang = 1000000
    },
    {
        id = "PVP_WINS",
        name = "PvP-Champion",
        description = "Gewinne 3 PvP-Kämpfe mit aktivem Pet",
        target = 3,
        reward_xp = 150000,
        reward_item = 1005102, -- PvP-DNA
        reward_yang = 1000000
    }
}

function AssignDailyMissions(playerID)
    -- Alte Missionen zurücksetzen
    db.execute("DELETE FROM feature_pet_missions WHERE owner_id = " .. playerID)
    
    -- Zwei zufällige Missionen zuweisen
    local assigned = 0
    local missionIndices = {}
    for i = 1, #PET_MISSIONS do table.insert(missionIndices, i) end
    
    while assigned < 2 and #missionIndices > 0 do
        local randomIndex = math.random(1, #missionIndices)
        local missionIndex = missionIndices[randomIndex]
        local mission = PET_MISSIONS[missionIndex]
        
        table.remove(missionIndices, randomIndex)
        
        db.execute("INSERT INTO feature_pet_missions (owner_id, mission_type, progress, target) VALUES (" .. playerID .. ", '" .. mission.id .. "', 0, " .. mission.target .. ")")
        assigned = assigned + 1
        
        pc.say(playerID, "📜 Neue Mission: " .. mission.name)
    end
end

function UpdateMissionProgress(playerID, missionType, amount)
    local mission = db.query("SELECT * FROM feature_pet_missions WHERE owner_id = " .. playerID .. " AND mission_type = '" .. missionType .. "' AND completed = 0")
    if not mission or #mission == 0 then return end
    
    mission = mission[1]
    local newProgress = mission.progress + amount
    
    db.execute("UPDATE feature_pet_missions SET progress = " .. newProgress .. " WHERE id = " .. mission.id)
    
    if newProgress >= mission.target then
        db.execute("UPDATE feature_pet_missions SET completed = 1, completed_at = NOW() WHERE id = " .. mission.id)
        pc.say(playerID, "🎉 Mission abgeschlossen: " .. GetMissionName(missionType))
    end
end

function ClaimMissionReward(playerID, missionType)
    local mission = db.query("SELECT * FROM feature_pet_missions WHERE owner_id = " .. playerID .. " AND mission_type = '" .. missionType .. "' AND completed = 1 AND reward_claimed = 0")
    if not mission or #mission == 0 then return false end
    
    mission = mission[1]
    local missionInfo = GetMissionInfo(missionType)
    
    if not missionInfo then return false end
    
    -- Belohnungen geben
    if missionInfo.reward_xp > 0 then
        local activePet = GetActivePet(playerID)
        if activePet then
            AddPetXP(playerID, activePet.id, missionInfo.reward_xp)
        end
    end
    
    if missionInfo.reward_yang > 0 then
        pc.give_yang(playerID, missionInfo.reward_yang)
    end
    
    if missionInfo.reward_item > 0 then
        pc.give_item(playerID, missionInfo.reward_item, 1)
    end
    
    db.execute("UPDATE feature_pet_missions SET reward_claimed = 1 WHERE id = " .. mission.id)
    pc.say(playerID, "🎁 Belohnung abgeholt für: " .. missionInfo.name)
    
    return true
end

function GetMissionInfo(missionType)
    for _, mission in ipairs(PET_MISSIONS) do
        if mission.id == missionType then
            return mission
        end
    end
    return nil
end

function GetMissionName(missionType)
    local mission = GetMissionInfo(missionType)
    return mission and mission.name or "Unbekannte Mission"
end

function GetPlayerMissions(playerID)
    return db.query("SELECT * FROM feature_pet_missions WHERE owner_id = " .. playerID .. " ORDER BY completed, mission_type")
end

-- Täglicher Reset
function ResetDailyMissions()
    db.execute("DELETE FROM feature_pet_missions WHERE completed = 1 AND reward_claimed = 1")
    say("Tägliche Pet-Missionen zurückgesetzt!")
end

return {
    AssignDailyMissions = AssignDailyMissions,
    UpdateMissionProgress = UpdateMissionProgress,
    ClaimMissionReward = ClaimMissionReward,
    GetPlayerMissions = GetPlayerMissions,
    ResetDailyMissions = ResetDailyMissions,
    PET_MISSIONS = PET_MISSIONS
}