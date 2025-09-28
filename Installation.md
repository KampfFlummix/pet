# Feature Pet System - Installation

## Voraussetzungen:
- MySQL-Zugriff (Putty)
- WinSCP (Datei-Upload)
- Server-Neustart-Rechte

## Schritt 1: Datenbank einrichten
1. Putty öffnen: `mysql -u root -p`
2. Datenbank auswählen: `use deine_datenbank;`
3. SQL-Skript ausführen: `source /pfad/zu/feature_pets_tables.sql`

## Schritt 2: Dateien hochladen
1. WinSCP öffnen und mit Server verbinden
2. Alle .lua Dateien nach `/usr/game/quest/lib/` uploaden
3. quest_feature_pets.txt nach `/usr/game/quest/` uploaden

## Schritt 3: Item Prototypes
1. item_proto_entries.txt Einträge in deine item_proto.txt einfügen
2. Sicherstellen dass die VNums nicht vergeben sind

## Schritt 4: Integration
1. Existierende item_use.lua anpassen (siehe Integration Guide)
2. Existierende monster_kill.lua anpassen (siehe Integration Guide)

## Schritt 5: Testen
1. Server neustarten
2. Item spawnen: `/item 1005000`
3. Truhe öffnen und Pet testen

## Fehlerbehebung:
- Logs checken: `/var/log/game_server/`
- DB-Verbindung prüfen
- Syntax-Fehler in Lua-Dateien prüfen
