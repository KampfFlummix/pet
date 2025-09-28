# Server Integration Guide

## Überblick
Dieses Feature Pet System wurde für Metin2 Server entwickelt, die ein Quest-System unterstützen. Es verwendet keine Server Source Code Änderungen und ist komplett in Lua und MySQL implementiert.

## 🔧 Deine Server-Spezifikationen

### Quest-System:
- **Syntax**: `quest name begin` → `state start begin` → `when condition begin`
- **NPC Dialog**: `when npc_vnum.chat."text" begin`
- **Item Use**: `when item_vnum.receive begin`
- **Player Functions**: `pc.get_id()`, `pc.say()`, `select()`, `pc.give_item2()`

### Bekannte funktionierende Funktionen:
```lua
pc.get_id()           -- Spieler ID
pc.say()              -- Nachricht an Spieler
pc.give_item2()       -- Item geben
pc.remove_item()      -- Item entfernen
pc.getqf() / pc.setqf() -- Quest-Flags
select()              -- Auswahl-Menü
npc.get_race()        -- NPC Rasse
mob_name()            -- NPC Name

## Kompatibilität
Das System ist kompatibel mit Servern, die:
- Quest-Dateien unterstützen (Zustandsmaschinen mit `begin`/`end` Syntax)
- Lua-Skripting in Quests erlauben
- MySQL Datenbankzugriff haben

## Integration in bestehende Systeme

### 1. Datenbank
Führe die SQL-Dateien in `database/` aus, um die notwendigen Tabellen zu erstellen.

### 2. Quest-Dateien
Kopiere die Quest-Dateien aus `quests/` in dein `quest/` Verzeichnis.

### 3. Lua-Bibliotheken
Kopiere die Lua-Dateien aus `quests/lib/` in dein `quest/lib/` Verzeichnis.

### 4. Items
Füge die Item-Definitionen aus `items/item_proto_entries.txt` in deine `item_proto.txt` ein.

### 5. Integration in bestehende Quests
Füge die Code-Snippets aus `integration/` in deine bestehenden Systeme ein:

- `item_use.lua`: Für die Verwendung der Pet-Items
- `monster_kill.lua`: Für XP und Missionen bei Monster-Kills
- `pvp_events.lua`: Für PvP-Ereignisse

### 6. NPC
Du kannst einen bestehenden NPC verwenden (wie in `quest_feature_pet_npc.txt` gezeigt, der den Waffenhändler (9001) verwendet) oder einen neuen NPC erstellen.

## Anpassungen
Du kannst das System anpassen, indem du:
- Die Konfiguration in `config/` änderst
- Weitere Pets in `feature_pet_chest.lua` hinzufügst
- Weitere Skills in `feature_pet_skills.lua` hinzufügst

## Fehlerbehebung
- Prüfe die Logs auf Syntaxfehler in den Quest-Dateien
- Stelle sicher, dass alle Lua-Bibliotheken geladen werden können
- Überprüfe die Datenbankverbindung und Tabellen

## Support
Bei Fragen kannst du ein Issue auf GitHub erstellen.