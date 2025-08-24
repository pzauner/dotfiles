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

## Installierte Pakete

-   `packages.txt`: Enthält eine Liste aller explizit installierten Pakete aus den offiziellen Repositories.
-   `aur-packages.txt`: Enthält eine Liste aller explizit installierten Pakete aus dem AUR.
