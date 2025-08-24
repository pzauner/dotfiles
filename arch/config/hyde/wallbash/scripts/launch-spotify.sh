#!/usr/bin/env bash

# Prüfen, ob Spotify läuft
if pgrep -x spotify > /dev/null; then
    # Spotify läuft bereits, Fenster in den Vordergrund bringen und zum Workspace wechseln
    CLIENT_INFO=$(hyprctl clients -j | jq -r '.[] | select(.class | test("(?i)spotify")) | "\(.workspace.id) \(.address)"' | head -n 1)

    if [ -n "$CLIENT_INFO" ]; then
        read -r WORKSPACE_ID WINDOW_ADDRESS <<< "$CLIENT_INFO"
        hyprctl --batch "dispatch workspace $WORKSPACE_ID; dispatch focuswindow address:$WINDOW_ADDRESS"
    else
        # Spotify läuft, hat aber kein Fenster (z.B. im Hintergrund, startet gerade)
        # Versuchen wir, es trotzdem zu starten, vielleicht öffnet das das Fenster
        spotify &
    fi
else
    # Spotify starten
    spotify &
fi
