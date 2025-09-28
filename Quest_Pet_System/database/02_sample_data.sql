-- Beispiel-Daten für Testing
INSERT INTO `feature_pets` (`owner_id`, `pet_vnum`, `name`, `quality_level`, `level`, `is_active`) VALUES
(1, 5001, 'Drachenkrieger', 4, 1, 1),
(1, 5002, 'Eisphönix', 7, 1, 0);

-- Beispiel-Skills
INSERT INTO `feature_pet_skills` (`pet_id`, `skill_type`, `base_value`) VALUES
(1, 'STAT_STR', 15),
(1, 'PVM_BOSS_DMG', 10),
(1, 'DROP_YANG', 8);

SELECT '✅ Beispiel-Daten eingefügt!' as status;