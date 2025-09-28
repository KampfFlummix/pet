-- FEATURE PET SYSTEM - Datenbank Setup
-- Komplett ohne Server Source Code

SET FOREIGN_KEY_CHECKS=0;

-- Haupt-Pet Tabelle
CREATE TABLE IF NOT EXISTS `feature_pets` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner_id` INT NOT NULL,
    `pet_vnum` INT NOT NULL,
    `name` VARCHAR(32) NOT NULL,
    `level` INT DEFAULT 1,
    `xp` BIGINT DEFAULT 0,
    `evolution_stage` INT DEFAULT 0,
    `quality_level` TINYINT DEFAULT 1,
    `is_active` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `owner_idx` (`owner_id`),
    INDEX `active_idx` (`is_active`),
    INDEX `owner_active_idx` (`owner_id`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pet Skills Tabelle
CREATE TABLE IF NOT EXISTS `feature_pet_skills` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `pet_id` INT NOT NULL,
    `skill_type` VARCHAR(32) NOT NULL,
    `base_value` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`pet_id`) REFERENCES `feature_pets`(`id`) ON DELETE CASCADE,
    INDEX `pet_idx` (`pet_id`),
    INDEX `skill_idx` (`skill_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pet DNA System
CREATE TABLE IF NOT EXISTS `feature_pet_dna` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `pet_id` INT NOT NULL,
    `dna_type` VARCHAR(32) NOT NULL,
    `dna_level` INT DEFAULT 1,
    `obtained_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`pet_id`) REFERENCES `feature_pets`(`id`) ON DELETE CASCADE,
    INDEX `pet_dna_idx` (`pet_id`),
    INDEX `dna_type_idx` (`dna_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pet Missions System
CREATE TABLE IF NOT EXISTS `feature_pet_missions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner_id` INT NOT NULL,
    `mission_type` VARCHAR(32) NOT NULL,
    `progress` INT DEFAULT 0,
    `target` INT DEFAULT 0,
    `completed` BOOLEAN DEFAULT FALSE,
    `reward_claimed` BOOLEAN DEFAULT FALSE,
    `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,
    INDEX `owner_mission_idx` (`owner_id`),
    INDEX `mission_type_idx` (`mission_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pet Arena Rankings
CREATE TABLE IF NOT EXISTS `feature_pet_rankings` (
    `pet_id` INT PRIMARY KEY,
    `total_power` INT DEFAULT 0,
    `battles_won` INT DEFAULT 0,
    `battles_lost` INT DEFAULT 0,
    `ranking` INT DEFAULT 0,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `power_idx` (`total_power`),
    INDEX `ranking_idx` (`ranking`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pet Fusion Log
CREATE TABLE IF NOT EXISTS `feature_pet_fusions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner_id` INT NOT NULL,
    `main_pet_id` INT NOT NULL,
    `sacrifice_pet_id` INT NOT NULL,
    `fusion_type` VARCHAR(32) NOT NULL,
    `success` BOOLEAN DEFAULT FALSE,
    `result_quality` INT DEFAULT 0,
    `fused_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `owner_fusion_idx` (`owner_id`),
    INDEX `fusion_date_idx` (`fused_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=1;

-- Erfolgsmeldung
SELECT '✅ Feature Pet System Datenbank erfolgreich erstellt!' as status;