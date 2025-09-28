-- =============================================================================
-- FEATURE PET CONFIGURATION
-- Zentrale Konfigurationsdatei für das Pet-System
-- =============================================================================

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
    },
    
    -- DNA System
    DNA_DROP_CHANCE = 10, -- 10% Chance von Bossen
    DNA_MAX_LEVEL = 5,
    
    -- Fusion System
    FUSION_XP_TRANSFER = 0.25, -- 25% XP Transfer
    FUSION_SKILL_TRANSFER_CHANCE = 30, -- 30% Chance pro Skill
    FUSION_QUALITY_UPGRADE_CHANCE = 12, -- 12% pro Quality-Level
    
    -- Mission System
    DAILY_MISSIONS_COUNT = 2,
    
    -- Arena System
    ARENA_XP_REWARD = 15,
    ARENA_RANKING_POINTS_WIN = 10,
    ARENA_RANKING_POINTS_LOSS = -5
}

return FEATURE_PET_CONFIG