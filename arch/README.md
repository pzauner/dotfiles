# Meine Arch Linux & Hyprland Konfiguration

Dieses Repository dokumentiert meine persönliche Konfiguration für Arch Linux mit dem Hyprland Fenstermanager, basierend auf dem [HyDE](https://github.com/HyDE-Project/HyDE)-Setup.

Info: Sämtliche Kommentare und Hinweise wie auch diese README wurden ai-generiert und entsprechen nicht gerade meinem persönlichen Schreibstil. Erklärungen sind ebenfalls nicht meine, keine Gewähr für Richtigkeit. Manches ist nun einfach ein Optimum aus "funktioniert gut genug" und "alles weitere kostet zu viel Zeit und Mühe."

## Wichtige Änderungen & Anpassungen

Hier werden die wichtigsten Abweichungen und Ergänzungen zum Standard-HyDE-Setup festgehalten.

### 1. Keybindings (`~/.config/hypr/keybindings.conf`)

-   **Anwendungsstarter `vicinae`**: Es wurde ein Shortcut hinzugefügt, um den `vicinae`-Launcher zu starten.
    -   Tastenkombination: `Super + Leertaste`
    -   Konfigurationszeile:
        ```ini
        bindd = $mainMod, Space, $d launcher, exec, /usr/bin/vicinae
        ```
    -   *Hinweis: Die Verwendung von `bindd` und `$d launcher` ist spezifisch für das HyDE-Setup. *

### 2. Screenshots mit HDR-Displays (`~/.local/lib/hyde/`)

-   **Problem**: Screenshots auf einem HDR-Monitor erschienen "ausgeblichen", da die meisten Bildbetrachter HDR nicht korrekt interpretieren.
-   **Finale Lösung**: Tone Mapping erfolgt nach der Aufnahme direkt im Skript `~/.local/lib/hyde/screenshot.sh` per ImageMagick:
    ```bash
    magick "$temp_screenshot" -sigmoidal-contrast 20,45% "$temp_screenshot"
    ```
    -   Die Werte `20,45%` wurden empirisch gewählt; bei Bedarf anpassbar.
    -   Grün und Rot sind nicht farbakkurat und ausgewaschen.
    -   Keine Modifikation von `grimblast` nötig.
    -   Hinweis: `colord` wurde installiert (optionales Paket für ICC‑profile), ist für diese Lösung aber nicht zwingend erforderlich.

### 3. OCR-Screenshots (Texterkennung im Bild)

-   **Funktion**: Ermöglicht das Erstellen eines Screenshots von einem ausgewählten Bildschirmbereich, dessen Textinhalt automatisch erkannt und in die Zwischenablage kopiert wird.
-   **Tastenkombination**: `Super + O`
-   **Umsetzung**:
    -   Die bereits im Skript `~/.local/lib/hyde/screenshot.sh` vorhandene OCR-Funktion (`sc`) wurde durch eine Tastenkombination zugänglich gemacht.
    -   Diese Funktion nutzt `slurp` zur Bereichsauswahl, `grim` für den Screenshot und `tesseract` für die OCR.
    -   Die Tastenkombination wurde neu in `~/.config/hypr/keybindings.conf` hinzugefügt.
-   **Benötigte Pakete**: `tesseract` und `tesseract-data-eng` (für englische Texterkennung).

### 4. Intelligentes Spotify-Startskript

-   **Funktion**: Ein Skript, das beim Drücken der `Super + M`-Tastenkombination prüft, ob Spotify bereits läuft.
    -   Wenn ja, wird das Spotify-Fenster in den Fokus gerückt und zum aktiven Workspace gewechselt.
    -   Wenn nein, wird Spotify normal gestartet.
-   **Vorteil**: Verhindert das Öffnen mehrerer Spotify-Instanzen.
-   **Skript**: `~/.config/hyde/wallbash/scripts/launch-spotify.sh`

### 5. Dynamische Monitor-Konfiguration (für Dummy Plug)

-   **Problem**: Notwendigkeit, je nach Anwendungsfall zwischen einem echten Monitor und einem HDMI-Dummy-Plug (z.B. für Game-Streaming) zu wechseln.
-   **Lösung**: Das Skript `~/.config/hypr/monitor-setup.sh` prüft, ob der Hauptmonitor (`DP-3`) verbunden ist.
    -   Wenn ja, wird dieser mit den optimalen Einstellungen (HDR, hohe Bildwiederholrate) aktiviert und der Dummy-Plug (`HDMI-A-1`) wird deaktiviert.
    -   Wenn nein, wird der Dummy-Plug als primärer Monitor mit einer Standardauflösung aktiviert.
-   **Aktivierung**: Die Konfiguration kann jederzeit mit `Super + Shift + M` neu geladen werden.

### 6. SDDM-Login: Passwortanzeige deaktivieren

-   **Problem**: Der Login-Manager (SDDM) zeigt bei der Passworteingabe die Zeichen für ca. eine Sekunde an, bevor sie maskiert werden.
-   **Lösung**: Um dieses Verhalten aus Sicherheitsgründen zu unterbinden, wurde die Konfigurationsdatei des SDDM-Themes "Candy" angepasst.
    -   In der Datei `/usr/share/sddm/themes/Candy/Components/Input.qml` wurde der Wert für `passwordMaskDelay` von `1000` auf `0` geändert.
-   **Ergebnis**: Die eingegebenen Zeichen im Passwortfeld werden nun sofort maskiert.

## Installierte Pakete

-   `packages.txt`: Enthält eine Liste aller explizit installierten Pakete aus den offiziellen Repositories.
-   `aur-packages.txt`: Enthält eine Liste aller explizit installierten Pakete aus dem AUR.

### Paketlisten aktualisieren

Um sicherzustellen, dass diese Listen den aktuellen Stand des Systems widerspiegeln, können sie mit den folgenden Befehlen neu generiert werden:

-   **Offizielle Pakete:**
    ```bash
    pacman -Qqe > packages.txt
    ```
-   **AUR-Pakete:**
    ```bash
    pacman -Qqm > aur-packages.txt
    ```

*Diese Befehle sollten im Hauptverzeichnis des dotfiles-Repositorys ausgeführt werden, um die vorhandenen Dateien zu überschreiben.*

### 7. System-Snapshots mit Snapper & systemd-boot

-   **Funktion**: Das System nutzt eine zweistufige Automatisierung, um nach jeder Paket-Aktion (Installation, Update) bootfähige System-Snapshots zu erstellen. Dies bietet eine robuste Absicherung gegen fehlerhafte Updates.
-   **Stufe 1: Snapshot-Erstellung (snap-pac)**
    -   Das Standard-Paket `snap-pac` ist für die eigentliche Erstellung der Snapshots zuständig.
    -   Dessen Hooks (`/usr/share/libalpm/hooks/05-snap-pac-pre.hook` und `zz-snap-pac-post.hook`) werden vor und nach einer `pacman`-Transaktion aktiv und erstellen einen "Pre"- und "Post"-Snapshot des Systems.
-   **Stufe 2: Boot-Einträge erzeugen (benutzerdefiniertes Skript)**
    -   Die von `snap-pac` erstellten Snapshots wären ohne weitere Konfiguration nicht direkt bootbar.
    -   Diese Funktionalität wird durch ein benutzerdefiniertes Skript unter `/usr/local/bin/update-snapper-boot` bereitgestellt.
    -   Dieses Skript wird nach jeder `pacman`-Transaktion durch den manuell erstellten Hook `/etc/pacman.d/hooks/update-snapper-boot.hook` aufgerufen.
    -   Es scannt alle verfügbaren Snapper-Snapshots und generiert daraus automatisch die notwendigen Einträge für den `systemd-boot`-Bootloader.
-   **Zusammenspiel**: Die beiden Systeme ergänzen sich. `snap-pac` ist für die Erstellung der Snapshots verantwortlich, während das benutzerdefinierte Skript die notwendigen Bootloader-Einträge generiert, um diese Snapshots bootfähig zu machen.

### 8. Benutzerdefinierte Shell-Funktionen

In der Datei `~/.config/zsh/conf.d/99-user-functions.zsh` sind mehrere interaktive Helfer definiert, um die Arbeit im Terminal zu beschleunigen.

-   **`cdi [pfad]`** (Interaktiv Verzeichnis wechseln)
    -   **Funktion**: Startet einen Fuzzy-Finder (`fzf`) zur interaktiven Auswahl eines Verzeichnisses.
    -   **Standardverhalten**: Ohne Angabe eines Pfades wird das gesamte Home-Verzeichnis (`~`) durchsucht.
    -   **Angepasstes Verhalten**: Mit `cdi .` oder `cdi /pfad/zum/ordner` kann die Suche auf ein bestimmtes Verzeichnis eingeschränkt werden.

-   **`f [pfad]`** (Interaktiv Datei finden & öffnen)
    -   **Funktion**: Startet einen Fuzzy-Finder zur interaktiven Auswahl einer Datei, die anschließend in `nano` (anpassbar) geöffnet wird.
    -   **Standardverhalten**: Ohne Angabe eines Pfades wird das gesamte Home-Verzeichnis (`~`) durchsucht.
    -   **Angepasstes Verhalten**: Mit `f .` oder `f /pfad/zum/ordner` kann die Suche auf ein bestimmtes Verzeichnis eingeschränkt werden.

-   **`ifind <suchbegriff> [pfad]`** (Interaktiv Inhalt finden)
    -   **Funktion**: Sucht nach einem Textinhalt in Dateien und zeigt die Ergebnisse in einer interaktiven Liste mit Live-Vorschau (via `fzf` und `bat`). Die ausgewählte Datei wird direkt an der richtigen Zeile in `nano` geöffnet.
    -   **Standardverhalten**: Sucht im aktuellen Verzeichnis.
    -   **Angepasstes Verhalten**: Es kann ein optionaler Suchpfad übergeben werden (`ifind "mein text" ~/projekte`).
    -   **Abhängigkeiten**: Nutzt `ripgrep` (`rg`) für die Suche und `bat` für die Vorschau, falls installiert.

### 9. Verbesserte Zsh-Tastenkombinationen

Zusätzlich zu den interaktiven Funktionen verbessert die `99-user-functions.zsh` das Editier-Erlebnis in der Kommandozeile durch konsistentere und leistungsfähigere Tastenkombinationen.

-   **Wort-Navigation (Linux-Standard)**
    -   `Strg` + `←`/`→`: Wortweises Springen des Cursors.
    -   `Strg` + `Backspace`: Löscht das Wort links vom Cursor.
    -   `Strg` + `Entf`: Löscht das Wort rechts vom Cursor.
    -   *Hinweis: Dies stellt ein Standard-Verhalten her, wie es in den meisten Linux-Anwendungen üblich ist.*

-   **Textauswahl**
    -   `Shift` + `←`/`→`: Markiert Text zeichenweise.

-   **Intelligentes Löschen**
    -   `Backspace`: Wenn Text markiert ist, wird die gesamte Markierung gelöscht. Ansonsten wird nur ein Zeichen gelöscht.

### 10. Statisches Terminal-Logo (fastfetch)

-   **Problem**: Beim Start einer neuen Terminalsitzung wurde durch das HyDE-Standard-Skript in `fastfetch` ein zufälliges oder variierendes ASCII-Logo angezeigt.
-   **Lösung**: Um eine konsistente Darstellung zu gewährleisten, wurde die `fastfetch`-Konfiguration angepasst, sodass immer das Arch-Linux-Logo angezeigt wird.
-   **Konfigurationsdatei**: `~/.config/fastfetch/config.jsonc`
-   **Änderung**: Der Wert `"logo": { "source": ... }` wurde von einem dynamischen Skriptaufruf auf den statischen Wert `"arch"` geändert.
