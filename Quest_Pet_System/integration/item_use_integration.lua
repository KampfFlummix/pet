-- =============================================================================
-- ITEM USE SYSTEM
-- Behandelt alle Item-Use Events inkl. Feature Pets
-- =============================================================================

-- Feature Pet System Integration
dofile("lib/feature_pet_system.lua")
dofile("lib/feature_pet_chest.lua")
dofile("lib/feature_pet_dna.lua")
dofile("lib/feature_pet_quality.lua")

function item_use(player, item)
    local playerID = player.get_id()
    local itemVnum = item.get_vnum()
    
    -- =========================================================================
    -- FEATURE PET ITEMS
    -- =========================================================================
    
    -- Feature Pet Truhe
    if itemVnum == 1005000 then
        if feature_pet_chest.UseFeaturePetChest(playerID) then
            return 1 -- Item verbrauchen
        end
        
    -- Quality Wechsel Item
    elseif itemVnum == 1005001 then
        pc.say(playerID, "Wähle ein Pet für Quality-Wechsel:")
        local pets = feature_pet_system.GetPlayerPets(playerID)
        
        if not pets or #pets == 0 then
            pc.say(playerID, "Du hast keine Pets!")
            return 0
        end
        
        for i, pet in ipairs(pets) do
            select(i, string.format("%s (Q%d)", pet.name, pet.quality_level))
        end
        select(#pets + 1, "Abbrechen")
        
        when select with input <= #pets do
            local selectedPet = pets[input]
            pc.say(playerID, "Wähle neue Quality:")
            
            for quality = 1, 8 do
                local qualityName = feature_pet_quality.GetQualityDisplayName(quality)
                select(quality, qualityName)
            end
            select(9, "Abbrechen")
            
            when select with input <= 8 do
                local newQuality = input
                if feature_pet_quality.UseQualitySwitchItem(playerID, selectedPet.id, newQuality) then
                    return 1 -- Item verbrauchen
                end
            end
        end
        
    -- DNA-Items
    elseif itemVnum >= 1005100 and itemVnum <= 1005104 then
        if feature_pet_dna.UseDNAItem(playerID, itemVnum) then
            return 1 -- Item verbrauchen
        end
        
    -- =========================================================================
    -- DEINE BESTEHENDEN ITEMS (Hier deinen bestehenden Code einfügen)
    -- =========================================================================
    
    -- Beispiel: Deine existierenden Items
    elseif itemVnum == 12345 then
        -- Dein bestehender Code für Item 12345
        pc.say(playerID, "Das ist ein bestehendes Item!")
        return 1
        
    elseif itemVnum == 67890 then
        -- Dein bestehender Code für Item 67890  
        pc.give_item2(playerID, 11111, 1)
        return 1
        
    -- =========================================================================
    -- STANDARD FALL - Item nicht erkannt
    -- =========================================================================
    else
        pc.say(playerID, "Dieses Item kann nicht verwendet werden.")
        return 0
    end
    
    return 0 -- Item nicht verbrauchen
end