# RTS Data Cleaning & Learning Tool (delete.ps1)

Ez a modul a kimentett adatok utólagos tisztításáért és a szűrőrendszer "tanításáért" felel. Segítségével a mentési folyamat (RescueData.ps1) egyre hatékonyabbá válik.

## Fő funkciók

### 1. Takarítás (TargetFolder)
A megadott mappán belül rekurzívan végigfut és töröl minden fájlt és mappát, amely szerepel a `blacklist.json` listájában.
- **Használat:** `.\delete.ps1 -TargetFolder "C:\Backups\Mentes_Mappa"`

### 2. Tömeges Tanulás (LearnFolder)
Ha van egy olyan mappád, amelybe manuálisan összegyűjtötted a szemetet, a script képes "felszívni" annak tartalmát.
- Minden benne lévő **mappa nevet** felvesz a tiltólistára.
- Minden benne lévő **fájl kiterjesztést** (.exe, .tmp, stb.) felvesz a tiltólistára.
- **Használat:** `.\delete.ps1 -LearnFolder "C:\Backups\Szemetes_Kosar"`

### 3. Interaktív Mód
Minden futás végén (vagy önálló indításnál) a script rákérdez, hogy szeretnél-e manuálisan új tiltott elemeket megadni.
- Elkülöníti a mappákat és a fájl-kiterjesztéseket.
- Automatikusan kezeli a pontozást a kiterjesztéseknél.
- `while` ciklusban teszi lehetővé több elem gyors felvitelét.

## Munkafolyamat ajánlás
1. Futtasd a mentést (`RescueData.ps1`).
2. Nézd át a mentett mappát.
3. Ami szemetet találsz, azt vagy add meg manuálisan a `delete.ps1` interaktív részében, vagy gyűjtsd egy külön mappába és használd a `-LearnFolder` kapcsolót.
4. Futtasd le a takarítást a `-TargetFolder` megadásával.

---
*Az RTS keretrendszer része.*
