-- =============================================================================
-- FEATURE PET CONSTANTS
-- Konstanten für das Pet-System
-- =============================================================================

-- Skill Types
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

-- Item VNums
ITEM_VNUMS = {
    PET_CHEST = 1005000,
    QUALITY_SWITCH = 1005001,
    DNA_METIN = 1005100,
    DNA_BOSS = 1005101,
    DNA_PVP = 1005102,
    DNA_YANG = 1005103,
    DNA_SOUL_EATER = 1005104,
    FUSION_STONE = 1005200,
    EVOLUTION_STONE = 1005300,
    MISSION_CHEST = 1005400
}

-- Pet VNums
PET_VNUMS = {
    DRAGON = 5001,
    ICE_PHOENIX = 5002,
    DARK_WOLF = 5003,
    LIGHT_SPIRIT = 5004,
    STONE_GOLEM = 5005,
    LIGHTNING_DRAGON = 5006,
    FIRE_DEVIL = 5007,
    WATER_NYMPH = 5008,
    WIND_FALCON = 5009,
    EARTH_DEMON = 5010
}

return {
    SKILL_TYPES = SKILL_TYPES,
    ITEM_VNUMS = ITEM_VNUMS,
    PET_VNUMS = PET_VNUMS
}