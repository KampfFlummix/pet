-- =============================================================================
-- FEATURE PET ARENA SYSTEM
-- PvP-Kämpfe zwischen Pets
-- =============================================================================

dofile("lib/feature_pet_system.lua")

function StartPetBattle(playerID, opponentPetID)
    local playerPet = GetActivePet(playerID)
    if not playerPet then
        pc.say(playerID, "Du hast kein aktives Pet!")
        return false
    end
    
    local opponentPet = db.query("SELECT * FROM feature_pets WHERE id = " .. opponentPetID)[1]
    if not opponentPet then
        pc.say(playerID, "Gegnerisches Pet nicht gefunden!")
        return false
    end
    
    if opponentPet.owner_id == playerID then
        pc.say(playerID, "Du kannst nicht gegen dein eigenes Pet kämpfen!")
        return false
    end
    
    -- Pet-Stärke berechnen
    local playerPower = CalculatePetPower(playerPet)
    local opponentPower = CalculatePetPower(opponentPet)
    
    -- Kampf-Ergebnis bestimmen
    local winner, loser, isDraw = DetermineBattleWinner(playerPower, opponentPower)
    
    -- Preise verteilen und Ergebnis anzeigen
    if isDraw then
        pc.say(playerID, "⚔️ Unentschieden! Beide Pets waren gleich stark.")
        return true
    end
    
    if winner == playerPet then
        -- Spieler gewinnt
        local xpReward = math.floor(loser.level * 100)
        AddPetXP(playerID, playerPet.id, xpReward)
        
        UpdatePetRanking(playerPet.id, 10)
        UpdatePetRanking(loser.id, -5)
        
        pc.say(playerID, string.format("🎉 Sieg! %s hat gewonnen! +%d XP", playerPet.name, xpReward))
        pc.say(opponentPet.owner_id, string.format("💥 Niederlage! %s hat gegen %s verloren.", opponentPet.name, playerPet.name))
    else
        -- Spieler verliert
        UpdatePetRanking(playerPet.id, -5)
        UpdatePetRanking(winner.id, 10)
        
        pc.say(playerID, string.format("💥 Niederlage! %s hat gegen %s verloren.", playerPet.name, opponentPet.name))
        pc.say(opponentPet.owner_id, string.format("🎉 Sieg! %s hat gewonnen!", opponentPet.name))
    end
    
    return true
end

function CalculatePetPower(pet)
    local basePower = pet.level * pet.quality_level
    local skillBonus = GetTotalSkillValue(pet.id)
    local evolutionBonus = pet.evolution_stage * 0.2
    local dnaBonus = GetDNAPowerBonus(pet.id)
    
    return math.floor(basePower * (1 + skillBonus/100) * (1 + evolutionBonus) * (1 + dnaBonus/100))
end

function GetTotalSkillValue(petID)
    local skills = db.query("SELECT base_value FROM feature_pet_skills WHERE pet_id = " .. petID)
    local total = 0
    for _, skill in ipairs(skills) do
        total = total + skill.base_value
    end
    return total
end

function GetDNAPowerBonus(petID)
    local dnaEntries = db.query("SELECT * FROM feature_pet_dna WHERE pet_id = " .. petID)
    local totalBonus = 0
    for _, dna in ipairs(dnaEntries) do
        totalBonus = totalBonus + (dna.dna_level * 2) -- 2% Bonus pro DNA-Level
    end
    return totalBonus
end

function DetermineBattleWinner(power1, power2)
    local totalPower = power1 + power2
    local chance1 = power1 / totalPower
    local chance2 = power2 / totalPower
    
    local roll = math.random()
    
    if roll < chance1 then
        return {power = power1}, {power = power2}, false
    elseif roll < chance1 + chance2 then
        return {power = power2}, {power = power1}, false
    else
        return nil, nil, true
    end
end

function UpdatePetRanking(petID, pointsChange)
    local ranking = db.query("SELECT * FROM feature_pet_rankings WHERE pet_id = " .. petID)
    if ranking and #ranking > 0 then
        local currentPoints = ranking[1].total_power or 0
        local newPoints = math.max(0, currentPoints + pointsChange)
        db.execute("UPDATE feature_pet_rankings SET total_power = " .. newPoints .. " WHERE id = " .. petID)
    else
        db.execute("INSERT INTO feature_pet_rankings (pet_id, total_power) VALUES (" .. petID .. ", " .. math.max(0, pointsChange) .. ")")
    end
end

function GetTopRankedPets(limit)
    return db.query("SELECT * FROM feature_pet_rankings ORDER BY total_power DESC LIMIT " .. (limit or 10))
end

function GetPetRanking(petID)
    local ranking = db.query("SELECT * FROM feature_pet_rankings WHERE pet_id = " .. petID)
    if ranking and #ranking > 0 then
        return ranking[1]
    end
    return nil
end

return {
    StartPetBattle = StartPetBattle,
    CalculatePetPower = CalculatePetPower,
    GetTopRankedPets = GetTopRankedPets,
    GetPetRanking = GetPetRanking
}