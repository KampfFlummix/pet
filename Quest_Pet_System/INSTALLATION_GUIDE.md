# STEP-BY-STEP INSTALLATION

## PHASE 1: DATENBANK (Tag 1)
1. Putty öffnen: `mysql -u root -p`
2. Datenbank wählen: `use deine_datenbank;`
3. Tabellen erstellen: `source database/01_feature_pets_tables.sql`
4. Testdaten: `source database/02_sample_data.sql` (optional)

## PHASE 2: DATEIEN UPLOAD (Tag 2)
1. WinSCP öffnen und mit Server verbinden
2. Alle .lua Dateien nach `/usr/game/quest/lib/` uploaden
3. Quest-Dateien nach `/usr/game/quest/` uploaden

## PHASE 3: ITEMS & MOBS (Tag 3)
1. item_proto_entries.txt in deine item_proto.txt einfügen
2. mob_proto_entries.txt in deine mob_proto.txt einfügen (falls DNA-Drops)

## PHASE 4: INTEGRATION (Tag 4)
1. Existierende item_use.lua anpassen (siehe integration/)
2. Existierende monster_kill.lua anpassen
3. Existierende pvp_events.lua anpassen

## PHASE 5: TESTEN (Tag 5)
1. Server neustarten
2. Item spawnen: `/item 1005000`
3. Truhe öffnen und Pet testen
4. Alle Features durchtesten

## BEI FEHLERN:
- Logs prüfen: `/var/log/game_server/`
- DB-Verbindung testen
- Syntax-Fehler in Lua-Dateien prüfen
- Quest-System Logs checken