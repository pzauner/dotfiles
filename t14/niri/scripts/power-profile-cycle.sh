#!/usr/bin/env bash
set -euo pipefail

cur=$(busctl --system get-property \
  org.freedesktop.UPower.PowerProfiles \
  /org/freedesktop/UPower/PowerProfiles \
  org.freedesktop.UPower.PowerProfiles ActiveProfile | awk -F'"' '{print $2}')

next="performance"
if [ "$cur" = "performance" ]; then
  next="power-saver"
elif [ "$cur" = "power-saver" ]; then
  next="balanced"
fi

busctl --system call \
  org.freedesktop.UPower.PowerProfiles \
  /org/freedesktop/UPower/PowerProfiles \
  org.freedesktop.DBus.Properties Set \
  ssv org.freedesktop.UPower.PowerProfiles ActiveProfile s "$next" >/dev/null

echo "$next"
