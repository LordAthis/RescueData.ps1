-------------------------------
# Data Rescue Tool
-------------------------------
Adatmentést segítő script, amolyan "Digitális Régész"



Professzionális adatmentő szkript régi HDD-k, SSD-k és ömlesztett adatmentések intelligens rendszerezésére készült. Úgy lett tervezve, hogy önállóan (szervizkörnyezetben) és az **RTS keretrendszer** moduljaként is megállja a helyét. Nem csupán másol: **értékeli** az adatokat, **tanul** a felhasználói döntésekből és **összefésüli** a többszörös mentéseket.




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



## A "Döntési Fa" működése (Intelligens Összefésülés)
A rendszer a `merge.ps1` modulon keresztül egy egyedi pontozási algoritmust (Heurisztikát) használ a duplikációk kezelésére:

1. **MD5 Hash azonosítás:** A fájlokat tartalom alapján azonosítja, nem név szerint.
2. **Struktúra Pontozás:** 
   - Ha egy fájl egy beszédes nevű mappában van (pl. `/Család/Karácsony/`), több pontot kap (+15).
   - Ha a mappa neve csak szám (pl. `/001/`), pontlevonást kap (-8).
   - A mélyebb, kidolgozottabb elérési utak bónuszt kapnak.
3. **Automatikus Győztes:** A tartalmukban azonos fájlok közül csak az marad meg, amelyik a "legértékesebb" helyen található. 
4. **Metaadat megőrzés:** A törölt duplikátumok elérési útját a rendszer egy `.mentett.txt` fájlba rögzíti a megmaradt fájl mellett, így az információ nem vész el.

## Modulok
- **RescueData.ps1:** Szelektív mentés (Böngészők, Kripto, Torrentek, Desktop).
- **Delete.ps1:** Blacklist alapú tisztítás és "tanuló" mód a szemét fájlok kiiktatására.
- **Merge.ps1:** Az intelligens összefésülő motor.

---
*Készült az RTS ([Reparing's - Tuning's - Setting's](https://github.com/LordAthis/RTS)) projekt keretében. Használható önállóan vagy a keretrendszer moduljaként is!*
