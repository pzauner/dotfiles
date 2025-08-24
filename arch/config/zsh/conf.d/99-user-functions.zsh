# -----------------------------------------------------------------------------
# Benutzerdefinierte interaktive Funktionen
# -----------------------------------------------------------------------------
# Diese Datei wird automatisch vom Zsh-Startskript von HyDE geladen.
# Der Präfix "99-" im Dateinamen stellt sicher, dass sie nach den
# Standardkonfigurationen geladen wird, um Konflikte zu vermeiden.
# -----------------------------------------------------------------------------

# Funktion, um interaktiv in ein Verzeichnis zu wechseln (conflict-free name)
# Usage: cdi [path]
#   - Ohne Argument: Sucht im aktuellen Verzeichnis
#   - Mit Argument (z.B. cdi ~): Sucht im angegebenen Verzeichnis
cdi() {
    local dir
    dir=$(find ${1:-~} \( -path '*/.git' -o -path '*/.cache' -o -path '*/node_modules' -o -path '*/vendor' \) -prune -o -type d -print 2>/dev/null | fzf --height 40% --reverse) && cd "$dir"
}

# Funktion, um eine Datei interaktiv zu finden und mit $EDITOR zu öffnen
# Usage: f [path]
#   - Öffnet die ausgewählte Datei in Neovim (anpassbar)
f() {
    local file
    # Du kannst 'nano' hier durch deinen bevorzugten Editor ersetzen (z.B. 'code', 'cursor', 'nvim')
    file=$(find ${1:-~} \( -path '*/.git' -o -path '*/.cache' -o -path '*/node_modules' -o -path '*/vendor' \) -prune -o -type f -print 2>/dev/null | fzf --height 40% --reverse) && nano "$file"
}

# Interaktive Inhaltssuche mit Vorschau
# Usage: ifind <suchbegriff>
# Sucht nach einem Text in allen Dateien, zeigt eine interaktive Liste
# mit Live-Vorschau und öffnet den Treffer im Editor an der richtigen Stelle.
# Empfehlung: 'ripgrep' (rg) und 'bat' für beste Performance und Darstellung installieren.
ifind() {
  # Prüft, ob ein Suchbegriff übergeben wurde
  if [ -z "$1" ]; then
    echo "Usage: ifind <pattern>"
    return 1
  fi
  
  local selected_item
  
  # Bevorzugt 'ripgrep' (rg), da es schneller ist und .gitignore beachtet.
  if command -v rg &> /dev/null; then
    # rg-Befehl für maschinenlesbaren Output (file:line:col:text)
    RG_PREFIX="rg --vimgrep --no-heading --smart-case"
    
    # FZF-Kommando zusammenbauen und ausführen
    selected_item=$(eval "$RG_PREFIX '$1' | fzf --delimiter ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window 'right:60%:wrap'")
  else
    # Fallback auf 'grep', falls 'rg' nicht installiert ist
    GREP_PREFIX="grep -rin --exclude-dir={.git,node_modules,vendor}"
    selected_item=$(eval "$GREP_PREFIX '$1' . | fzf --delimiter ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window 'right:60%:wrap'")
  fi
  
  # Wenn der Benutzer etwas ausgewählt hat (nicht mit ESC abgebrochen)
  if [[ -n $selected_item ]]; then
    # Extrahiere Dateipfad (Feld 1) und Zeilennummer (Feld 2)
    local file=$(echo "$selected_item" | cut -d: -f1)
    local line=$(echo "$selected_item" | cut -d: -f2)
    
    # Öffne die Datei an der exakten Zeile im Editor
    nano "+$line" "$file"
  fi
}

# -----------------------------------------------------------------------------
# Konsistente Tastenkombinationen für Wort-Navigation
# -----------------------------------------------------------------------------
# Überschreibt die "Mac-ähnlichen" Alt+Pfeil-Tasten von Oh-my-Zsh und
# setzt die Standard-Linux-Kombination Strg+Pfeil für konsistentes
# Verhalten über alle Anwendungen hinweg.
# -----------------------------------------------------------------------------
# Entferne alte Bindungen (falls vorhanden), indem sie an "nichts" gebunden werden
bindkey '\e\e[C' undefined-key
bindkey '\e\e[D' undefined-key

# Setze neue Bindungen für Strg + Links/Rechts
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Bindungen für wortweises Löschen (Strg + Backspace / Strg + Entf)
bindkey '^H' backward-kill-word # Ctrl+Backspace
bindkey '^[[3;5~' kill-word      # Ctrl+Delete

# -----------------------------------------------------------------------------
# Text mit Shift + Pfeiltasten markieren
# -----------------------------------------------------------------------------
# Helfer-Widgets, um eine Markierung zu starten und den Cursor zu bewegen
select-backward-char-widget() {
  if ((REGION_ACTIVE == 0)); then
    zle set-mark-command
  fi
  zle backward-char
}
zle -N select-backward-char-widget

select-forward-char-widget() {
  if ((REGION_ACTIVE == 0)); then
    zle set-mark-command
  fi
  zle forward-char
}
zle -N select-forward-char-widget

# Binde Shift + Links/Rechts an die neuen Widgets
bindkey '^[[1;2D' select-backward-char-widget
bindkey '^[[1;2C' select-forward-char-widget

# -----------------------------------------------------------------------------
# Intelligentes Backspace zum Löschen von markiertem Text
# -----------------------------------------------------------------------------
smart-backspace-widget() {
  if ((REGION_ACTIVE)); then
    zle kill-region
  else
    zle backward-delete-char
  fi
}
zle -N smart-backspace-widget
bindkey '^?' smart-backspace-widget # '^?' ist der übliche Code für Backspace
