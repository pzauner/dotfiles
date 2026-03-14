# t14 niri

Snapshot of current T14 Niri + DMS lock/brightness setup.

## Overlay Repo

- niri-focus-ring-overlay: https://github.com/pzauner/niri-focus-ring-overlay

## Included

- `config/config.kdl` - active Niri config
- `scripts/brightness-cycle.sh` - brightness state machine (`... -> 1% -> 1%+night -> 0%` and symmetric up)
- `scripts/power-profile-cycle.sh` - cycles power profiles (`balanced -> performance -> power-saver`)
- `niri-focus-ring/niri-focus-ring.service` - user service for focus ring overlay
- `niri-focus-ring/niri-focus-ring-daemon.py` - overlay daemon
- `dms/lockscreen-settings.json` - relevant DMS lock/fingerprint settings

## Notes

- `config.kdl` currently has the commands inlined for brightness and power-profile switching.
- Scripts are included here so the logic is versioned in one place and can be referenced from config later.
