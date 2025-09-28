-- =============================================================================
-- FEATURE PET EVENTS SYSTEM
-- Saisonale Events und Spezial-Events
-- =============================================================================

dofile("lib/feature_pet_system.lua")

-- Saisonale Events
SEASONAL_EVENTS = {
    HALLOWEEN = {
        active = false,
        start_date = "10-25",
        end_date = "11-02",
        pets = {
            [5101] = {name = "Geisterjäger", special_skill = "SEELEN_FRESSER"},
            [5102] = {name = "Pumpkin-King", special_skill = "KÜRBIS_EXPLOSION"}
        },
        drop_boost = 50, -- +50% Drop-Chance
        xp_boost = 30 -- +30% XP
    },
    CHRISTMAS = {
        active = false,
        start_date = "12-20", 
        end_date = "12-27",
        pets = {
            [5103] = {name = "Rudolph", special_skill = "GESCHENK_BONUS"},
            [5104] = {name = "Blitzen", special_skill = "SCHNEETEMPEST"}
        },
        drop_boost = 30,
        xp_boost = 50
    },
    SUMMER = {
        active = false,
        start_date = "07-01",
        end_date = "07-31",
        pets = {
            [5105] = {name = "Wassernixe", special_skill = "KÜHLUNG"},
            [5106] = {name = "Sonnendrache", special_skill = "SONNENBRAND"}
        },
        drop_boost = 20,
        xp_boost = 20
    }
}

function CheckSeasonalEvents()
    local current_date = os.date("%m-%d")
    
    for eventName, eventData in pairs(SEASONAL_EVENTS) do
        if current_date >= eventData.start_date and current_date <= eventData.end_date then
            if not eventData.active then
                ActivateEvent(eventName, eventData)
            end
        else
            if eventData.active then
                DeactivateEvent(eventName, eventData)
            end
        end
    end
end

function ActivateEvent(eventName, eventData)
    eventData.active = true
    say("🎉 " .. eventName .. " Event started!")
    
    -- Event-Pets zur Truhe hinzufügen
    for petVnum, petInfo in pairs(eventData.pets) do
        FEATURE_PETS[petVnum] = petInfo
    end
    
    -- Globalen Event-Bonus setzen
    SetGlobalEventBonus(eventData.drop_boost, eventData.xp_boost)
end

function DeactivateEvent(eventName, eventData)
    eventData.active = false
    say("❌ " .. eventName .. " Event ended.")
    
    -- Event-Pets entfernen
    for petVnum, _ in pairs(eventData.pets) do
        FEATURE_PETS[petVnum] = nil
    end
    
    -- Globalen Event-Bonus entfernen
    SetGlobalEventBonus(0, 0)
end

function SetGlobalEventBonus(dropBoost, xpBoost)
    -- Hier könntest du globale Variablen setzen, die in der Bonus-Berechnung berücksichtigt werden
    -- Zum Beispiel: 
    -- GLOBAL_DROP_BOOST = dropBoost
    -- GLOBAL_XP_BOOST = xpBoost
end

function GetEventBonus(playerID, bonusType)
    for eventName, eventData in pairs(SEASONAL_EVENTS) do
        if eventData.active then
            if bonusType == "DROP_ITEM" then
                return eventData.drop_boost
            elseif bonusType == "DROP_EXP" then
                return eventData.xp_boost
            end
        end
    end
    return 0
end

-- Spezial-Event: Pet-Turnier
function StartPetTournament()
    say("🏆 Pet-Turnier gestartet! Die Top 10 Pets erhalten Belohnungen!")
    
    -- Turnier dauert 1 Woche
    SetTournamentActive(true)
    
    -- Rankings zurücksetzen für Turnier
    db.execute("UPDATE feature_pet_rankings SET tournament_points = 0")
end

function EndPetTournament()
    local topPets = GetTopRankedPets(10)
    
    for i, pet in ipairs(topPets) do
        local reward = CalculateTournamentReward(i)
        GiveTournamentReward(pet.pet_id, reward, i)
    end
    
    say("🏆 Pet-Turnier beendet! Belohnungen wurden verteilt.")
    SetTournamentActive(false)
end

function CalculateTournamentReward(rank)
    local rewards = {
        [1] = {yang = 5000000, item = 1005400, xp = 500000},
        [2] = {yang = 3000000, item = 1005400, xp = 300000},
        [3] = {yang = 2000000, item = 1005400, xp = 200000},
        [4] = {yang = 1000000, item = 1005300, xp = 100000},
        [5] = {yang = 800000, item = 1005300, xp = 80000},
        [6] = {yang = 600000, item = 1005200, xp = 60000},
        [7] = {yang = 500000, item = 1005200, xp = 50000},
        [8] = {yang = 400000, item = 1005100, xp = 40000},
        [9] = {yang = 300000, item = 1005100, xp = 30000},
        [10] = {yang = 200000, item = 1005100, xp = 20000}
    }
    return rewards[rank] or {yang = 0, item = 0, xp = 0}
end

function GiveTournamentReward(petID, reward, rank)
    local pet = db.query("SELECT owner_id FROM feature_pets WHERE id = " .. petID)[1]
    if pet then
        pc.give_yang(pet.owner_id, reward.yang)
        pc.give_item(pet.owner_id, reward.item, 1)
        
        local activePet = GetActivePet(pet.owner_id)
        if activePet and activePet.id == petID then
            AddPetXP(pet.owner_id, petID, reward.xp)
        end
        
        pc.say(pet.owner_id, string.format("🎖️ Platz %d im Pet-Turnier! Belohnung: %d Yang, %d XP", rank, reward.yang, reward.xp))
    end
end

function SetTournamentActive(active)
    -- Hier könntest du einen globalen Flag setzen
    -- TOURNAMENT_ACTIVE = active
end

-- Initialisierung: Event-Check
CheckSeasonalEvents()

return {
    CheckSeasonalEvents = CheckSeasonalEvents,
    GetEventBonus = GetEventBonus,
    StartPetTournament = StartPetTournament,
    EndPetTournament = EndPetTournament,
    SEASONAL_EVENTS = SEASONAL_EVENTS
}