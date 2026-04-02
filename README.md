-------------------------------
# Data Rescue Tool
-------------------------------
Adatmentést segítő script, amolyan "Digitális Régész"



Professzionális adatmentő szkript elhanyagolt HDD-k és SSD-k gyors, szelektív mentéséhez. Úgy lett tervezve, hogy önállóan (szervizkörnyezetben) és az **RTS keretrendszer** moduljaként is megállja a helyét.

## Főbb funkciók
- **Intelligens Böngésző Mentés:** Chrome, Edge, Firefox, Brave, Opera és Tor profilok mentése (könyvjelzők, jelszavak, kiterjesztések és egyedi beállítások).
- **Szelektív Cache:** Az 50KB alatti felesleges cache fájlokat figyelmen kívül hagyja, de a potenciális adatokat megtartja.
- **Torrent Kezelés:** Külön gyűjti a `.torrent` fájlokat és a félbehagyott letöltéseket.
- **Automatizált Identifikáció:** A megadott névhez automatikusan hozzáadja az aktuális dátumot a mappa- és archívumnévben.
- **Blacklist Kezelés:** Tanítható tiltólista a felesleges rendszerfájlok és telepítők (pl. régi böngésző setupok) kiszűrésére.
- **RTS Integráció:** JSON alapú paraméterezhetőség és kettős (helyi + rendszer) logolás.

## Használat
1. Másold le a tárolót.
2. Futtasd a `RescueTool.ps1`-et Rendszergazdaként.
3. Ha a `config.json` üres, a szkript bekéri a szükséges adatokat.
4. A mentés végeztével választható a tömörítés (ZIP), de az eredeti adatok megmaradnak a későbbi feldolgozáshoz.

## Segédfájlok
- `config.json`: Mentési beállítások és célútvonalak.
- `blacklist.json`: Tiltott mappák és fájltípusok listája.
- `delete.ps1`: (Készülőben) A mentett adatok utólagos tisztításához és a blacklist tanításához.
- `merge.ps1`: (Készülőben) Adatfeldolgozás, összefésülés, duplikációk kezelése!

---
*Készült az RTS (Rescue & Technical Support) projekt keretében.*
