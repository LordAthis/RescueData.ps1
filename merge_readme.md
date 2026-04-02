# RescueData Merge Tool (merge.ps1)

Ez a modul hivatott rendet tenni a különböző forrásokból származó mentések között, intelligens pontozási rendszer segítségével.

## Intelligens Funkciók
- **Pontozás (Scoring):** A script értékeli a mappaszerkezetet. A beszédes nevek (pl. "Karácsony") több pontot kapnak, mint a technikai nevek (pl. "001"). A fájl mindig a legmagasabb pontszámú (legjobban rendszerezett) helyre kerül.
- **MD5 Tracking:** Minden fájlról hash készül. Ha egy fájl több helyen is megvan, a duplikáció törlődik, de a nyertes fájl mellé készül egy `.mentett.txt`, amely tartalmazza az összes korábbi elérési utat.
- **Böngésző összefésülés:** A könyvjelzők és profilok név-prioritás alapján kerülnek összevonásra.
- **Intelligens szűrés:** Az 5KB alatti lényegtelen fájlok automatikusan törlődnek, kivéve a kritikus típusokat (.torrent, .txt, .json).

## Használat
1. Állítsd be a `mergelogic.json` fájlban a számodra "szemétnek" számító mappaneveket.
2. Indítás: `.\merge.ps1 -SourceBase "C:\Mentesek" -MasterPath "D:\Vegleges_Adatok" -UpdateMD5DB`
3. A folyamat végén az üresen maradt forrásmappák automatikusan törlődnek.

---
*Az RTS keretrendszer részeként is használható.*




